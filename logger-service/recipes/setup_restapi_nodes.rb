include_recipe "common::install_official_docker" 
include_recipe "logger-service::install_awscli"
include_recipe "logger-service::install_fluentd_container"

execute "mkdir for Docker files" do
  cwd "/srv"
  command "mkdir -p fluentd-restapi-nodes"
end

template "/srv/fluentd-restapi-nodes/Dockerfile" do
  source 'fluentd-restapi-nodes/Dockerfile.erb'
  mode '0644'
  owner 'root'
  group 'root'
end

template "/srv/fluentd-restapi-nodes/fluent.conf" do
  source 'fluentd-restapi-nodes/fluent.conf.erb'
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

execute "build fluentd REST API server nodes docker image" do
  cwd "/srv/fluentd-restapi-nodes"
  command "docker build -t fluentd-restapi-nodes ."
end

execute "kill fluentd container" do
  command "docker rm -f fluentd-restapi-instance"
  only_if "docker ps -a | grep 'fluentd-restapi-instance'"
end

execute "just run a fresh fluentd container" do
  command <<-EOF
    docker run -d \
      -p 24224:24224 \
      -v /var/log/fluent:/var/log/fluent \
      -v /srv/www/personal_cloud_rest_api/shared/log:/srv/www/personal_cloud_rest_api/shared/log \
      --name=fluentd-restapi-instance \
      fluentd-restapi-nodes
  EOF
end
