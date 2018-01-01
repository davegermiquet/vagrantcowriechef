#
# Cookbook:: installpython
# Recipe:: default
#
# Copyright:: 2017, The Authors, All Rights Reserved.
node['python']['build-deps'].each do |name|
  package "#{name}"
end 

remote_file "/usr/src/Python-#{node['python']['pythonversion']}.tgz" do
  source "https://www.python.org/ftp/python/#{node['python']['pythonversion']}/Python-#{node['python']['pythonversion']}.tgz"
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end


tar_extract "/usr/src/Python-#{node['python']['pythonversion']}.tgz"  do
  action :extract_local
  target_dir "/usr/src/"
  creates "/usr/src/Python-#{node['python']['pythonversion']}/demo"
end

execute 'configure python' do
  cwd "/usr/src/Python-#{node['python']['pythonversion']}"
  command './configure --enable-optimizations'
  not_if { ::File.exist?('/usr/local/bin/python2.7')}
end
execute 'make python' do
  cwd "/usr/src/Python-#{node['python']['pythonversion']}"
  command 'make altinstall'
  not_if { ::File.exist?('/usr/local/bin/python2.7')}
end

remote_file "/usr/src/Python-#{node['python']['pythonversion']}/get-pip.py" do
  source "https://bootstrap.pypa.io/get-pip.py"
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end

execute 'download get_pip' do
cwd "/usr/src/Python-#{node['python']['pythonversion']}"
  command '/usr/local/bin/python2.7 get-pip.py'
  not_if { ::File.exist?('/usr/local/bin/pip2.7')}
end
