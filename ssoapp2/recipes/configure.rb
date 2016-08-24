include_recipe "deploy"

application = 'personal_cloud_sso'
deploy = node[:deploy][application]
rest_api_server_settings = node['pcloud_settings']['rest-api-server']

rails_env = node[:deploy][application][:rails_env]

execute "restart Rails app #{application}" do
  user 'deploy'
  cwd deploy[:current_path]
  command node[:opsworks][:rails_stack][:restart_command]
  action :nothing
end

mailer_settings = rest_api_server_settings['mailer']

template "#{deploy[:deploy_to]}/shared/config/mailer.yml" do
  source "mailer.yml.erb"
  cookbook 'ssoapp2'
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

environments_settings = rest_api_server_settings['environment']

['production', 'staging'].each do |environment|
  template "#{deploy[:deploy_to]}/shared/config/settings.#{environment}.yml" do
    source "#{environment}.yml.erb"
    cookbook 'ssoapp2'
    mode "0660"
    group deploy[:group]
    owner deploy[:user]
    variables({
      :api => environments_settings['api'],
      :xmpp => environments_settings['xmpp'],
      :environments => environments_settings['environments'],
      :oauth => environments_settings['oauth'],
      :recaptcha => environments_settings['recaptcha'],
      :redis => environments_settings['redis'],
      :oauth_applications => environments_settings['oauth_applications'],
      :vendors => environments_settings['vendors'],
      :unicorn => environments_settings['unicorn'],
      :geoip => environments_settings['geoip']
    })

    notifies :run, "execute[restart Rails app #{application}]"

    only_if do
      File.directory?("#{deploy[:deploy_to]}/shared/config/")
    end
  end
end

databases_settings = rest_api_server_settings['databases']

template "#{deploy[:deploy_to]}/shared/config/database.yml" do
  source "database.yml.erb"
  cookbook 'ssoapp2'
  mode "0660"
  group deploy[:group]
  owner deploy[:user]
  variables({
    :databases => databases_settings
  })

  notifies :run, "execute[restart Rails app #{application}]"

  only_if do
    File.directory?("#{deploy[:deploy_to]}/shared/config/")
  end
end



template "/etc/monit/conf.d/" + application + "_unicorn_master.monitrc" do
  mode '0400'
  owner 'root'
  group 'root'
  source "rails_service.monitrc.erb"
  variables(:deploy => deploy, :application => application)
end

service "monit" do
  action :restart
end
