#
# Cookbook Name:: server
# Recipe:: default
#
# Copyright (C) 2014 YOUR_NAME
#
# All rights reserved - Do Not Redistribute
#

#include_recipe 'mysql::client_install'

package "imagemagick" do
  action :install
end

case node[:platform]
when "ubuntu","debian"
  package "libmagickwand-dev" do
    action :install
  end
  package "libsqlite3-dev" do
    action :install
  end
when "centos"
  package "ImageMagick-devel" do
    action :install
  end
  package "sqlite-devel" do
    action :install
  end
end

package "nodejs" do
  action :install
end

package "npm" do
  action :install
end

bash 'install_bower' do
  code <<-EOH
    npm install -g bower
  EOH
end

bash 'alias_nodejs' do
  code <<-EOH
    ln -s /usr/bin/nodejs /usr/bin/node
  EOH
  not_if { ::File.exists?('/usr/bin/node') }
end
