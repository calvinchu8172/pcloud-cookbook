include_recipe "deploy"

# 參數設定
application = 'personal_cloud_sso'
deploy      = node[:deploy][application]
rails_env   = deploy[:rails_env]
settings    = node[:pcloud_settings][:portalapp]

# 宣告 restart command line
execute "restart Rails app #{application}" do
  user deploy[:user]
  cwd deploy[:current_path]
  command node[:opsworks][:rails_stack][:restart_command]
  action :nothing
end

# 生成 database.yml
template "#{deploy[:deploy_to]}/shared/config/database.yml" do
  source 'database.yml.erb'
  cookbook 'ssoapp'
  mode '0660'
  group deploy[:group]
  owner deploy[:user]
  variables({
    databases: settings[:databases]
  })

  notifies :run, "execute[restart Rails app #{application}]"

  only_if do
    File.directory?("#{deploy[:deploy_to]}/shared/config/")
  end
end

# 生成 mailer.yml
template "#{deploy[:deploy_to]}/shared/config/mailer.yml" do
  source 'mailer.yml.erb'
  cookbook 'ssoapp'
  mode '0660'
  group deploy[:group]
  owner deploy[:user]
  variables({
    delivery_method: settings[:mailer][:delivery_method],
    smtp_settings: settings[:mailer][:smtp_settings],
    default: settings[:mailer][:default],
    default_url_options: settings[:mailer][:default_url_options]
  })

  notifies :run, "execute[restart Rails app #{application}]"

  only_if do
    File.directory?("#{deploy[:deploy_to]}/shared/config/")
  end
end

# 生成 settings.{rails_env}.yml
template "#{deploy[:deploy_to]}/shared/config/settings.#{rails_env}.yml" do
  source "#{rails_env}.yml.erb"
  cookbook 'ssoapp'
  mode '0660'
  group deploy[:group]
  owner deploy[:user]
  variables({
    api: settings[:environment][:api],
    xmpp: settings[:environment][:xmpp],
    environments: settings[:environment][:environments],
    oauth: settings[:environment][:oauth],
    recaptcha: settings[:environment][:recaptcha],
    redis: settings[:environment][:redis],
    oauth_applications: settings[:environment][:oauth_applications],
    vendors: settings[:environment][:vendors]
  })

  notifies :run, "execute[restart Rails app #{application}]"

  only_if do
    File.directory?("#{deploy[:deploy_to]}/shared/config/")
  end
end

# 執行 precompile
execute 'rake assets:precompile' do
  cwd deploy[:current_path]
  user deploy[:user]
  command 'bundle exec rake assets:precompile'
  environment 'RAILS_ENV' => rails_env
end

# 生成 unicorn_master.monitrc
template "/etc/monit/conf.d/#{application}_unicorn_master.monitrc" do
  mode '0400'
  owner 'root'
  group 'root'
  source 'rails_service.monitrc.erb'
  variables({
    deploy: deploy,
    application: application
  })
end

# 重啟 monit
service 'monit' do
  action :restart
end
