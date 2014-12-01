execute "mkdir for Docker files" do
  cwd "/srv"
  command "mkdir -p ecowork_fluentd personal_cloud_fluentd"
end

cookbook_file "Dockerfile-ecowork-fluentd" do
  path "/srv/ecowork_fluentd/Dockerfile"
  action :create
end

execute "build fluentd docker base image" do
  cwd "/srv/ecowork_fluentd"
  command "docker build -t ecowork/fluentd ."
end

cookbook_file "Dockerfile-personal-cloud-fluentd" do
  path "/srv/personal_cloud_fluentd/Dockerfile"
  action :create
end

cookbook_file "fluent.conf" do
  path "/srv/personal_cloud_fluentd/fluent.conf"
  action :create
end

cookbook_file "out_hipchatv2.rb" do
  path "/srv/personal_cloud_fluentd/out_hipchatv2.rb"
  action :create
end

execute "build personal cloud specific fluentd docker image" do
  cwd "/srv/personal_cloud_fluentd"
  command "docker build -t personal_cloud/fluentd ."
end

running_container_id = `docker ps -a | grep "24224/tcp" | cut -d" " -f1`

execute "kill fluentd container" do
  command "docker kill #{running_container_id}"
  not_if { running_container_id.empty? }
end

execute "just run a fresh fluentd container" do
  command "docker run -d -p 24224:24224 personal_cloud/fluentd"
  not_if "ps -ef | grep fluentd | grep ruby | grep -v grep"
end
