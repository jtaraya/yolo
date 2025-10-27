# -*- mode: ruby -*-
# vi: set ft=ruby :
Vagrant.configure("2") do |config|
  # Use Jeff Geerling's Ubuntu 20.04 box (no auth keys needed)
  config.vm.box = "geerlingguy/ubuntu2004"
  config.vm.box_version = "1.0.4"
  
  # Set hostname
  config.vm.hostname = "yolo-app"
  
  # Port forwarding for all services
  config.vm.network "forwarded_port", guest: 3000, host: 3000, id: "frontend"
  config.vm.network "forwarded_port", guest: 5000, host: 5000, id: "backend"
  config.vm.network "forwarded_port", guest: 27017, host: 27017, id: "mongodb"
  
  # VirtualBox VM configuration
  config.vm.provider "virtualbox" do |vb|
    vb.name = "yolo-ecommerce-vm"
    vb.memory = "2048"
    vb.cpus = 2
  end
  
  # Provision with Ansible (runs inside VM)
  config.vm.provision "ansible_local" do |ansible|
    ansible.playbook = "playbook.yml"
    ansible.verbose = true
    ansible.install = true
    ansible.install_mode = "pip"
    ansible.pip_install_cmd = "sudo apt-get install -y python3-pip && sudo pip3 install ansible"
    ansible.compatibility_mode = "2.0"
  end
end
