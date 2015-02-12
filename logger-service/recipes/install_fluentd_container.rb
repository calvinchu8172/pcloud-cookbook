execute "mkdir for Docker files" do
  cwd "/srv"
  command "mkdir -p ruby-rvm-base fluentd-base fluentd-center"
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
