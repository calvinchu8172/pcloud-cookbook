include_recipe 'common::load_config_yaml'
app_region = node["opsworks"]["instance"]["region"]


directory "/opt/aws/cloudwatch" do
  recursive true
end


template "/tmp/cwlogs.cfg" do
  source 'cloudwatch-mongooseim-nodes/awslogs.conf.erb'
  mode '0644'
  owner 'root'
  group 'root'
end

remote_file "/opt/aws/cloudwatch/awslogs-agent-setup.py" do
  source "https://s3.amazonaws.com/aws-cloudwatch/downloads/latest/awslogs-agent-setup.py"
  mode "0755"
end

execute "Install CloudWatch Logs agent" do
  command "/opt/aws/cloudwatch/awslogs-agent-setup.py -n -r #{app_region} -c /tmp/cwlogs.cfg"
  not_if { system "pgrep -f aws-logs-agent-setup" }
end


