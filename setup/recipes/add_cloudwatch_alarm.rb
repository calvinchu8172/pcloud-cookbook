package "awscli" do
  action :install
end

aws_instance_id = node[:opsworks][:instance][:aws_instance_id]
aws_instance_name = node[:opsworks][:instance][:hostname]
aws_stack_name = node[:opsworks][:stack][:name]

ec2_instance_settings = {
  "setup_alarm" => {
    "sns_resource" => "arn:aws:sns:us-east-1:212868998188:PCloud-Ecowork-Staff",
    "alarm_settings" => [
      { "mertric_name" => "CPUUtilization", "threshold" => 80, "consecutive_periods" => 3, "period" => 300, "statistic" => "Average", "unit" => "Seconds", "comparison-operator" => "GreaterThanOrEqualToThreshold" },
      { "mertric_name" => "StatusCheckFailed", "threshold" => 1, "consecutive_periods" => 1, "period" => 300, "statistic" => "Average", "unit" => "Seconds", "comparison-operator" => "GreaterThanOrEqualToThreshold" }
    ]
  }
}

ec2_instance_settings['setup_alarm']['alarm_settings'].each do |alarm_setting|
  execute "add CloudWatch alarms to EC2 instances" do
    user "root"
    command <<-EOH
      aws cloudwatch put-metric-alarm
        --alarm-name "#{aws_stack_name}-#{aws_instance_name}-#{alarm_setting['mertric_name']}"
        --alarm-description "#{alarm_setting['mertric_name']} "
        --actions-enabled true
        --ok-actions "#{ec2_instance_settings['setup_alarm']['sns_resource']}"
        --alarm-actions "#{ec2_instance_settings['setup_alarm']['sns_resource']}"
        --metric-name "#{alarm_setting['metric_name']}"
        --namespace AWS/EC2
        --statistic #{alarm_setting['statistic']}
        --dimensions Name=InstanceId,Value=#{aws_instance_id}
        --period #{alarm_setting['period']}
        --unit #{alarm_setting['unit']}
        --evaluation-periods #{alarm_setting['consecutive_periods']}
        --threshold #{alarm_setting['threshold']}
        --comparison-operator #{alarm_setting['comparison-operator']})
    EOH
  end
end