require 'aws-sdk'

ENV['AWS_REGION'] = "us-east-1"

Chef::Log.info("Setup a secondary NIC with an Elastic IP address")

Aws.config.update({
  region: 'us-east-1',
  credentials: Aws::InstanceProfileCredentials.new(), 
})

client = Aws::EC2::Client.new()
resource = Aws::EC2::Resource.new(client: client)
Chef::Log.info(resource.network_interfaces)
