package "mysql-client" do
  action :install
end

package "redis-tools" do
  action :install
end

package "awscli" do
  action :install
end

bots_instances_data_s3 = node['pcloud_settings']['bots']['instances']['s3']

execute "load bot instances data from S3" do
  user "root"
  cwd "/var/tmp/"
  command <<-EOH
    AWS_ACCESS_KEY_ID=#{bots_instances_data_s3['key_id']} \
    AWS_SECRET_ACCESS_KEY=#{bots_instances_data_s3['secret_key']} \
    aws s3 cp s3://#{bots_instances_data_s3['bucket']}/bots/bots.json bots.json --region 'us-east-1'
  EOH
end
