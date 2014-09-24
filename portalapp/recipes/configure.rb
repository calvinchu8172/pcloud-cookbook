include_recipe "deploy"

application = 'personal_cloud_portal'
deploy = node[:deploy][application]

execute "restart Rails app #{application}" do
  user 'deploy'
  cwd deploy[:current_path]
  command node[:opsworks][:rails_stack][:restart_command]
  action :nothing
end

node.default[:deploy][application][:database][:adapter] = OpsWorks::RailsConfiguration.determine_database_adapter(application, node[:deploy][application], "#{node[:deploy][application][:deploy_to]}/current", :force => node[:force_database_adapter_detection])
deploy = node[:deploy][application]

template "#{deploy[:deploy_to]}/shared/config/database.yml" do
  source "database.yml.erb"
  cookbook 'rails'
  mode "0660"
  group deploy[:group]
  owner deploy[:user]
  variables(:database => deploy[:database], :environment => deploy[:rails_env])

  notifies :run, "execute[restart Rails app #{application}]"

  only_if do
    deploy[:database][:host].present? && File.directory?("#{deploy[:deploy_to]}/shared/config/")
  end
end

template "#{deploy[:deploy_to]}/shared/config/memcached.yml" do
  source "memcached.yml.erb"
  cookbook 'rails'
  mode "0660"
  group deploy[:group]
  owner deploy[:user]
  variables(
    :memcached => deploy[:memcached] || {},
    :environment => deploy[:rails_env]
  )

  notifies :run, "execute[restart Rails app #{application}]"

  only_if do
    deploy[:memcached][:host].present? && File.directory?("#{deploy[:deploy_to]}/shared/config/")
  end
end

template "#{deploy[:deploy_to]}/shared/config/mailer.yml" do
  source "mailer.yml.erb"
  cookbook 'portalapp'
  mode "0660"
  group deploy[:group]
  owner deploy[:user]

  notifies :run, "execute[restart Rails app #{application}]"

  only_if do
    File.directory?("#{deploy[:deploy_to]}/shared/config/")
  end
end

template "#{deploy[:deploy_to]}/shared/config/settings.production.yml" do
  source "production.yml.erb"
  cookbook 'portalapp'
  mode "0660"
  group deploy[:group]
  owner deploy[:user]

  notifies :run, "execute[restart Rails app #{application}]"

  only_if do
    File.directory?("#{deploy[:deploy_to]}/shared/config/")
  end
end

template "#{deploy[:deploy_to]}/shared/config/secrets.yml" do
  source "secrets.yml.erb"
  cookbook 'portalapp'
  mode "0660"
  group deploy[:group]
  owner deploy[:user]
  variables({
    :production_secret_key => 'c894834ec3f545ba9f1495e4a68be7db6c25ba3400439349c2e86684845c90fd7a6eccf666cc651c2f1b38a80585c8cf4ed7466a15acdba2b9701402a5af2aef'
  })

  notifies :run, "execute[restart Rails app #{application}]"

  only_if do
    File.directory?("#{deploy[:deploy_to]}/shared/config/")
  end
end
