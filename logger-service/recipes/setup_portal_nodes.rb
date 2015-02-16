include_recipe "logger-service::install_official_docker" 
include_recipe "logger-service::install_fluentd_container"

execute "mkdir for Docker files" do
  cwd "/srv"
  command "mkdir -p fluentd-portal-nodes"
end

# setup fluentd for Rails apps nodes (e.g. Portal & REST API Server)

cookbook_file "Dockerfile" do
  source "fluentd-portal-nodes/Dockerfile"
  path "/srv/fluentd-portal-nodes/Dockerfile"
  action :create
end

cookbook_file "fluent.conf" do
  source "fluentd-portal-nodes/fluent.conf"
  path "/srv/fluentd-portal-nodes/fluent.conf"
  action :create
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
