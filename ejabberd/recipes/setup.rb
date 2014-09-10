template '/etc/ejabberd/ejabberdctl.cfg' do
  cookbook 'ejabberd'
  source "ejabberdctl.cfg.erb"
  mode "0640"
  variables(
    :private_ip => node[:opsworks][:instance][:private_ip],
    :hostname => node[:opsworks][:instance][:hostname],
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
