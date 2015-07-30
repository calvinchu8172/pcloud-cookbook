if (node[:opsworks][:instance][:hostname] == "rails-app1" && node[:opsworks][:instance][:layers].include?("rails-app"))
  rails_env = node[:deploy]['personal_cloud_portal'][:rails_env]
  app_path = node[:deploy]['personal_cloud_portal']['current_path']

  Chef::Log.info("Assign DDNS expiration cron job on #{node[:opsworks][:instance][:hostname]} (cwd: #{app_path})")

  execute "run whenever" do
    user 'deploy'
    cwd app_path
    command "RAILS_ENV=#{rails_env} bundle exec whenever --update-crontab --set 'environment=#{rails_env}&path=#{app_path}'"
  end
end
