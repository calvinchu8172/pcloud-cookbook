#
# Cookbook Name:: personal-cloud-cookbooks
# Recipe:: packages
#
# Copyright (C) 2014 Huei-Horng Yo
#
# All rights reserved - Do Not Redistribute
#
package "imagemagick" do
  action :install
end

case node[:platform]
when "ubuntu","debian"
  package "imagemagick" do
    action :install
  end
when "centos"
  package "imagemagick" do
    action :install
  end
end
