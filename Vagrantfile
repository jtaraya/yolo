# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "geerlingguy/ubuntu2004"
  config.vm.box_version = "1.0.4"
  
  config.vm.hostname = "yolo-app"
  
  # Updated Port Forwarding (avoiding collisions)
  config.vm.network "forwarded_port", guest: 3000, host: 3000, id: "frontend"
  config.vm.network "forwarded_port", guest: 5000, host: 5001, id: "backend"     # Changed: 5000 → 5001
  config.vm.network "forwarded_port", guest: 27017, host: 27017, id: "mongodb"
  
  config.vm.provider "virtualbox" do |vb|
    vb.name = "yolo-ecommerce-vm"
    vb.memory = "2048"
    vb.cpus = 2
  end
  
  config.vm.provision "ansible_local" do |ansible|
    ansible.playbook = "playbook.yml"
    ansible.verbose = true
    ansible.install = true
    ansible.install_mode = "pip"
    ansible.compatibility_mode = "2.0"
  end
end