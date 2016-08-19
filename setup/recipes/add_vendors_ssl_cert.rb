
ssl_vendor_settings = node['ssl']['certificates']['vendors']

ssl_vendor_settings['list'].each do |vendor| 

	# create vendor's ca certificate directory
	directory "#{ssl_vendor_settings['certpath']}" do
	  owner 'root'
	  group 'root'
	  action :create
	  recursive true
	end

	execute "load vendor's ssl certificate from S3" do
	  user "root"
	  cwd "#{vendor['certpath']}"
	  command <<-EOH
	    AWS_ACCESS_KEY_ID=#{ssl_vendor_settings['s3_access_key']} \
	    AWS_SECRET_ACCESS_KEY=#{ssl_vendor_settings['s3_secret_key']} \
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

  # "ssl": {
  #   "certificates": {
  #     "vendors": {
  #       "s3_bucket": "pcloud-alpha"
  #       "s3_access_key": "AKIAJGCMN2ELYNJUS4WQ",
  #       "s3_secret_key": "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",
  #       "list": [
  #         {
  #           "name": "asi"
  #           "certpath": "/usr/local/share/ca-certificates/asicloud.aethersi.com/"
  #           "certfile": "asi-ssl-alpha.crt"
  #         }
  #       ]
  #     }
  #   }
  # },