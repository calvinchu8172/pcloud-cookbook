require 'aws-sdk'

ENV['AWS_REGION'] = "us-east-1"

Chef::Log.info("Setup a secondary NIC with an Elastic IP address")

resource = Aws::EC2::Resource.new
Chef::Log.info(resource.network_interfaces)
