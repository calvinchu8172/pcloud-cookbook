#
# Cookbook Name:: pcloud-appserver
# Recipe:: default
#
# Copyright (C) 2014 YOUR_NAME
#
# All rights reserved - Do Not Redistribute
#

cookbook_file "/srv/www/personal_cloud_portal/current/config/mailer.yml" do
  source "mailer.yml"
  mode 0644
  action :create_if_missing
end
