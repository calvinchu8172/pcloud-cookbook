include_recipe "install_official_docker" 
include_recipe "install_fluentd_container"

# setup fluentd logging center

cookbook_file "Dockerfile" do
  source "fluentd-center/Dockerfile"
  path "/srv/fluentd-center/Dockerfile"
  action :create
end

cookbook_file "fluent.conf" do
  source "fluentd-center/fluent.conf"
  path "/srv/fluentd-center/fluent.conf"
  action :create
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
