include_recipe "deploy"

application = 'personal_cloud_portal'
deploy = node[:deploy][application]
portalapp_settings = node['pcloud_settings']['portalapp']

execute "restart Rails app #{application}" do
  user 'deploy'
  cwd deploy[:current_path]
  command node[:opsworks][:rails_stack][:restart_command]
  action :nothing
end

mailer_settings = portalapp_settings['mailer']

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

environments_settings = portalapp_settings['environment']

['production', 'staging'].each do |environment|
  template "#{deploy[:deploy_to]}/shared/config/settings.#{environment}.yml" do
    source "#{environment}.yml.erb"
    cookbook 'portalapp'
    mode "0660"
    group deploy[:group]
    owner deploy[:user]
    variables({
      :magic_number => environments_settings['magic_number'],
      :xmpp => environments_settings['xmpp'],
      :environments => environments_settings['environments'],
      :version => environments_settings['version'],
      :oauth => environments_settings['oauth'],
      :recaptcha => environments_settings['recaptcha'],
      :redis => environments_settings['redis']
    })

    notifies :run, "execute[restart Rails app #{application}]"

    only_if do
      File.directory?("#{deploy[:deploy_to]}/shared/config/")
    end
  end
end

databases_settings = portalapp_settings['databases']

template "#{deploy[:deploy_to]}/shared/config/database.yml" do
  source "database.yml.erb"
  cookbook 'portalapp'
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

execute "sidekiq" do
  cwd deploy[:current_path]
  user deploy[:user]
  command "bundle exec sidekiq -d -L log/sidekiq.log -q mailer"

  not_if "ps -ef |grep sidekiq |grep -v grep"
end
