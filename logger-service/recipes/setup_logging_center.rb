include_recipe "common::install_official_docker" 
include_recipe "logger-service::install_fluentd_container"

execute "mkdir for Docker files" do
  cwd "/srv"
  command "mkdir -p fluentd-center"
end

# setup fluentd logging center

template "/srv/fluentd-center/Dockerfile" do
  source 'fluentd-center/Dockerfile.erb'
  mode '0644'
  owner 'root'
  group 'root'
  variables({
    :access_key => node['fluentd-center']['access_key'],
    :secret_key => node['fluentd-center']['secret_key']
  })
end

template "/srv/fluentd-center/fluent.conf" do
  source 'fluentd-center/fluent.conf.erb'
  mode '0644'
  owner 'root'
  group 'root'
  variables({
    :environments => ['alpha', 'beta', 'production'],
    :elasticsearch_host => node['elasticsearch']['host']
  })
end

cookbook_file "out_hipchatv2.rb" do
  source "fluentd-center/out_hipchatv2.rb"
  path "/srv/fluentd-center/out_hipchatv2.rb"
  action :create
end

execute "build fluentd logging center docker image" do
  cwd "/srv/fluentd-center"
  command "docker build -t fluentd-center ."
end

execute "kill fluentd container" do
  command "docker rm -f fluentd-center-instance"
  only_if "docker ps -a | grep 'fluentd-center-instance'"
end

execute "just run a fresh fluentd container" do
  command "docker run -d -p 24224:24224 -v /var/log/fluent:/var/log/fluent --name=fluentd-center-instance fluentd-center"
end
