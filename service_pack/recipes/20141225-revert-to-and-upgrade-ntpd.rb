#
# Cookbook Name:: service_pack
# Recipe:: 20141225-revert-to-and-upgrade-ntpd
#
# Copyright (C) 2014 Huei-Horng Yo <hiroshiyui@ecoworkinc.com>
#
# All rights reserved - Do Not Redistribute
#

execute 'apt-get update' do
  action :run
end

package "openntpd" do
  action :purge
end

package "ntp" do
  action :install
end

