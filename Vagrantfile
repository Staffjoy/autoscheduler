# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"
Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "trusty-amd64"
  config.vm.box_url = "http://cloud-images.ubuntu.com/vagrant/trusty/current/trusty-server-cloudimg-amd64-vagrant-disk1.box"
  config.vm.network :private_network, ip: "192.168.69.70"
  config.vm.synced_folder ".", "/vagrant"
  config.vm.provider :virtualbox do |vb|
    vb.customize ["modifyvm", :id, "--memory", "1500"]
    vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
  end

  config.vm.provision "shell", privileged: false, inline: "cd /vagrant/build/ && bash ubuntu-install.sh"
  # Docker for dev purposes
  config.vm.provision "shell", inline: "curl -sSL https://get.docker.com/ | sudo sh"
  config.vm.provision "shell", inline: "echo 'export JULIA_LOAD_PATH=\"/vagrant/\"' >> /etc/profile"
  config.vm.provision "shell", inline: "echo 'export ENV=\"dev\"' >> /etc/profile"

end
