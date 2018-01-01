# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|
  config.vm.box = "centos/7"
  config.vm.provision "chef_solo" do | chef|
  chef.json= { "mysql" => { "rootPassword" => "9#kShfq9890321"
			},
		"python" =>  {
			    "pythonversion" => "2.7.14",
			    "build-deps" => [ "rpm-build","redhat-rpm-config","yum-utils", "autoconf", "automake", "binutils", "bison", "flex", "gcc", "gcc-c++", "gettext", "libtool", "make", "patch", "pkgconfig", "rpm-sign" ,"openssl-devel","bzip2-devel","tar","gzip"] 
                         }
}
      chef.add_recipe "installpython"
      chef.add_recipe "install_mysql"
      chef.add_recipe "install_cowrie"
      chef.add_recipe "install_xmpp"
  end
end
