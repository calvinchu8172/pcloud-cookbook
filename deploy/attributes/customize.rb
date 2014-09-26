# project specific settings (which override defaults)
normal[:rails][:max_pool_size] = 20

## Personal Cloud Portal
normal[:deploy]['personal_cloud_portal'][:symlink_before_migrate]['config/mailer.yml'] = 'config/mailer.yml'
normal[:deploy]['personal_cloud_portal'][:symlink_before_migrate]['config/settings.production.yml'] = 'config/settings/production.yml'

## Personal Cloud REST API Server
normal[:deploy]['personal_cloud_rest_api'][:symlink_before_migrate]['config/mailer.yml'] = 'config/mailer.yml'
normal[:deploy]['personal_cloud_rest_api'][:symlink_before_migrate]['config/settings.production.yml'] = 'config/settings/production.yml'

## Personal Cloud Bots
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
normal[:deploy]['personal_cloud_bots']['route']['key_id'] = 'AKIAIFBA53YARL2VHDWQ'
normal[:deploy]['personal_cloud_bots']['route']['access_key'] = 'vaCdIwOTtYbTFVwoSyXpVAzfexg63pndLwZmsXQe'
normal[:deploy]['personal_cloud_bots']['route']['reserved_hosts'] = ['api', 'www', 'dns', 'ddns', 'upnp', 'blog', 'zyxel', 'store', 'host', 'support', 'service', 'services']
normal[:deploy]['personal_cloud_bots']['route']['zones'] = [
  {'id' => 'Z1SL2C2LT75LT2', 'name' => 'demo.ecoworkinc.com.'}
]
# God monitor
normal[:deploy]['personal_cloud_bots']['god']['xmpp_config'] = [
  {'jid' => 'bot99@xmpp.pcloud.ecoworkinc.com/robot', 'pw' => '12345'},
  {'jid' => 'bot100@xmpp.pcloud.ecoworkinc.com/robot', 'pw' => '12345'}
]
normal[:deploy]['personal_cloud_bots']['god']['mail_domain'] = 'pcloud.ecoworkinc.com'
normal[:deploy]['personal_cloud_bots']['god']['mail_user'] = 'AKIAIN64R4K6P6VHET5A'
normal[:deploy]['personal_cloud_bots']['god']['mail_pw'] = 'Atccdco0f1YKXFNtMHJfFe23C5ZXdihlea3OL66AQBEF'
normal[:deploy]['personal_cloud_bots']['god']['notify_list'] = [
  {'name' => 'clshang', 'email' => 'clshang@ecoworkinc.com'}
]
# Make symbolic links
normal[:deploy]['personal_cloud_bots'][:symlink_before_migrate]['config/bot_db_config.yml'] = 'config/bot_db_config.yml'
normal[:deploy]['personal_cloud_bots'][:symlink_before_migrate]['config/bot_mail_config.yml'] = 'config/bot_mail_config.yml'
normal[:deploy]['personal_cloud_bots'][:symlink_before_migrate]['config/bot_queue_config.yml'] = 'config/bot_queue_config.yml'
normal[:deploy]['personal_cloud_bots'][:symlink_before_migrate]['config/bot_route_config.yml'] = 'config/bot_route_config.yml'
normal[:deploy]['personal_cloud_bots'][:symlink_before_migrate]['config/god_config.yml'] = 'config/god_config.yml'
