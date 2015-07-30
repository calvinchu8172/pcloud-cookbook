if (node[:opsworks][:instance][:hostname] == "rails-app1" && node[:opsworks][:instance][:layers].include?("rails-app"))
  Chef::Log.info("Assign DDNS expiration cron job on #{node[:opsworks][:instance][:hostname]}")
  Chef::Log.info("#{node[:deploy]}")

  #execute "run whenever" do
    #command "bundle exec whenever --update-crontab --set 'environment=staging'"
  #end
end
