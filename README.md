# YOLO E-Commerce Application - IP3 Configuration Management

A full-stack e-commerce platform with automated Ansible provisioning and Docker containerization.

## Architecture
```
┌──────────────────────────────────┐
│  Vagrant VM (Ubuntu 20.04)       │
│                                  │
│  ┌────────────────────────────┐ │
│  │  Frontend (React/Nginx)    │ │
│  │  Port: 8080                │ │
│  └────────────────────────────┘ │
│           ▲                      │
│           │ HTTP                 │
│           ▼                      │
│  ┌────────────────────────────┐ │
│  │  Backend (Node.js/Express) │ │
│  │  Port: 5000                │ │
│  └────────────────────────────┘ │
│           ▲                      │
│           │ MongoDB URI          │
│           ▼                      │
│  ┌────────────────────────────┐ │
│  │  Database (MongoDB)        │ │
│  │  Port: 27017               │ │
│  └────────────────────────────┘ │
└──────────────────────────────────┘
```

## Prerequisites

- [Vagrant](https://www.vagrantup.com/)
- [VirtualBox](https://www.virtualbox.org/)
- [Ansible](https://www.ansible.com/)
- [Git](https://git-scm.com/)

## Quick Start

### Step 1: Clone Repository
```bash
git clone <your-repo-url>
cd yolo
```

### Step 2: Start Vagrant & Provision
```bash
vagrant up
```

This command:
- Creates Ubuntu 20.04 VM
- Installs Docker
- Creates Docker networks
- Pulls and runs containers
- All automated with Ansible!

### Step 3: SSH into VM
```bash
vagrant ssh
```

### Step 4: Verify Services
```bash
docker ps
```

You should see 3 containers running.

## Access Application

- **Frontend**: http://localhost:8080
- **Backend API**: http://localhost:5000
- **MongoDB**: localhost:27017

## Testing

## Test Each Role

# Start VM
vagrant up --no-provision

# Test common role only
ansible-playbook playbook.yml --tags common -i inventory.yml

# Verify
vagrant ssh -c "docker --version"
vagrant ssh -c "docker network ls | grep -E 'backend-db-net|frontend-backend-net'"
vagrant ssh -c "ls -la /opt/yolo/"
![alt text](<test: Common role verified - Docker installed and networks.png>)


### Test Frontend
```bash
curl http://localhost:8080
```

### Test Backend API
```bash
curl http://localhost:5000/api/products
```

### Test MongoDB
```bash
vagrant ssh
docker exec yolo-database mongosh --eval "db.adminCommand('ping')"
```

## Useful Commands
```bash
# Stop VM
vagrant halt

# Destroy VM
vagrant destroy

# Reprovision
vagrant up --provision

# SSH into VM
vagrant ssh

# View containers
vagrant ssh
docker ps
docker logs <container-name>
```

## Project Structure
```
yolo/
├── Vagrantfile
├── playbook.yml
├── inventory.yml
├── vars/
│   └── all.yml
├── roles/
│   ├── common/tasks/main.yml
│   ├── db/tasks/main.yml
│   ├── backend/tasks/main.yml
│   └── frontend/tasks/main.yml
└── README.md
```

## Ansible Roles

1. **common**: Installs Docker, creates networks, clones repo
2. **db**: Deploys MongoDB container
3. **backend**: Deploys Backend API
4. **frontend**: Deploys Frontend React app

## Key Features

✅ Automated infrastructure with Vagrant + Ansible  
✅ Pre-built Docker images from Docker Hub  
✅ Proper networking between services  
✅ Data persistence with volumes  
✅ Environment variables management  
✅ Production-ready configuration  

## Author
[Jacob Taraya](https://github.com/jtaraya) 
DevOps Engineer | Cloud & Automation Enthusiast


*Repository forked and enhanced from [Yolo](https://github.com/Vinge1718/yolo)*
