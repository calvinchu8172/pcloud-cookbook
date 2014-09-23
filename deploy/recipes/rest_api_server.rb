include_recipe 'deploy'

node[:deploy].each do |application, deploy|

  if deploy[:application_type] != 'rails' && deploy[:application] != 'personal_cloud_rest_api'
    Chef::Log.debug("Skipping deploy::rails application #{application} as it is neither a Rails app nor Personal Cloud REST API Server")
    next
  end

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
end

