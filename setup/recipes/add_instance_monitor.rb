

instance_setup_alarm_settings = node['ec2_instance_settings']['setup_alarm']

directory "/opt/bin" do
  owner 'root'
  group 'root'
  action :create
  recursive true
end

template "/opt/bin/instance_monitor_alarm.sh" do
  mode '0400'
  owner 'root'
  group 'root'
  source "instance_monitor_alarm.sh.erb"
  variables({
    :sns_resource => instance_setup_alarm_settings['sns_resource']
  })
end

template "/etc/monit/conf.d/instance.monitrc" do
  mode '0400'
  owner 'root'
  group 'root'
  source "instance.monitrc.erb"
end

# monitrc 
service "monit" do
  action :restart
end
