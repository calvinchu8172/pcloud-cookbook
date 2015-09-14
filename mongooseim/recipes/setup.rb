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

execute "/sbin/ip link set dev eth0 mtu 1400" do
  user "root"
end

template '/etc/sysctl.conf' do
  cookbook 'mongooseim'
  source 'sysctl.conf.erb'
  owner 'root'
  group 'root'
  mode '0644'
end

execute "setup port forwarding 443 to 5222" do
  user "root"
  command "iptables -t nat -A PREROUTING -i eth0 -p tcp --dport 443 -j REDIRECT --to-port 5222"
end

execute "shutdown mongooseim first during setting things up & done" do
  user "root"
  command "service mongooseim stop"
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

execute "load secret key from S3" do
  user "root"
  cwd "#{mongooseim_settings['ejabberd_c2s']['certpath']}"
  command <<-EOH
    AWS_ACCESS_KEY_ID=#{mongooseim_settings['ejabberd_c2s']['s3_access_key']} \
    AWS_SECRET_ACCESS_KEY=#{mongooseim_settings['ejabberd_c2s']['s3_secret_key']} \
    aws s3 cp s3://#{mongooseim_settings['ejabberd_c2s']['s3_bucket']}/certificates/#{mongooseim_settings['ejabberd_c2s']['certfile']} \
    #{mongooseim_settings['ejabberd_c2s']['certfile']} --region 'us-east-1'
  EOH

  #not_if "test -f #{mongooseim_settings['ejabberd_c2s']['certpath']}#{mongooseim_settings['ejabberd_c2s']['certfile']}"
end

execute "set ownership & permission of secret key" do
  user "root"
  cwd "#{mongooseim_settings['ejabberd_c2s']['certpath']}"
  command <<-EOH
    chown mongooseim:mongooseim #{mongooseim_settings['ejabberd_c2s']['certpath']}#{mongooseim_settings['ejabberd_c2s']['certfile']} && \
    chmod 0400 #{mongooseim_settings['ejabberd_c2s']['certpath']}#{mongooseim_settings['ejabberd_c2s']['certfile']}
  EOH

  only_if "test -f #{mongooseim_settings['ejabberd_c2s']['certpath']}#{mongooseim_settings['ejabberd_c2s']['certfile']}"
end

package "erlang-base" do
  action :install
end

package "erlang-base-hipe" do
  action :install
end

git 'one time password download' do
  repository 'git@gitlab.ecoworkinc.com:zyxel/one-time-password.git'
  revision 'develop'
  destination '/tmp/one-time-password'
  action :sync
end

execute 'compile one time password module' do
  user 'root'
  cwd '/tmp/one-time-password'
  command 'erlc mod_onetime_password.erl && cp mod_onetime_password.beam /usr/lib/mongooseim/lib/ejabberd-2.1.8+mim-1.5.1/ebin/'
end

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

execute "start mongooseim" do
  user "root"
  command "service mongooseim start"
end
