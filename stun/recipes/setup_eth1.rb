gem_package "aws-sdk" do
  action :install
end

require 'aws-sdk-core'

env "AWS_REGION" do
  value "us-east-1"
end
