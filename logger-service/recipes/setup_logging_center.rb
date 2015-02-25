include_recipe "logger-service::install_official_docker" 
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

#cookbook_file "fluent.conf" do
  #source "fluentd-center/fluent.conf"
  #path "/srv/fluentd-center/fluent.conf"
  #action :create
#end

template "/srv/fluentd-center/fluent.conf" do
  source 'fluentd-center/fluent.conf.erb'
  mode '0644'
  owner 'root'
  group 'root'
  variables({
    :access_key => node['fluentd-center']['access_key'],
    :secret_key => node['fluentd-center']['secret_key']
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

running_container_id = `docker ps -a | grep "24224/tcp" | cut -d" " -f1`

execute "kill fluentd container" do
  command "docker kill #{running_container_id}"
  not_if { running_container_id.empty? }
end

execute "just run a fresh fluentd container" do
  command "docker run -d -p 24224:24224 -v /var/log/fluent:/var/log/fluent fluentd-center"
end
