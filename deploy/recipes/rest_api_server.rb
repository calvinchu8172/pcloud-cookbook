include_recipe 'deploy'

application = 'personal_cloud_rest_api'
deploy = node[:deploy][application]

opsworks_deploy_dir do
  user deploy[:user]
  group deploy[:group]
  path deploy[:deploy_to]
end

opsworks_rails do
  deploy_data deploy
  app application
end

opsworks_deploy_rest_api_server do
  deploy_data deploy
  app application
end
