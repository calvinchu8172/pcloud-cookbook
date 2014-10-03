include_recipe "deploy"

application = 'personal_cloud_rest_api'
deploy = node[:deploy][application]
rest_api_server_settings = node['pcloud_settings']['rest-api-server']

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

production_settings = rest_api_server_settings['production']

['production', 'staging'].each do |environment|
  template "#{deploy[:deploy_to]}/shared/config/settings.#{environment}.yml" do
    source "#{environment}.yml.erb"
    cookbook 'rest-api'
    mode "0660"
    group deploy[:group]
    owner deploy[:user]
    variables({
      :magic_number => production_settings['magic_number'],
      :xmpp => production_settings['xmpp'],
      :environments => production_settings['environments'],
      :version => production_settings['version'],
      :oauth => production_settings['oauth'],
      :recaptcha => production_settings['recaptcha'],
      :redis => production_settings['redis']
    })

    notifies :run, "execute[restart Rails app #{application}]"

    only_if do
      File.directory?("#{deploy[:deploy_to]}/shared/config/")
    end
  end
end

#staging_settings = rest_api_server_settings['staging']

#template "#{deploy[:deploy_to]}/shared/config/settings.staging.yml" do
  #source "staging.yml.erb"
  #cookbook 'rest-api'
  #mode "0660"
  #group deploy[:group]
  #owner deploy[:user]
  #variables({
    #:magic_number => staging_settings['magic_number'],
    #:xmpp => staging_settings['xmpp'],
    #:environments => staging_settings['environments'],
    #:version => staging_settings['version'],
    #:oauth => staging_settings['oauth'],
    #:recaptcha => staging_settings['recaptcha'],
    #:redis => staging_settings['redis']
  #})

  #notifies :run, "execute[restart Rails app #{application}]"

  #only_if do
    #File.directory?("#{deploy[:deploy_to]}/shared/config/")
  #end
#end

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
