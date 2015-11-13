package "awscli" do
  action :install
end

aws_instance_id = node[:opsworks][:instance][:aws_instance_id]
aws_instance_name = node[:opsworks][:instance][:hostname]
aws_stack_name = node[:opsworks][:stack][:name]

instance_setup_alarm_settings = node['ec2_instance_settings']['setup_alarm']
instance_setup_alarm_settings['alarm_settings'].each do |alarm_setting|
  execute "add CloudWatch alarms to EC2 instances" do
    user "root"
    command <<-EOH
      aws cloudwatch put-metric-alarm \
        --region "#{instance_setup_alarm_settings['region']}" \
        --alarm-name "#{aws_stack_name}-#{aws_instance_name}-#{alarm_setting['metric_name']}" \
        --alarm-description "#{alarm_setting['metric_name']} " \
        --actions-enabled \
        --ok-actions "#{instance_setup_alarm_settings['sns_resource']}" \
        --alarm-actions "#{instance_setup_alarm_settings['sns_resource']}" \
        --metric-name "#{alarm_setting['metric_name']}" \
        --namespace AWS/EC2 \
        --statistic #{alarm_setting['statistic']} \
        --dimensions Name=InstanceId,Value=#{aws_instance_id} \
        --period #{alarm_setting['period']} \
        --unit #{alarm_setting['unit']} \
        --evaluation-periods #{alarm_setting['consecutive_periods']} \
        --threshold #{alarm_setting['threshold']} \
        --comparison-operator #{alarm_setting['comparison-operator']}
    EOH
  end
end