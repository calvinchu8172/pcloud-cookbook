include_recipe 'deploy'

node[:deploy].each do |application, deploy|
  Chef::Log.info("#{application.inspect}")
  Chef::Log.info("#{deploy.inspect}")

  # NOTICE: Remember to set your App's name to 'Personal Cloud Bots'
  if deploy[:application] == 'personal_cloud_bots'
    opsworks_deploy_dir do
      user deploy[:user]
      group deploy[:group]
      path deploy[:deploy_to]
    end

    opsworks_deploy_bots do
      # send application & deploy object as parameters to 
      # ../definitions/opsworks_deploy_bots.rb
      deploy_data deploy
      app application
    end
  end
end
