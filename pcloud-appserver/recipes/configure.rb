#
# Cookbook Name:: pcloud-appserver
# Recipe:: default
#
# Copyright (C) 2014 YOUR_NAME
#
# All rights reserved - Do Not Redistribute
#
include_recipe "deploy"

node[:deploy].each do |application, deploy|
  deploy = node[:deploy][application]

  #cookbook_file "/srv/www/personal_cloud_portal/current/config/mailer.yml" do
    #source "mailer.yml"
    #mode 0644
    #action :create_if_missing
  #end

  template "#{deploy[:deploy_to]}/shared/config/mailer.yml" do
    source "mailer.yml.erb"
    cookbook 'pcloud-appserver'
    mode "0660"
    group deploy[:group]
    owner deploy[:user]

    notifies :run, "execute[restart Rails app #{application}]"

    only_if do
      File.directory?("#{deploy[:deploy_to]}/shared/config/")
    end
  end

  #template "#{deploy[:deploy_to]}/shared/config/database.yml" do
    #source "database.yml.erb"
    #cookbook 'rails'
    #mode "0660"
    #group deploy[:group]
    #owner deploy[:user]
    #variables(:database => deploy[:database], :environment => deploy[:rails_env])

    #notifies :run, "execute[restart Rails app #{application}]"

    #only_if do
      #deploy[:database][:host].present? && File.directory?("#{deploy[:deploy_to]}/shared/config/")
    #end
  #end

  #template "#{deploy[:deploy_to]}/shared/config/memcached.yml" do
    #source "memcached.yml.erb"
    #cookbook 'rails'
    #mode "0660"
    #group deploy[:group]
    #owner deploy[:user]
    #variables(
      #:memcached => deploy[:memcached] || {},
      #:environment => deploy[:rails_env]
    #)

    #notifies :run, "execute[restart Rails app #{application}]"

    #only_if do
      #deploy[:memcached][:host].present? && File.directory?("#{deploy[:deploy_to]}/shared/config/")
    #end
  #end
end

