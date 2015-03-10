include_recipe "logger-service::install_official_docker" 
include_recipe "logger-service::install_fluentd_container"

execute "mkdir for Docker files" do
  cwd "/srv"
  command "mkdir -p fluentd-portal-nodes"
end

cookbook_file "Dockerfile" do
  source "fluentd-portal-nodes/Dockerfile"
  path "/srv/fluentd-portal-nodes/Dockerfile"
  action :create
end

template "/srv/fluentd-portal-nodes/fluent.conf" do
  source 'fluentd-portal-nodes/fluent.conf.erb'
  mode '0644'
  owner 'root'
  group 'root'
  variables({
    :layer => node[:opsworks][:stack][:name].squeeze.downcase.tr(" ", "_"),
    :hostname => node[:opsworks][:instance][:hostname],
    :fluentd1 => node['loggers']['fluentd1'],
    :fluentd2 => node['loggers']['fluentd2']
  })
end

execute "build fluentd logging center docker image" do
  cwd "/srv/fluentd-portal-nodes"
  command "docker build -t fluentd-portal-nodes ."
end

running_container_id = `docker ps -a | grep "24224/tcp" | cut -d" " -f1`

execute "kill fluentd container" do
  command "docker kill #{running_container_id}"
  not_if { running_container_id.empty? }
end

execute "just run a fresh fluentd container" do
  command "docker run -d -p 24224:24224 -v /var/log/fluent:/var/log/fluent -v /srv/www/personal_cloud_portal/shared/log:/srv/www/personal_cloud_portal/shared/log fluentd-portal-nodes"
end
