include_recipe "deploy"

application = 'personal_cloud_rest_api'
deploy = node[:deploy][application]
rest_api_server_settings = node['pcloud_settings']['rest-api-server']

execute "restart Rails app #{application}" do
  user 'deploy'
  cwd deploy[:current_path]
  command node[:opsworks][:rails_stack][:restart_command]
  action :nothing
end

mailer_settings = rest_api_server_settings['mailer']['production']

template "#{deploy[:deploy_to]}/shared/config/mailer.yml" do
  source "mailer.yml.erb"
  cookbook 'portalapp'
  mode "0660"
  group deploy[:group]
  owner deploy[:user]
  variables({
    :delivery_method => mailer_settings['delivery_method'],
    :smtp_settings => mailer_settings['smtp_settings'],
    :default => mailer_settings['default'],
    :default_url_options => mailer_settings['default_url_options']
  })

  notifies :run, "execute[restart Rails app #{application}]"

  only_if do
    File.directory?("#{deploy[:deploy_to]}/shared/config/")
  end
end

production_settings = rest_api_server_settings['production']

template "#{deploy[:deploy_to]}/shared/config/settings.production.yml" do
  source "production.yml.erb"
  cookbook 'portalapp'
  mode "0660"
  group deploy[:group]
  owner deploy[:user]
  variables({
    :magic_number => production_settings['magic_number'],
    :xmpp => production_settings['xmpp'],
    :environments => production_settings['environments'],
  })

  notifies :run, "execute[restart Rails app #{application}]"

  only_if do
    File.directory?("#{deploy[:deploy_to]}/shared/config/")
  end
end
