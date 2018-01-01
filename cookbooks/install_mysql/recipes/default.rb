#
# Cookbook:: installpython
# Recipe:: default
#
# Copyright:: 2017, The Authors, All Rights Reserved.
remote_file "/tmp/mysql57-community-release-el7-9.noarch.rpm"  do
  source "https://dev.mysql.com/get/mysql57-community-release-el7-9.noarch.rpm"
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end

rpm_package "/tmp/mysql57-community-release-el7-9.noarch.rpm" do 
end

package "mysql-server"
package "mysql-community-devel.x86_64" do 
end

service "mysqld" do
  action :enable
  action :start
end

execute "Get Password" do
   command "export mysqlpasswd=\"`grep 'temporary password' /var/log/mysqld.log | cut -d\\   -f11 | tr '\n' ' ' | sed \"s/ //g\"`\"" 
end

