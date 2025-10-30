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
  
  # Install Ansible using Python (comes pre-installed)
  config.vm.provision "shell", inline: <<-SHELL
    # Python3 is already installed, just install pip via Python
    python3 -m pip install --user ansible 2>/dev/null || true
    # Make sure ansible is in PATH
    export PATH="~/.local/bin:$PATH"
  SHELL
  
  # Then run playbook
  config.vm.provision "ansible_local" do |ansible|
    ansible.playbook = "ansible/playbook.yml"
    ansible.inventory_path = "ansible/inventory"
    ansible.verbose = true
    ansible.install = false
  end
end