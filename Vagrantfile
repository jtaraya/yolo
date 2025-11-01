# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  # Ubuntu 20.04 box
  config.vm.box = "geerlingguy/ubuntu2004"
  config.vm.box_version = "1.0.4"
  
  # Synced folder for accessing files
  config.vm.synced_folder ".", "/vagrant_data"

  # VM Resources
  config.vm.provider "virtualbox" do |vb|
    vb.name = "ansible-vm-jtaraya"
    vb.memory = "2048"
    vb.cpus = 2
  end

  # Forward ports for accessing services
  config.vm.network "forwarded_port", guest: 80, host: 8080, auto_correct: true    # Frontend
  config.vm.network "forwarded_port", guest: 5000, host: 5000, auto_correct: true  # Backend
  config.vm.network "forwarded_port", guest: 27017, host: 27017, auto_correct: true # MongoDB

  # Provision with Ansible
  config.vm.provision "ansible" do |ansible|
    ansible.playbook = "playbook.yml"
    ansible.inventory_path = "inventory.yml"
    ansible.become = true
    ansible.limit = "all"
    ansible.verbose = "v"
  end
end