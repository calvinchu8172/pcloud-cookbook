# project specific settings (which override defaults)
normal[:rails][:max_pool_size] = 20
## Personal Cloud Portal
normal[:deploy]['personal_cloud_portal'][:symlink_before_migrate]['config/mailer.yml'] = 'config/mailer.yml'
normal[:deploy]['personal_cloud_portal'][:symlink_before_migrate]['config/secrets.yml'] = 'config/secrets.yml'
normal[:deploy]['personal_cloud_portal'][:symlink_before_migrate]['config/settings.production.yml'] = 'config/settings/production.yml'

## Personal Cloud Bots
normal[:deploy]['personal_cloud_bots']['fluentd']['s3']['key_id'] = 'AKIAIFBA53YARL2VHDWQ'
normal[:deploy]['personal_cloud_bots']['fluentd']['s3']['secret_key'] = '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'
normal[:deploy]['personal_cloud_bots']['fluentd']['s3']['bucket'] = 'ecowork-demo'
normal[:deploy]['personal_cloud_bots']['fluentd']['s3']['log_path'] = 'personal-cloud-bot-log/'
