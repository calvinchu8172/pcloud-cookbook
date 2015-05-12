require 'resolv'

template '/etc/hosts' do
  source "hosts.erb"
  mode "0644"
  variables(
    :localhost_name => node[:opsworks][:instance][:hostname],
    :nodes => search(:node, "name:*"),
    :fake_xmpp_server => node['pcloud_settings']['bots']['fake_xmpp_server'] 
  )
end
