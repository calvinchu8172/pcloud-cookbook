execute "mkdir for Docker files" do
  cwd "/srv"
  command "mkdir -p ruby-rvm-base fluentd-base personal-cloud-bot personal-cloud-portal"
end

# setup ruby-rvm-base

cookbook_file "Dockerfile" do
  source "ruby-rvm-base/Dockerfile"
  path "/srv/ruby-rvm-base/Dockerfile"
  action :create
end

execute "build RVM docker base image" do
  cwd "/srv/ruby-rvm-base"
  command "docker build -t ruby-rvm-base ."
end

# setup fluentd-base

cookbook_file "Dockerfile" do
  source "fluentd-base/Dockerfile"
  path "/srv/fluentd-base/Dockerfile"
  action :create
end

cookbook_file "monitrc" do
  source "fluentd-base/monitrc"
  path "/srv/fluentd-base/monitrc"
  action :create
end

execute "build fluentd docker base image" do
  cwd "/srv/fluentd-base"
  command "docker build -t fluentd-base ."
end

# setup fluentd for personal-cloud-portal

cookbook_file "Dockerfile" do
  source "personal-cloud-portal/Dockerfile"
  path "/srv/personal-cloud-portal/Dockerfile"
  action :create
end

cookbook_file "fluent.conf" do
  source "personal-cloud-portal/fluent.conf"
  path "/srv/personal-cloud-portal/fluent.conf"
  action :create
end

cookbook_file "out_hipchatv2.rb" do
  source "personal-cloud-portal/out_hipchatv2.rb"
  path "/srv/personal-cloud-portal/out_hipchatv2.rb"
  action :create
end

execute "build personal cloud portal specific fluentd docker image" do
  cwd "/srv/personal-cloud-portal"
  command "docker build -t personal-cloud-portal ."
end

running_container_id = `docker ps -a | grep "24224/tcp" | cut -d" " -f1`

execute "kill fluentd container" do
  command "docker kill #{running_container_id}"
  not_if { running_container_id.empty? }
end

execute "just run a fresh fluentd container" do
  command "docker run -d -p 24224:24224 -v /var/log/fluent:/var/log/fluent personal-cloud-portal"
end
