# Append MongooseIM name record(s) in /etc/hosts
require 'resolv'

exit unless node[:opsworks][:instance][:layers].include?("bot")

# pick up a MongooseIM instance
mongooseim_instance = node[:opsworks][:layers]['mongooseim'][:instances].keys.first
mongooseim_ip = node[:opsworks][:layers]['mongooseim'][:instances][mongooseim_instance]['ip']
mongooseim_name = node['pcloud_settings']['mongooseim']['vhost']

template '/etc/hosts' do
  source "hosts.erb"
  mode "0644"
  variables(
    :localhost_name => node[:opsworks][:instance][:hostname],
    :nodes => search(:node, "name:*"),
    :ip => mongooseim_ip,
    :name => mongooseim_name
  )
end
