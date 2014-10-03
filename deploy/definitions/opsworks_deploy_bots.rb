require 'json'

define :opsworks_deploy_bots do
  application = params[:app]
  deploy = params[:deploy_data]
  bots_settings = node['pcloud_settings']['bots']

  # Setting-up & Running fluentd
  fluentd_s3 = bots_settings['fluentd']['s3']

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
      :db_userpw => bots_config_db['userpw']
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

  bots_instances_data_s3 = bots_settings['instances']['s3']

  execute "load bot instances data from S3" do
    user "#{deploy[:user]}"
    cwd "#{deploy[:deploy_to]}/shared/config/"
    command <<-EOH
      AWS_ACCESS_KEY_ID=#{bots_instances_data_s3['key_id']} \
      AWS_SECRET_ACCESS_KEY=#{bots_instances_data_s3['secret_key']} \
      aws s3 cp s3://#{bots_instances_data_s3['bucket']}/bots/bots.json bots.json --region 'us-east-1'
    EOH
  end

  bots_instances = JSON.load(File.open("#{deploy[:deploy_to]}/shared/config/bots.json", "r"))
  node_bots_instances = bots_instances[node[:opsworks][:instance][:hostname]]

  bots_config_god = bots_settings['god']

  #xmpp_config = node['xmpp_config'].nil? ? bots_config_god['xmpp_config'] : node['xmpp_config']

  template "#{deploy[:deploy_to]}/shared/config/god_config.yml" do
    source "god_config.yml.erb"
    cookbook 'deploy'
    mode "0644"
    group deploy[:group]
    owner deploy[:user]
    variables({
      :god_path => "#{deploy[:current_path]}/",
      :god_xmpp_config => node_bots_instances,
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

  # Run God monitor & Bots
  execute "launch bots" do
    command "god terminate; god -c #{deploy[:current_path]}/bot.god"
  end
end
