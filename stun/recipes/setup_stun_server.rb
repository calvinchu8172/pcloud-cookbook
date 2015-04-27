include_recipe "common::install_official_docker" 

execute "mkdir for Docker files" do
  cwd "/srv"
  command "mkdir -p stunserver"
end

cookbook_file "Dockerfile" do
  source "Dockerfile"
  path "/srv/stunserver/Dockerfile"
  action :create
end

execute "build stunserver docker image" do
  cwd "/srv/stunserver"
  command "docker build -t stunserver ."
end

execute "run stunserver in docker" do
  command "docker run -d --net=host stunserver /opt/stunserver/stunserver --mode full --primaryinterface eth0 --altinterface eth1"
end
