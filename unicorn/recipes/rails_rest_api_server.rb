unless node[:opsworks][:skip_uninstall_of_other_rails_stack]
  include_recipe "apache2::uninstall"
end

include_recipe "nginx"
include_recipe "unicorn"

application = 'personal_cloud_rest_api'
deploy = node[:deploy][application]

opsworks_deploy_user do
  deploy_data deploy
end

opsworks_deploy_dir do
  user deploy[:user]
  group deploy[:group]
  path deploy[:deploy_to]
end

template "#{deploy[:deploy_to]}/shared/scripts/unicorn" do
  mode '0755'
  owner deploy[:user]
  group deploy[:group]
  source "unicorn.service.erb"
  variables(:deploy => deploy, :application => application)
end

service "unicorn_#{application}" do
  start_command "#{deploy[:deploy_to]}/shared/scripts/unicorn start"
  stop_command "#{deploy[:deploy_to]}/shared/scripts/unicorn stop"
  restart_command "#{deploy[:deploy_to]}/shared/scripts/unicorn restart"
  status_command "#{deploy[:deploy_to]}/shared/scripts/unicorn status"
  action :nothing
end

template "#{deploy[:deploy_to]}/shared/config/unicorn.conf" do
  mode '0644'
  owner deploy[:user]
  group deploy[:group]
  source "unicorn.conf.erb"
  variables(:deploy => deploy, :application => application)
end


template "/etc/monit/conf.d/" + application + "_unicorn_master.monitrc" do
  mode '0400'
  owner 'root'
  group 'root'
  source "rails_service_monitrc.erb"
  variables(:deploy => deploy, :application => application)
end

service "monit" do
  action :restart
end