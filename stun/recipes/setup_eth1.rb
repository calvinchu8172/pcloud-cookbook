gem_package "aws-sdk" do
  action :install
end

ENV['AWS_REGION'] = "us-east-1"

Chef::Log.info("Ooooops!")
