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

# Stop MongooseIM before anything is done
service "mongooseim" do
  action :stop
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
    aws s3 cp s3://#{mongooseim_settings['ejabberd_c2s']['s3_bucket']}/certificate/#{mongooseim_settings['ejabberd_c2s']['certfile']} \
    #{mongooseim_settings['ejabberd_c2s']['certfile']} --region 'us-east-1'
  EOH

  not_if "test -f #{mongooseim_settings['ejabberd_c2s']['certpath']}#{mongooseim_settings['ejabberd_c2s']['certfile']}"
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

service "mongooseim" do
  action :start
end
