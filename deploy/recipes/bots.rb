include_recipe 'deploy'

node[:deploy].each do |application, deploy|
  Chef::Log.info("#{application.inspect}")
  Chef::Log.info("#{deploy.inspect}")
  Chef::Log.info("#{node.inspect}")

  # NOTICE: Remember to set your App's name exactly to 'Personal Cloud Bots'
  #
  # Ensure if we are dealing with Personal Cloud Bots app:
  if deploy[:application] != 'personal_cloud_bots'
    # skip it
    next
  end

  opsworks_deploy_dir do
    user deploy[:user]
    group deploy[:group]
    path deploy[:deploy_to]
  end

  opsworks_deploy do
    deploy_data deploy
    app application
  end

  opsworks_deploy_bots do
    # send application & deploy object as parameters to 
    # ../definitions/opsworks_deploy_bots.rb
    deploy_data deploy
    app application
  end

end
