define :opsworks_deploy_bots do
  application = params[:app]
  deploy = params[:deploy_data]
  fluentd_s3 = deploy['fluentd']['s3']

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

  execute "fluentd -d /var/run/fluentd.pid" do
    user 'root'
  end
end
