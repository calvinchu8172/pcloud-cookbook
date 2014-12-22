#
# Cookbook Name:: service_pack
# Recipe:: 20141222-upgrade-ntpd
#
# Copyright (C) 2014 Huei-Horng Yo <hiroshiyui@ecoworkinc.com>
#
# All rights reserved - Do Not Redistribute
#

# Ref: https://ics-cert.us-cert.gov/advisories/ICSA-14-353-01

# remove ntp
execute "apparmor_parser -R /etc/apparmor.d/usr.sbin.ntpd" do
end

package "ntp" do
  action :purge
end

# install openntpd instead of 'original' ntp
package "openntpd" do
  action :install
end
