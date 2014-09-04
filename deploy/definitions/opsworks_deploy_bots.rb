define :opsworks_deploy_bots do
  application = params[:app]
  deploy = params[:deploy_data]

  # Setting-up & Running fluentd
  fluentd_s3 = deploy['fluentd']['s3']

  # initialize fluentd config
  execute "fluentd -s" do
    user 'root'
    not_if 'test -d /etc/fluent'
  end

  # generate our own fluent.conf
  template "/etc/fluent/fluent.conf" do
    source "fluent.conf.erb"
    cookbook 'deploy'
    mode "0644"
    group 'root'
    owner 'root'
    variables({
      :s3_key => fluentd_s3['key_id'], 
      :s3_secret_key => fluentd_s3['secret_key'],
      :s3_bucket => fluentd_s3['bucket'],
      :s3_log_path => fluentd_s3['log_path']
    })
  end

  # start fluentd
  execute "fluentd -d /var/run/fluentd.pid" do
    user 'root'
    not_if 'test -f /var/run/fluentd.pid'
  end

  # Bots Configurations
  unless node['xmpp_config'].nil?
    override[:deploy]['personal_cloud_bots']['god']['xmpp_config'] = node['xmpp_config']
  end

  bots_config_db = deploy['db']

  template "#{deploy[:deploy_to]}/shared/config/bot_db_config.yml" do
    source "bot_db_config.yml.erb"
    cookbook 'deploy'
    mode "0644"
    group deploy[:group]
    owner deploy[:user]
    variables({
      :db_host => bots_config_db['host'],
      :db_socket => bots_config_db['socket'],
      :db_name => bots_config_db['name'],
      :db_userid => bots_config_db['userid'],
      :db_userpw => bots_config_db['userpw']
    })
  end

  bots_config_mail = deploy['mail']

  template "#{deploy[:deploy_to]}/shared/config/bot_mail_config.yml" do
    source "bot_mail_config.yml.erb"
    cookbook 'deploy'
    mode "0644"
    group deploy[:group]
    owner deploy[:user]
    variables({
      :mail_key_id => bots_config_mail['key_id'],
      :mail_access_key => bots_config_mail['access_key'],
      :mail_region => bots_config_mail['region'],
      :mail_domain => bots_config_mail['domain']
    })
  end

  bots_config_queue = deploy['queue']

  template "#{deploy[:deploy_to]}/shared/config/bot_queue_config.yml" do
    source "bot_queue_config.yml.erb"
    cookbook 'deploy'
    mode "0644"
    group deploy[:group]
    owner deploy[:user]
    variables({
      :queue_key_id => bots_config_queue['key_id'],
      :queue_access_key => bots_config_queue['access_key'],
      :queue_region => bots_config_queue['region'],
      :queue_name => bots_config_queue['name']
    })
  end

  bots_config_route = deploy['route']

  template "#{deploy[:deploy_to]}/shared/config/bot_route_config.yml" do
    source "bot_route_config.yml.erb"
    cookbook 'deploy'
    mode "0644"
    group deploy[:group]
    owner deploy[:user]
    variables({
      :route_key_id => bots_config_route['key_id'],
      :route_access_key => bots_config_route['access_key'],
      :route_reserved_hosts => bots_config_route['reserved_hosts'],
      :route_zones => bots_config_route['zones']
    })
  end

  bots_config_god = deploy['god']
  #bots_config_god['xmpp_config'] = node['xmpp_config'] unless node['xmpp_config'].nil?

  template "#{deploy[:deploy_to]}/shared/config/god_config.yml" do
    source "god_config.yml.erb"
    cookbook 'deploy'
    mode "0644"
    group deploy[:group]
    owner deploy[:user]
    variables({
      :god_path => "#{deploy[:current_path]}/",
      :god_xmpp_config => bots_config_god['xmpp_config'],
      :god_mail_domain => bots_config_god['mail_domain'],
      :god_mail_user => bots_config_god['mail_user'],
      :god_mail_pw => bots_config_god['mail_pw'],
      :god_notify_list => bots_config_god['notify_list']
    })
  end

  # Run God monitor & Bots
  execute "launch bots" do
    command "god terminate; god -c #{deploy[:current_path]}/bot.god"
  end
end
