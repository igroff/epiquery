# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  config.vm.box = "precise64_virtualbox"


  config.vm.provider "virtualbox" do |v|
    v.name = 'epiquery'
  end

  config.vm.network "forwarded_port", guest: 9000, host: 9001
  config.vm.network "forwarded_port", guest: 7070, host: 7070



  config.vm.provision "shell", inline: "cd /vagrant/epiquery; sudo apt-get update; sudo apt-get -y install make curl git; sudo make"

  config.vm.synced_folder "./", "/vagrant/epiquery"
end
