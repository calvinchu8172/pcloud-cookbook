include_recipe "deploy"

application = 'personal_cloud_findme'
deploy = node[:deploy][application]
findme_settings = node['pcloud_settings']['findme']

execute "restart Rails app #{application}" do
  user 'deploy'
  cwd deploy[:current_path]
  command node[:opsworks][:rails_stack][:restart_command]
  action :nothing
end

['production', 'development' ,'staging'].each do |environment|
  template "#{deploy[:deploy_to]}/shared/config/settings.#{environment}.yml" do
    source "settings.yml.erb"
    cookbook 'findme'
    mode "0660"
    group deploy[:group]
    owner deploy[:user]
    variables({
      :environments => findme_settings['environments'],
      :redis => findme_settings['redis']
    })

    notifies :run, "execute[restart Rails app #{application}]"

    only_if do
      File.directory?("#{deploy[:deploy_to]}/shared/config/")
    end
  end
end

cookbook_file "#{deploy[:deploy_to]}/shared/config/database.yml" do
  source 'database.yml'
  mode "0660"
  cookbook 'findme'
  group deploy[:group]
  owner deploy[:user]

  notifies :run, "execute[restart Rails app #{application}]"

  only_if do
    File.directory?("#{deploy[:deploy_to]}/shared/config/")
  end
end



template "/etc/monit/conf.d/" + application + "_unicorn_master.monitrc" do
  mode '0400'
  owner 'root'
  group 'root'
  source "rails_service.monitrc.erb"
  variables(:deploy => deploy, :application => application)
end

service "monit" do
  action :restart
end
