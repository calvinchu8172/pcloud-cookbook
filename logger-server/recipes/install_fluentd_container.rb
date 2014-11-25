execute "mkdir for Docker files" do
  cwd "/srv"
  command "mkdir -p ecowork_fluentd personal_cloud_fluentd"
end

cookbook_file "Dockerfile-ecowork-fluentd" do
  path "/srv/ecowork_fluentd/Dockerfile"
  action :create
end

execute "build docker image" do
  cwd "/srv/ecowork_fluentd"
  command "docker build -t ecowork/fluentd ."
end

execute "kill fluentd container" do
  command <<-EOH
    docker ps -a | grep "ecowork/fluentd" | cut -d" " -f1 | xargs sudo docker kill && \
    docker ps -a | grep "ecowork/fluentd" | cut -d" " -f1 | xargs sudo docker rm
  EOH

  only_if "ps ef | grep fluentd | grep ruby | grep -v grep"
end

execute "run fluentd container" do
  command "docker run -d ecowork/fluentd"
end
