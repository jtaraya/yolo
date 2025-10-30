# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "geerlingguy/ubuntu2004"
  config.vm.box_version = "1.0.4"
  
  config.vm.hostname = "yolo-app"
  config.vm.synced_folder ".", "/vagrant", SharedFoldersEnableSymlinksCreate: false
  
  config.vm.network "forwarded_port", guest: 3000, host: 3000, id: "frontend"
  config.vm.network "forwarded_port", guest: 5000, host: 5001, id: "backend"
  config.vm.network "forwarded_port", guest: 27017, host: 27017, id: "mongodb"
  
  config.vm.provider "virtualbox" do |vb|
    vb.name = "yolo-ecommerce-vm"
    vb.memory = "2048"
    vb.cpus = 2
  end
  
  # SKIP shell provisioning - Ansible comes pre-installed on the box!
  # Just use ansible_local to run the playbook
  config.vm.provision "ansible_local" do |ansible|
    ansible.playbook = "ansible/playbook.yml"
    ansible.inventory_path = "ansible/inventory"
    ansible.verbose = true
    # Don't try to install ansible - it's already on the box!
    ansible.install = false
  end
end