#
# Cookbook Name:: service_pack
# Recipe:: 20141225-revert-to-and-upgrade-ntpd
#
# Copyright (C) 2014 Huei-Horng Yo <hiroshiyui@ecoworkinc.com>
#
# All rights reserved - Do Not Redistribute
#

# ref: http://www.ubuntu.com/usn/usn-2537-1/

execute 'apt-get update' do
  action :run
end

package "libssl1.0.0" do
  action :upgrade
end
