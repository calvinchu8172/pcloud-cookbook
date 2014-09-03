define :opsworks_deploy_bots do
  application = params[:app]
  deploy = params[:deploy_data]

  template "/etc/fluent/fluent.conf" do
    source "fluent.conf.erb"
    cookbook 'deploy'
    mode "0644"
    group 'root'
    owner 'root'
    variables({
      :s3_key => '',
      :s3_secret_key => '',
      :s3_bucket => '',
      :s3_log_path => ''
    })
  end
end
