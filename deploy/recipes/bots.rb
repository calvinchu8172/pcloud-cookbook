include_recipe 'deploy'

node[:deploy].each do |application, deploy|
  Chef::Log.info("#{application.inspect}")
  Chef::Log.info("#{deploy.inspect}")
end
