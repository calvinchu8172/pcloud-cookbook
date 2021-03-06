

instance_setup_alarm_settings = node['ec2_instance_settings']['setup_alarm']

stack    = node[:opsworks][:stack][:name]
hostname = node[:opsworks][:instance][:hostname]
aws_instance_id = node["opsworks"]["instance"]["aws_instance_id"]
account = instance_setup_alarm_settings['sns_resource'].split(':')[4]

directory "/opt/bin" do
  owner 'root'
  group 'root'
  action :create
  recursive true
end

template "/opt/bin/instance_monitor_alarm.sh" do
  mode '0700'
  owner 'root'
  group 'root'
  source "instance_monitor_alarm.sh.erb"
  variables({
    :sns_resource => instance_setup_alarm_settings['sns_resource'],
    :region => instance_setup_alarm_settings['region'],
    :stack => stack,
    :hostname => hostname,
    :aws_instance_id => aws_instance_id,
    :account => account
  })
end

template "/etc/monit/conf.d/instance.monitrc" do
  mode '0700'
  owner 'root'
  group 'root'
  source "instance.monitrc.erb"
end

# monitrc 
service "monit" do
  action :restart
end
