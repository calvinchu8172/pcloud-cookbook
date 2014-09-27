include_recipe "deploy"

node[:deploy].each do |application, deploy|
  deploy = node[:deploy][application]
  portalapp_settings = node['pcloud_settings']['portalapp']

  execute "restart Rails app #{application}" do
    user 'deploy'
    cwd deploy[:current_path]
    command node[:opsworks][:rails_stack][:restart_command]
    action :nothing
  end

  node.default[:deploy][application][:database][:adapter] = OpsWorks::RailsConfiguration.determine_database_adapter(application, node[:deploy][application], "#{node[:deploy][application][:deploy_to]}/current", :force => node[:force_database_adapter_detection])
  deploy = node[:deploy][application]

  mailer_settings = portalapp_settings['mailer']['production']

  template "#{deploy[:deploy_to]}/shared/config/mailer.yml" do
    source "mailer.yml.erb"
    cookbook 'portalapp'
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

  template "#{deploy[:deploy_to]}/shared/config/settings.production.yml" do
    source "production.yml.erb"
    cookbook 'portalapp'
    mode "0660"
    group deploy[:group]
    owner deploy[:user]

    notifies :run, "execute[restart Rails app #{application}]"

    only_if do
      File.directory?("#{deploy[:deploy_to]}/shared/config/")
    end
  end
end
