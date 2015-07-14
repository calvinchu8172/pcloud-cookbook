execute "add elasticsearch official repository apt-key" do
  cwd "/tmp"
  command "wget -qO - https://packages.elasticsearch.org/GPG-KEY-elasticsearch | apt-key add -"
end

execute "add elasticsearch official repository" do
  command <<-EOH
    add-apt-repository 'deb http://packages.elasticsearch.org/elasticsearch/1.6/debian stable main' && \
    apt-get update
  EOH
end

package "default-jre" do
  action :install
end

package "elasticsearch" do
  action :install
end

directory '/var/run/elasticsearch' do
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end

execute "configure elasticsearch to automatically start during bootup" do
  command "update-rc.d elasticsearch defaults 95 10"
end

cron "elasticsearch_log_expiration" do
  minute '00'
  hour '11'
  command "find /var/log/elasticsearch -name 'elasticsearch.log.*' -ctime +30 -delete"
end

service "elasticsearch" do
  supports :status => true, :restart => true
  action [ :enable, :start ]
end
