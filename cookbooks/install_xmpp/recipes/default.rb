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
