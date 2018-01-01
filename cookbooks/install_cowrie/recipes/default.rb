include_recipe 'poise-python::default'

package "git"
package "net-tools"

group 'cowrie' do
  action :create
  gid '9999'
  append true
end

user 'cowrie' do
  comment 'start cowrie up'
  manage_home true
  uid '9999'
  group 'cowrie'
  home '/home/cowrie'
  shell '/bin/bash'
  password '$1$JJsvHslasdfjVEroftprNn4JHtDi'
end

git "/home/cowrie/honeypot" do
  repository "https://github.com/micheloosterhof/cowrie.git"
  reference "master"
  user 'cowrie'
  action :sync
end

python_execute '-m pip install virtualenv' do 
    python '/usr/local/bin/python2.7'
end


bash 'mysql_changepasswd' do
   code <<-EOH
   export myPass="`grep 'temporary password' /var/log/mysqld.log | cut -d\  -f11 | tr '\n' ' ' | sed \"s/ //g\"`"
   mysqladmin --user=root --password="${myPass}" password "#{node['mysql']['rootPassword']}"
   EOH
   not_if { ::Dir.exist?("/var/lib/mysql/cowrie")}
   notifies :run, 'execute[mysql_insecure]', :immediately
end

execute 'mysql_insecure' do
   command "mysql --user=root --password=#{node['mysql']['rootPassword']} -e \"UNINSTALL PLUGIN validate_password;\""
   notifies :run, 'execute[mysql_grant]', :immediately
   action :nothing
end

execute 'mysql_grant' do
   command "echo \"CREATE DATABASE cowrie; GRANT ALL ON cowrie.* TO cowrie@localhost IDENTIFIED BY 'cowrie';\" | mysql -u root --password=#{node['mysql']['rootPassword']}"
   action :nothing
   notifies :run, 'execute[mysql_query]', :immediately
end

execute 'mysql_query' do
   command "echo \"use cowrie;source /home/cowrie/honeypot/doc/sql/mysql.sql;\" | mysql -u cowrie -p cowrie"
   action :nothing
end

python_execute '-m pip install mysql' do 
    python '/usr/local/bin/python2.7'
end

python_virtualenv '/opt/cowrie/' do
  python '/usr/local/bin/python2.7'
end

pip_requirements '/home/cowrie/honeypot/requirements.txt' do
  virtualenv '/opt/cowrie/'
end
cookbook_file '/home/cowrie/honeypot/bin/cowrie' do
  source 'cowrie'
  force_unlink true
  owner 'cowrie'
  group 'cowrie'
  mode '0755'
  action :create
end
cookbook_file '/home/cowrie/honeypot/cowrie.cfg' do
  source 'cowrie.cfg'
  owner 'cowrie'
  group 'cowrie'
  mode '0755'
  action :create
end

execute "python cowrie" do
        user 'cowrie'
	ENV['PATH'] = ENV['PATH'] + ":/opt/rh/rh-mysql57/root/usr/bin/"
	command '/home/cowrie/honeypot/bin/cowrie restart'
end
