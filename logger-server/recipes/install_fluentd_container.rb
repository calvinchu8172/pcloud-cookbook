execute "mkdir for Docker files" do
  cwd "/srv"
  command "mkdir ecowork_fluentd personal_cloud_fluentd"
end

cookbook_file "ecowork_fluentd/Dockerfile" do
  path "/srv/ecowork_fluentd/Dockerfile"
  action :create
end

execute "build docker image" do
  cwd "/srv/ecowork_fluentd"
  command "docker build -t ecowork/fluentd ."
end

execute "run fluentd container" do
  command "docker run -d ecowork/fluentd"
end
