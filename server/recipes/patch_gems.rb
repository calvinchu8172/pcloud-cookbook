#
# Cookbook Name:: server
# Recipe:: default
#
# Copyright (C) 2014 YOUR_NAME
#
# All rights reserved - Do Not Redistribute
#
Chef::Log.info("Home? #{ENV['HOME']}")
Chef::Log.info("Deploy Home? #{deploy[:home]}")
Chef::Log.info("Gem Home? #{ENV['GEM_HOME']}")
