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
	command '/home/cowrie/honeypot/bin/cowrie start'
end
