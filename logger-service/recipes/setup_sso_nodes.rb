include_recipe "common::install_official_docker"
include_recipe "logger-service::install_awscli"
include_recipe "logger-service::install_fluentd_container"

execute "mkdir for Docker files" do
  cwd "/srv"
  command "mkdir -p fluentd-sso-nodes"
end

template "/srv/fluentd-sso-nodes/Dockerfile" do
  source 'fluentd-sso-nodes/Dockerfile.erb'
  mode '0644'
  owner 'root'
  group 'root'
end

puts "*********" + node[:opsworks][:stack][:name]
puts "*********" + node[:opsworks][:stack][:name].squeeze.downcase.tr(" ", "_")

template "/srv/fluentd-sso-nodes/fluent.conf" do
  source 'fluentd-sso-nodes/fluent.conf.erb'
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

execute "build fluentd sso nodes docker image" do
  cwd "/srv/fluentd-sso-nodes"
  command "docker build -t fluentd-sso-nodes ."
end

execute "kill fluentd container" do
  command "docker rm -f fluentd-sso-instance"
  only_if "docker ps -a | grep 'fluentd-sso-instance'"
end

execute "just run a fresh fluentd container" do
  command <<-EOF
    docker run -d \
      -p 24224:24224 \
      -v /var/log/fluent:/var/log/fluent \
      -v /srv/www/personal_cloud_sso/shared/log:/srv/www/personal_cloud_sso/shared/log \
      --name=fluentd-sso-instance \
      fluentd-sso-nodes
  EOF
end
