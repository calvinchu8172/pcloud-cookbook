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

package "awscli" do
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

template '/usr/lib/mongooseim/etc/vm.args' do
  cookbook 'mongooseim'
  source 'vm.args.erb'
  owner 'mongooseim'
  group 'mongooseim'
  mode '0644'
  variables({
    :hostname => node[:opsworks][:instance][:hostname]
  })
end

mongooseim_settings = node['pcloud_settings']['mongooseim']

template '/usr/lib/mongooseim/etc/ejabberd.cfg' do
  cookbook 'mongooseim'
  source 'ejabberd.cfg.erb'
  owner 'mongooseim'
  group 'mongooseim'
  mode '0644'
  variables({
    :vhost => mongooseim_settings['vhost'],
    :ejabberd_c2s => mongooseim_settings['ejabberd_c2s'],
    :sm_backend => mongooseim_settings['sm_backend'],
    :auth_method => mongooseim_settings['auth_method']
  })
end
