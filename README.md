# Overview
This project involved the containerization and deployment of a full-stack yolo application using Docker.


# Requirements
Install the docker engine here:
- [Docker](https://docs.docker.com/engine/install/) 

## How to launch the application 


![Alt text](image.png)

## How to run the app
Use vagrant up --provison command

# E-Commerce Microservice Application

## Project Overview
This is a containerized e-commerce application built with:
- **FrontEnd**: React application
- **Backend** : Node.js/Express API
- **Database** : MongoDB

## Prerequisites
- Docker Desktop installed
- Docker Compose Installed
- DockerHub account

## Architecture
This application uese a microservices architecture with  3 main services:
1. FrontEnd Service (React)
2. BackEndServices (Node.js)
3. Database services (MongoDB)

##Quick Start
```bash

# Build & Start all services
docker-compose up --build

# Access the App
FrontEnd : http://localhost:3000
BackEnd API : http://localhost:5000
