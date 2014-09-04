# project specific settings (which override defaults)
normal[:rails][:max_pool_size] = 20
## Personal Cloud Portal
normal[:deploy]['personal_cloud_portal'][:symlink_before_migrate]['config/mailer.yml'] = 'config/mailer.yml'
normal[:deploy]['personal_cloud_portal'][:symlink_before_migrate]['config/secrets.yml'] = 'config/secrets.yml'
normal[:deploy]['personal_cloud_portal'][:symlink_before_migrate]['config/settings.production.yml'] = 'config/settings/production.yml'

## Personal Cloud Bots
# fluentd
normal[:deploy]['personal_cloud_bots']['fluentd']['s3']['key_id'] = 'AKIAIFBA53YARL2VHDWQ'
normal[:deploy]['personal_cloud_bots']['fluentd']['s3']['secret_key'] = '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'
normal[:deploy]['personal_cloud_bots']['fluentd']['s3']['bucket'] = 'ecowork-demo'
normal[:deploy]['personal_cloud_bots']['fluentd']['s3']['log_path'] = 'personal-cloud-bot-log/'
# database
normal[:deploy]['personal_cloud_bots']['db']['host'] = 'test12345.cjfxj7dznwce.ap-northeast-1.rds.amazonaws.com'
normal[:deploy]['personal_cloud_bots']['db']['socket'] = ''
normal[:deploy]['personal_cloud_bots']['db']['name'] = 'personal_cloud'
normal[:deploy]['personal_cloud_bots']['db']['userid'] = 'root'
normal[:deploy]['personal_cloud_bots']['db']['userpw'] = '12345678'
# SES?
normal[:deploy]['personal_cloud_bots']['mail']['key_id'] = 'AKIAIOKGDAZ2CJ7QW3HQ'
normal[:deploy]['personal_cloud_bots']['mail']['access_key'] = 'CzT3ufnkS85CfbPEF/3Z5n2B7TWmTS8Bbw+9VX1Q'
normal[:deploy]['personal_cloud_bots']['mail']['region'] = 'us-west-2'
normal[:deploy]['personal_cloud_bots']['mail']['domain'] = 'pcloud.ecoworkinc.com'
# SQS
normal[:deploy]['personal_cloud_bots']['queue']['key_id'] = 'AKIAIFBA53YARL2VHDWQ'
normal[:deploy]['personal_cloud_bots']['queue']['access_key'] = 'vaCdIwOTtYbTFVwoSyXpVAzfexg63pndLwZmsXQe'
normal[:deploy]['personal_cloud_bots']['queue']['region'] = 'us-east-1'
normal[:deploy]['personal_cloud_bots']['queue']['name'] = 'personal_cloud1'
# Route 53
#normal[:deploy]['personal_cloud_bots']['route']
# God monitor
#normal[:deploy]['personal_cloud_bots']['god']
# Make symbolic links
normal[:deploy]['personal_cloud_bots'][:symlink_before_migrate]['config/bot_db_config.yml'] = 'config/bot_db_config.yml'
normal[:deploy]['personal_cloud_bots'][:symlink_before_migrate]['config/bot_mail_config.yml'] = 'config/bot_mail_config.yml'
normal[:deploy]['personal_cloud_bots'][:symlink_before_migrate]['config/bot_queue_config.yml'] = 'config/bot_queue_config.yml'
