if (node[:opsworks][:instance][:hostname] == "rails-app1" && node[:opsworks][:instance][:layers].include?("rails-app"))
  rails_env = node[:deploy]['personal_cloud_portal'][:rails_env]
  app_path = node[:deploy]['personal_cloud_portal']['current_path']

  Chef::Log.info("Assign DDNS expiration cron job on #{node[:opsworks][:instance][:hostname]} (cwd: #{app_path})")

  cron "ddns expiration" do
    minute '0'
    hour '2'
    user 'deploy'
    path "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games"
    command "/bin/bash -l -c 'cd #{app_path} && RAILS_ENV=#{rails_env} bundle exec rake ddns_expire:cronjob --silent >> /dev/null 2>&1'"
  end
end
