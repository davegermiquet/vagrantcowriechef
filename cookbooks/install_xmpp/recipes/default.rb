#
# Cookbook:: install_xmpp
# Recipe:: default
#
# Copyright:: 2017, The Authors, All Rights Reserved.

cookbook_file '/tmp/ejabber.rpm' do
  source 'ejabberd-17.12-0.x86_64.rpm'
  owner 'vagrant'
  group 'vagrant'
  mode '0755'
  action :create_if_missing
end

pkg_path = '/tmp/ejabber.rpm'

rpm_package pkg_path do
  action :install
end

cookbook_file '/opt/ejabberd/conf/ejabberd.yml' do
  source 'ejabberd.yml'
  owner 'ejabberd'
  group 'ejabberd'
  mode '0755'
  action :create
end

cookbook_file '/opt/ejabberd/conf/ejabberdctl.cfg' do
  source 'ejabberdctl.cfg'
  owner 'ejabberd'
  group 'ejabberd'
  mode '0755'
  action :create
end

execute 'mysql_grant_ejabber' do
    command  "echo \"CREATE DATABASE ejabberd;GRANT ALL ON ejabberd.* TO 'ejabberd'@'localhost' IDENTIFIED BY 'ejabberd';\" | mysql -u root --password=#{node['mysql']['rootPassword']}"
   not_if { ::Dir.exist?("/var/lib/mysql/ejabberd")}
   notifies :run, 'execute[mysql_query_ejabber]', :immediately
end

execute 'mysql_query_ejabber' do
   command "echo \"use ejabberd;source /opt/ejabberd-17.12/lib/ejabberd-17.12/priv/sql/mysql.sql;\" | mysql -u ejabberd --password=ejabberd"
   action :nothing
end

execute 'moveservicefile'  do
  command "cp /opt/ejabberd-17.12/bin/ejabberd.service /etc/systemd/system"
  notifies :run, 'execute[systemctl]', :immediately
end

execute 'systemctl'  do 
  command "systemctl daemon-reload"
  notifies :run, 'execute[startService]', :immediately
  action :nothing
end

execute 'startService'  do 
  command "systemctl start ejabberd"
  notifies :run, 'execute[AddUser]', :immediately
  action :nothing
end

execute 'AddUser' do
  command "/opt/ejabberd-17.12/bin/ejabberdctl register admin cowrie.com changeme"
  action :nothing
end

service 'ejabberd'  do
   action :restart
end

