# project specific settings (which override defaults)
normal[:rails][:max_pool_size] = 20
## Personal Cloud Portal
normal[:deploy]['personal_cloud_portal'][:symlink_before_migrate]['config/mailer.yml'] = 'config/mailer.yml'
normal[:deploy]['personal_cloud_portal'][:symlink_before_migrate]['config/secrets.yml'] = 'config/secrets.yml'
normal[:deploy]['personal_cloud_portal'][:symlink_before_migrate]['config/settings.production.yml'] = 'config/settings/production.yml'

## Personal Cloud Bots
normal[:deploy]['personal_cloud_bots']['fluentd']['s3']['key_id'] = ''
normal[:deploy]['personal_cloud_bots']['fluentd']['s3']['secret_key'] = ''
normal[:deploy]['personal_cloud_bots']['fluentd']['s3']['bucket'] = ''
normal[:deploy]['personal_cloud_bots']['fluentd']['s3']['log_path'] = ''
