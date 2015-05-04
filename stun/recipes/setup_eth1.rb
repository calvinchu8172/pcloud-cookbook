require 'aws-sdk'

ENV['AWS_REGION'] = "us-east-1"

Chef::Log.info("Setup a secondary NIC with an Elastic IP address")

client = Aws::EC2::Client.new(region: 'us-east-1')
resource = Aws::EC2::Resource.new(client: client)
Chef::Log.info(resource.network_interfaces)
