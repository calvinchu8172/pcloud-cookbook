# project specific settings (which override defaults)
normal[:rails][:max_pool_size] = 20

## Personal Cloud Portal
normal[:deploy]['personal_cloud_portal'][:rake] = 'rake'
normal[:deploy]['personal_cloud_portal'][:symlink_before_migrate]['config/mailer.yml'] = 'config/mailer.yml'
normal[:deploy]['personal_cloud_portal'][:symlink_before_migrate]['config/settings.production.yml'] = 'config/settings/production.yml'
normal[:deploy]['personal_cloud_portal'][:symlink_before_migrate]['config/settings.staging.yml'] = 'config/settings/staging.yml'

## Personal Cloud REST API Server
normal[:deploy]['personal_cloud_rest_api'][:rake] = 'rake'
normal[:deploy]['personal_cloud_rest_api'][:symlink_before_migrate]['config/mailer.yml'] = 'config/mailer.yml'
normal[:deploy]['personal_cloud_rest_api'][:symlink_before_migrate]['config/settings.production.yml'] = 'config/settings/production.yml'
normal[:deploy]['personal_cloud_rest_api'][:symlink_before_migrate]['config/settings.staging.yml'] = 'config/settings/staging.yml'

# Make symbolic links
normal[:deploy]['personal_cloud_bots'][:symlink_before_migrate]['config/bot_db_config.yml'] = 'config/bot_db_config.yml'
normal[:deploy]['personal_cloud_bots'][:symlink_before_migrate]['config/bot_mail_config.yml'] = 'config/bot_mail_config.yml'
normal[:deploy]['personal_cloud_bots'][:symlink_before_migrate]['config/bot_queue_config.yml'] = 'config/bot_queue_config.yml'
normal[:deploy]['personal_cloud_bots'][:symlink_before_migrate]['config/bot_redis_config.yml'] = 'config/bot_redis_config.yml'
normal[:deploy]['personal_cloud_bots'][:symlink_before_migrate]['config/bot_route_config.yml'] = 'config/bot_route_config.yml'
normal[:deploy]['personal_cloud_bots'][:symlink_before_migrate]['config/god_config.yml'] = 'config/god_config.yml'
