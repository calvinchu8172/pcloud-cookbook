# project specific settings (which override defaults)
normal[:opsworks][:rails][:ignore_bundler_groups] = []
normal[:deploy]['personal_cloud_portal'][:symlink_before_migrate]['config/mailer.yml'] = 'config/mailer.yml'
normal[:deploy]['personal_cloud_portal'][:symlink_before_migrate]['config/secrets.yml'] = 'config/secrets.yml'
normal[:deploy]['personal_cloud_portal'][:symlink_before_migrate]['config/settings.production.yml'] = 'config/settings/production.yml'
