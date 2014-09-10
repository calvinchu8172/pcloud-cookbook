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

execute "rm /var/lib/ejabberd/*" do
  user 'root'
  notifies :create, "ruby_block[ejabberd_files_cleaned_flag]", :immediately
  not_if { node.attribute?("ejabberd_files_cleaned") }
end

ruby_block "ejabberd_files_cleaned_flag" do
  block do
    node.set['ejabberd_files_cleaned'] = true
    node.save
  end
  action :nothing
end

execute "ejabberdctl start" do
  user 'root'
  notifies :create, "ruby_block[ejabberd_started_flag]", :immediately
  not_if { node.attribute?("ejabberd_started") }
end

ruby_block "ejabberd_started_flag" do
  block do
    node.set['ejabberd_started'] = true
    node.save
  end
  action :nothing
end
