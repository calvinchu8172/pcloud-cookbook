
ssl_vendor_settings = node['ssl']['certificates']['vendors']

ssl_vendor_settings['list'].each do |vendor| 

	# create vendor's ca certificate directory
	directory "#{vendor['certpath']}" do
	  owner 'root'
	  group 'root'
	  action :create
	  recursive true
	end

	execute "load vendor's ssl certificate from S3" do
	  user "root"
	  cwd "#{vendor['certpath']}"
	  command <<-EOH
	    aws s3 cp s3://#{ssl_vendor_settings['s3_bucket']}/certificates/vendors/#{vendor['name']}/#{vendor['certfile']} \
	    #{vendor['certfile']} --region 'us-east-1'
	  EOH

	  #not_if "test -f #{vendor['certpath']}#{vendor['certfile']}"
	end

end

execute "update ca certificates" do
	user "root"
	command "update-ca-certificates"
end
