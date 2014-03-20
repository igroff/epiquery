# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  config.vm.box = "epiquery"
  config.vm.box_url = "http://files.vagrantup.com/precise64_vmware.box"


  config.vm.provider "virtualbox" do |v|
    v.name = 'epiquery'
  end


  config.vm.network "forwarded_port", guest: 9000, host: 9001
  config.vm.network "forwarded_port", guest: 7070, host: 7071


  config.vm.synced_folder "./", "/vagrant/epiquery"

  config.vm.provision "shell", inline: "cd /vagrant/epiquery; sudo apt-get update; sudo apt-get -y install make curl git; make"

end
