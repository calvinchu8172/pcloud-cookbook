require 'json'

define :opsworks_deploy_bots do
  application = params[:app]
  deploy = params[:deploy_data]
  bots_settings = node['pcloud_settings']['bots']

  xmpp_config = node['pcloud_settings']['mongooseim']

  template "#{deploy[:deploy_to]}/shared/config/bot_xmpp_db_config.yml" do
    source "bot_xmpp_db_config.yml.erb"
    cookbook 'deploy'
    mode "0644"
    group deploy[:group]
    owner deploy[:user]
    variables({
      :db_host => xmpp_config['auth_method']['host'],
      :db_socket => '',
      :db_name => xmpp_config['auth_method']['database'],
      :db_userid => xmpp_config['auth_method']['username'],
      :db_userpw => xmpp_config['auth_method']['password'],
      :db_pool => xmpp_config['auth_method']['pool_size']
    })
  end

  # Bots Configurations
  bots_config_db = bots_settings['db']

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
      :db_userpw => bots_config_db['userpw'],
      :db_pool => bots_config_db['pool']
    })
  end

  bots_config_mail = bots_settings['mail']

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
      :mail_domain => bots_config_mail['domain'],
      :mail_smtp_host => bots_config_mail['smtp_host'],
      :mail_smtp_port => bots_config_mail['smtp_port'],
      :mail_smtp_user => bots_config_mail['smtp_user'],
      :mail_smtp_password => bots_config_mail['smtp_password']
    })
  end

  bots_config_queue = bots_settings['queue']

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

  bots_config_route = bots_settings['route']

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

  bots_config_god = bots_settings['god']

  template "#{deploy[:deploy_to]}/shared/config/god_config.yml" do
    source "god_config.yml.erb"
    cookbook 'deploy'
    mode "0644"
    group deploy[:group]
    owner deploy[:user]
    variables({
      :god_path => "#{deploy[:current_path]}/",
      :god_xmpp_config => bots_config_god['ec2_instances'][node[:opsworks][:instance][:hostname]],
      :god_xmpp_domain => xmpp_config['vhost'], 
      :god_xmpp_resource => bots_config_god['xmpp']['resource'],
      :god_mail_domain => bots_config_god['mail_domain'],
      :god_mail_user => bots_config_god['mail_user'],
      :god_mail_pw => bots_config_god['mail_pw'],
      :god_notify_list => bots_config_god['notify_list']
    })
  end

  bots_config_redis = bots_settings['redis']

  template "#{deploy[:deploy_to]}/shared/config/bot_redis_config.yml" do
    source "bot_redis_config.yml.erb"
    cookbook 'deploy'
    mode "0644"
    group deploy[:group]
    owner deploy[:user]
    variables({
      :redis_host => bots_config_redis['host']
    })
  end

  bots_revision = `cd #{deploy[:current_path]} && git rev-parse HEAD`.strip
  Chef::Log.info("Launching Bots revision #{bots_revision}")

  # Run God monitor & Bots
  execute "terminate god" do
    cwd "#{deploy[:current_path]}"
    command "god terminate"
    only_if 'ps -ef | grep god | grep -v grep'
  end

  execute "launch bots" do
    cwd "#{deploy[:current_path]}"
    command "god -c #{deploy[:current_path]}/bot.god"
  end
end
