#
# Cookbook Name:: pcloud-appserver
# Recipe:: default
#
# Copyright (C) 2014 YOUR_NAME
#
# All rights reserved - Do Not Redistribute
#

package "imagemagick" do
  action :install
end

case node[:platform]
when "ubuntu","debian"
  package "libmagickwand-dev" do
    action :install
  end
when "centos"
  package "ImageMagick-devel" do
    action :install
  end
end
