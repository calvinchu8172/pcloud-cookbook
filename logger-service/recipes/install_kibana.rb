kibana = "kibana-4.1.1-linux-x64"

execute "download kibana" do
  cwd "/tmp"
  command "wget https://download.elasticsearch.org/kibana/kibana/#{kibana}.tar.gz"
  not_if "test -f /tmp/#{kibana}.tar.gz"
end

execute "setup kibana" do
  cwd "/srv"
  command "tar xvfz /tmp/#{kibana}.tar.gz"
  not_if "test -d /srv/#{kibana}"
end

cookbook_file "kibana.yml" do
  source "kibana/kibana.yml"
  path "/srv/#{kibana}/config/kibana.yml"
  action :create
end

cookbook_file "logrotate" do
  source "kibana/logrotate"
  path "/etc/logrotate.d/kibana"
  owner 'root'
  group 'root'
  action :create
end

execute "kill running kibana" do
  command "kill `/bin/cat /var/run/kibana.pid`"
  #only_if "ps -ef | grep 'node.*kibana\.js'"
  only_if "test -f /var/run/kibana.pid"
end

bash "run kibana" do
  code "/srv/#{kibana}/bin/kibana -q &"
end
