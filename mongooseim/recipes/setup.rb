execute "setup mongooseim repository" do
  user "root"
  cwd "/tmp"
  command <<-EOH
    wget https://packages.erlang-solutions.com/erlang-solutions_1.0_all.deb && \
    dpkg -i erlang-solutions_1.0_all.deb && \
    apt-get update
  EOH
  not_if "test -f /etc/apt/sources.list.d/erlang-solutions.list"
end

package "mongooseim" do
  version '1.5.0-1'
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

# development packages for OTP module compilation
['erlang-base', 'erlang-base-hipe'].each do |package|
  package "#{package}" do
    action :install
  end
end

# directory for OTP module compilation
remote_directory "/opt/one-time-password" do
  source 'one-time-password'
  owner 'mongooseim'
  group 'mongooseim'
  action :create
  recursive true
end

# OTP module path
otp_ebin_path = "/usr/lib/mongooseim/lib/onetime-password-1.0.0/ebin"

directory "#{otp_ebin_path}" do
  owner 'mongooseim'
  group 'mongooseim'
  action :create
  recursive true
end

execute 'compile one time password module' do
  user 'mongooseim'
  cwd '/opt/one-time-password'
  command "erlc mod_onetime_password.erl"
end

execute 'deploy one time password module' do
  user 'root'
  cwd '/opt/one-time-password'
  command "cp mod_onetime_password.beam #{otp_ebin_path}"
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

execute 'remove Mnesia database folder' do
  user 'root'
  cwd '/usr/lib/mongooseim/'
  command <<-EOH
    mkdir -p /usr/lib/mongooseim/temp && \
    mv Mnesia.mongooseim@#{node[:opsworks][:instance][:hostname]} ./temp
  EOH
end

execute "start mongooseim" do
  user "root"
  command "service mongooseim start"
end
