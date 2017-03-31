

instance_setup_alarm_settings = node['ec2_instance_settings']['setup_alarm']

stack    = node[:opsworks][:stack][:name].squeeze.downcase.tr(' ', '_')
hostname = node[:opsworks][:instance][:hostname]
layers = node[:opsworks][:instance][:layers]


puts "stack: #{stack}"

layers.each do |layer|
  puts "layer: #{layer['name']}"
end

puts "hostname: #{hostname}"
puts "instance_id: #{node["opsworks"]["instance"]["id"]}"
puts "aws_instance_id: #{node["opsworks"]["instance"]["aws_instance_id"]}"


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
    :region => instance_setup_alarm_settings['region']
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
