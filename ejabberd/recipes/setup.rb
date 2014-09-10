require 'resolv'

template '/etc/hosts' do
  cookbook 'ejabberd'
  source "hosts.erb"
  mode "0644"
  variables(
    :localhost_name => node[:opsworks][:instance][:hostname],
    :nodes => search(:node, "name:*")
  )
end

template '/etc/ejabberd/ejabberdctl.cfg' do
  cookbook 'ejabberd'
  source "ejabberdctl.cfg.erb"
  mode "0640"
  variables(
    :private_ip => node[:opsworks][:instance][:private_ip],
    :aws_instance_id => node[:opsworks][:instance][:aws_instance_id]
  )
end

template '/etc/security/limits.conf' do
  cookbook 'ejabberd'
  source 'limits.conf.erb'
  owner 'root'
  group 'root'
  mode '0644'
end
