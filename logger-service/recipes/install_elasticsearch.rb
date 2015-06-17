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

execute "configure elasticsearch to automatically start during bootup" do
  command "update-rc.d elasticsearch defaults 95 10"
end

service "elasticsearch" do
  supports :status => true, :restart => true
  action [ :enable, :start ]
end
