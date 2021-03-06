include_recipe "common::install_official_docker" 
include_recipe "logger-service::install_awscli"
include_recipe "logger-service::install_fluentd_container"

execute "mkdir for Docker files" do
  cwd "/srv"
  command "mkdir -p fluentd-bot-nodes"
end

template "/srv/fluentd-bot-nodes/Dockerfile" do
  source 'fluentd-bot-nodes/Dockerfile.erb'
  mode '0644'
  owner 'root'
  group 'root'
end

template "/srv/fluentd-bot-nodes/fluent.conf" do
  source 'fluentd-bot-nodes/fluent.conf.erb'
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

execute "build fluentd bot nodes docker image" do
  cwd "/srv/fluentd-bot-nodes"
  command "docker build -t fluentd-bot-nodes ."
end

execute "kill existed fluentd-bot-instance" do
  command "docker rm -f fluentd-bot-instance"
  only_if "docker ps -a | grep 'fluentd-bot-instance'"
end

execute "run fluentd-bot-instance in docker" do
  command "docker run -d -p 24224:24224 -v /srv/www/personal_cloud_bots/shared/log:/srv/www/personal_cloud_bots/shared/log -v /var/log/fluent:/var/log/fluent --name=fluentd-bot-instance fluentd-bot-nodes"
end
