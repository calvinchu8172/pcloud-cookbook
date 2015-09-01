include_recipe "deploy"

application = 'personal_cloud_rest_api'
deploy = node[:deploy][application]
rest_api_server_settings = node['pcloud_settings']['rest-api-server']

rails_env = node[:deploy][application][:rails_env]

execute "restart Rails app #{application}" do
  user 'deploy'
  cwd deploy[:current_path]
  command node[:opsworks][:rails_stack][:restart_command]
  action :nothing
end

mailer_settings = rest_api_server_settings['mailer']

template "#{deploy[:deploy_to]}/shared/config/mailer.yml" do
  source "mailer.yml.erb"
  cookbook 'rest-api'
  mode "0660"
  group deploy[:group]
  owner deploy[:user]
  variables({
    :delivery_method => mailer_settings['delivery_method'],
    :smtp_settings => mailer_settings['smtp_settings'],
    :default => mailer_settings['default'],
    :default_url_options => mailer_settings['default_url_options']
  })

  notifies :run, "execute[restart Rails app #{application}]"

  only_if do
    File.directory?("#{deploy[:deploy_to]}/shared/config/")
  end
end

environments_settings = rest_api_server_settings['environment']

['production', 'staging'].each do |environment|
  template "#{deploy[:deploy_to]}/shared/config/settings.#{environment}.yml" do
    source "#{environment}.yml.erb"
    cookbook 'rest-api'
    mode "0660"
    group deploy[:group]
    owner deploy[:user]
    variables({
      :api => environments_settings['api'],
      :xmpp => environments_settings['xmpp'],
      :environments => environments_settings['environments'],
      :oauth => environments_settings['oauth'],
      :recaptcha => environments_settings['recaptcha'],
      :redis => environments_settings['redis']
    })

    notifies :run, "execute[restart Rails app #{application}]"

    only_if do
      File.directory?("#{deploy[:deploy_to]}/shared/config/")
    end
  end
end

databases_settings = rest_api_server_settings['databases']

template "#{deploy[:deploy_to]}/shared/config/database.yml" do
  source "database.yml.erb"
  cookbook 'rest-api'
  mode "0660"
  group deploy[:group]
  owner deploy[:user]
  variables({
    :databases => databases_settings
  })

  notifies :run, "execute[restart Rails app #{application}]"

  only_if do
    File.directory?("#{deploy[:deploy_to]}/shared/config/")
  end
end

sidekiq_pid = `ps -ef | grep "sidekiq.*busy" | grep -v grep | awk '{print $2}'`.strip

if sidekiq_pid.empty?
  execute "start sidekiq directly" do
    cwd deploy[:current_path]
    user deploy[:user]
    command "RAILS_ENV=#{rails_env} bundle exec sidekiq -d -C #{deploy[:current_path]}/config/sidekiq.yml"
  end
else
  execute "kill then restart sidekiq" do
    cwd deploy[:current_path]
    user deploy[:user]
    command "kill #{sidekiq_pid} && RAILS_ENV=#{rails_env} bundle exec sidekiq -d -C #{deploy[:current_path]}/config/sidekiq.yml"
  end
end
