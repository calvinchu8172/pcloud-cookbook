execute "setup mongooseim repository" do
  user "root"
  cwd "/tmp"
  command <<-EOH
    wget https://packages.erlang-solutions.com/erlang-solutions_1.0_all.deb && \
    dpkg -i erlang-solutions_1.0_all.deb && \
    apt-get update
  EOH
  not_if "dpkg-query -W mongooseim"
end

package "mongooseim" do
  action :install
end

package "mysql-client" do
  action :install
end

package "redis-tools" do
  action :install
end

template '/etc/security/limits.conf' do
  cookbook 'mongooseim'
  source 'limits.conf.erb'
  owner 'root'
  group 'root'
  mode '0644'
end

template '/etc/pam.d/common-session' do
  cookbook 'mongooseim'
  source 'common-session.erb'
  owner 'root'
  group 'root'
  mode '0644'
end

template '/etc/pam.d/common-session-noninteractive' do
  cookbook 'mongooseim'
  source 'common-session-noninteractive.erb'
  owner 'root'
  group 'root'
  mode '0644'
end

template '/etc/sysctl.conf' do
  cookbook 'mongooseim'
  source 'sysctl.conf.erb'
  owner 'root'
  group 'root'
  mode '0644'
end
