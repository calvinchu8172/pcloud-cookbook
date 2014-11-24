cookbook_file "Dockerfile" do
  path "/srv/Dockerfile"
  action :create
end

execute "build docker image" do
  cwd "/srv"
  command "docker build -t personal_cloud/fluentd ."
end
