# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure(2) do |config|
  config.vm.box = "chef/centos-7.0"
  config.vm.network "forwarded_port", guest: 15672, host: 15672
  config.vm.network "forwarded_port", guest: 5672, host: 5672
  config.vm.network "forwarded_port", guest: 9042, host: 9042
  config.vm.network "forwarded_port", guest: 9125, host: 9125
  config.vm.network "forwarded_port", guest: 8888, host: 8888
  config.vm.provision :chef_apply do |chef|
    chef.recipe = File.read("config/chef_apply.rb")
  end
  config.vm.provider "vmware_workstation" do |vm|
    vm.vmx["memsize"] = "8192"
    vm.vmx["numvcpus"] = "8"
  end
  config.vm.provider "vmware_fusion" do |vm|
    vm.vmx["memsize"] = "8192"
    vm.vmx["numvcpus"] = "8"
  end
  config.ssh.forward_agent = true
end
