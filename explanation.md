YOLO E-Commerce — Explanation

## Overview

This document explains the YOLO E-Commerce application ,a MERN-stack sample app composed of three microservices: frontend, backend (Node/Express) and database (MongoDB). 

The project is containerized with Docker and orchestrated using Docker Compose.


## Table of Contents

1. [Project Overview](#project-overview)
2. [Architecture Explanation](#architecture-explanation)
3. [Docker Concepts Applied](#docker-concepts-applied)
4. [Step-by-Step Implementation](#step-by-step-implementation)
5. [Dockerfile Explanations](#dockerfile-explanations)
6. [Docker Compose Breakdown](#docker-compose-breakdown)
7. [Network Configuration](#network-configuration)
8. [Volume Management](#volume-management)
9. [Environment Variables](#environment-variables)
10. [Testing and Verification](#testing-and-verification)
11. [Troubleshooting Guide](#troubleshooting-guide)
12. [Lessons Learned](#lessons-learned)

---

## Project Overview

### What is YOLO?

YOLO is a full-stack e-commerce web application that allows users to browse and add fashion products. The application demonstrates modern microservices architecture using containerization.

### Technology Stack

- **Frontend:** React.js (served by Nginx in production)
- **Backend:** Node.js with Express.js
- **Database:** MongoDB 5.0
- **Containerization:** Docker & Docker Compose
- **Registry:** DockerHub

### Project Goals

1. Containerize a multi-tier application
2. Implement microservices architecture
3. Demonstrate data persistence
4. Apply Docker best practices
5. Deploy to container registry

---

## Architecture Explanation

### Three-Tier Architecture
```
┌─────────────────────────────────────────────────┐
│            Docker Network (Bridge)              │
│                (yolo-network)                   │
│                                                 │
│  ┌──────────────┐   ┌──────────────┐          │
│  │   Frontend   │   │   Backend    │          │
│  │  (Nginx:80)  │──▶│  (Node:5000) │──┐       │
│  │              │   │              │  │       │
│  └──────────────┘   └──────────────┘  │       │
│        ▲                                │       │
│        │ HTTP (Port 3000)              │       │
│        │                                ▼       │
│        │                         ┌──────────┐  │
│        │                         │ Database │  │
│        │                         │(Mongo:   │  │
│        └─────────────────────────│  27017)  │  │
│                                  └─────┬────┘  │
│                                        │       │
│                                        ▼       │
│                                   ┌─────────┐  │
│                                   │ Volume  │  │
│                                   │ (Data)  │  │
│                                   └─────────┘  │
└─────────────────────────────────────────────────┘
```

### Component Interactions

1. **User → Frontend:** Browser requests served by Nginx on port 3000
2. **Frontend → Backend:** API calls to Node.js backend on port 5000
3. **Backend → Database:** MongoDB connection on port 27017
4. **Database → Volume:** Data persisted to Docker volume

---

## Docker Concepts Applied

### 1. **Multi-Stage Builds**

Multi-stage builds reduce final image size by separating build and runtime environments.

**Benefits:**
- Smaller production images
- Faster deployment
- Reduced attack surface
- Cost-effective storage

**Example:** Frontend goes from ~300MB to ~40MB!

### 2. **Base Image Selection**

**Why Alpine?**
- Minimal size (~5MB base)
- Security focused
- Package manager (apk)
- Wide compatibility

**Images Used:**
- `node:18-alpine` - Build stage
- `nginx:alpine` - Frontend production
- `mongo:5.0` - Database (official)

### 3. **Layer Caching**

Docker caches layers to speed up builds.

**Strategy:**
```dockerfile
COPY package*.json ./    # Changes rarely
RUN npm install          # Cached unless package.json changes
COPY . .                 # Changes frequently
```

### 4. **Networks**

Custom bridge networks enable:
- Container name resolution (DNS)
- Isolated communication
- Network segmentation

### 5. **Volumes**

Named volumes provide:
- Data persistence
- Independent lifecycle
- Backup capability
- Performance benefits

### 6. **Health Checks**

Monitor container health automatically:
- Restart unhealthy containers
- Prevent traffic to failing services
- Production reliability

---

## Step-by-Step Implementation

### Phase 1: Project Setup
```bash
# Clone repository
git clone https://github.com/username/yolo.git
cd yolo

# Create environment file
cp .env.sample .env
```

### Phase 2: Backend Containerization
```bash
# Create backend/Dockerfile
# Build image
docker build -t yolo-backend:test ./backend

# Test image
docker run -p 5000:5000 yolo-backend:test
```

### Phase 3: Frontend Containerization
```bash
# Create client/Dockerfile
# Build image
docker build -t yolo-client:test ./client

# Test image
docker run -p 3000:80 yolo-client:test
```

### Phase 4: Compose Orchestration
```bash
# Create docker-compose.yml
# Build all services
docker-compose build

# Start application
docker-compose up -d

# Verify running
docker-compose ps
```

### Phase 5: Testing
```bash
# Add products through UI
# Stop containers
docker-compose down

# Restart
docker-compose up -d

# Verify data persists
```

### Phase 6: Deployment
```bash
# Tag images
docker tag yolo-backend username/yolo-backend:v1.0
docker tag yolo-client username/yolo-client:v1.0

# Push to DockerHub
docker push username/yolo-backend:v1.0
docker push username/yolo-client:v1.0
```

---

## Dockerfile Explanations

### Backend Dockerfile Breakdown
```dockerfile
# Stage 1: Build Stage
FROM node:18-alpine AS build
```
**Purpose:** Use Node 18 Alpine as build environment
**Why:** Small size, modern Node version, compatibility
```dockerfile
WORKDIR /app
COPY package*.json ./
RUN npm ci --omit=dev
```
**Purpose:** Install only production dependencies
**Why:** Reduces image size, faster installs, security
```dockerfile
# Stage 2: Production Stage
FROM node:18-alpine AS production
COPY --from=build /app/node_modules ./node_modules
```
**Purpose:** Copy only necessary files from build stage
**Why:** Minimizes final image size
```dockerfile
USER node
```
**Purpose:** Run as non-root user
**Why:** Security best practice, limits potential damage
```dockerfile
CMD ["node", "server.js"]
```
**Purpose:** Start the Node.js server
**Why:** Defines container entry point

### Frontend Dockerfile Breakdown
```dockerfile
# Stage 1: Build React App
FROM node:18-alpine AS build
RUN npm run build
```
**Purpose:** Compile React app to static files
**Why:** Optimizes for production, removes source code
```dockerfile
# Stage 2: Serve with Nginx
FROM nginx:alpine AS production
COPY --from=build /app/build /usr/share/nginx/html
```
**Purpose:** Use Nginx to serve static files
**Why:** 
- Extremely efficient (~40MB vs ~300MB)
- Production-grade server
- Better performance
- No Node.js needed in production

---

## Docker Compose Breakdown

### Service: Database
```yaml
database:
  image: mongo:5.0
  volumes:
    - mongodb-data:/data/db
```

**Explanation:**
- Uses official MongoDB 5.0 image
- Named volume ensures data survives container restarts
- Mount point `/data/db` is MongoDB's default data directory
```yaml
healthcheck:
  test: echo 'db.runCommand("ping").ok' | mongosh localhost:27017/test --quiet
```

**Purpose:** Verify MongoDB is responding
**Benefit:** Other services wait for database to be ready

### Service: Backend
```yaml
backend:
  build:
    context: ./backend
    args:
      buildversion: "1.0"
  image: username/yolo-backend:v1.0
```

**Explanation:**
- Builds from local Dockerfile
- Tags with DockerHub username
- Passes build version as argument
```yaml
depends_on:
  database:
    condition: service_healthy
```

**Purpose:** Wait for database health check before starting
**Benefit:** Prevents connection errors

### Service: Frontend
```yaml
frontend:
  ports:
    - "3000:80"
```

**Explanation:**
- Maps host port 3000 to container port 80 (nginx)
- Allows access via http://localhost:3000

---

## Network Configuration

### Custom Bridge Network
```yaml
networks:
  yolo-network:
    driver: bridge
```

**What is it?**
A user-defined bridge network for container communication.

**Why use it?**
1. **Automatic DNS:** Containers can reach each other by name
   - Backend connects to `mongodb://database:27017`
   - No need for IP addresses

2. **Isolation:** Only containers on this network can communicate

3. **Better control:** Custom network settings

**Example Usage in Backend:**
```javascript
// server.js
mongoose.connect('mongodb://database:27017/yolo_db')
// 'database' resolves to the database container's IP
```

---

## Volume Management

### Named Volume
```yaml
volumes:
  mongodb-data:
    driver: local
```

**What is it?**
A named volume managed by Docker for persistent storage.

**Why use it?**
1. **Data Persistence:** Survives container deletion
2. **Easy Backup:** Can be backed up separately
3. **Performance:** Better than bind mounts
4. **Portability:** Works across different hosts

**Verification:**
```bash
# List volumes
docker volume ls

# Inspect volume
docker volume inspect mongodb-data

# See where data is stored
docker volume inspect mongodb-data | grep Mountpoint
```

**Testing Persistence:**
```bash
# Add data through application
# Stop and remove containers
docker-compose down

# Start again
docker-compose up -d

# Data still exists! ✅
```

---

## Environment Variables

### Why Use .env Files?

1. **Security:** Sensitive data not in code
2. **Flexibility:** Easy to change per environment
3. **Portability:** Same code, different configs

### Our .env File
```bash
MONGO_INITDB_ROOT_USERNAME=admin
MONGO_INITDB_ROOT_PASSWORD=securepassword123
MONGO_INITDB_DATABASE=yolo_db
MONGODB_URI=mongodb://admin:securepassword123@database:27017/yolo_db?authSource=admin
```

**Usage in docker-compose.yml:**
```yaml
environment:
  MONGO_INITDB_ROOT_USERNAME: ${MONGO_INITDB_ROOT_USERNAME}
```

**Usage in Backend Code:**
```javascript
mongoose.connect(process.env.MONGODB_URI)
```

---

## Testing and Verification

### Build Tests
```bash
# Test 1: Build backend individually
docker build -t test-backend ./backend
# Expected: Success, ~200MB

# Test 2: Build frontend individually  
docker build -t test-frontend ./client
# Expected: Success, ~40MB

# Test 3: Build with compose
docker-compose build
# Expected: All services build successfully
```

### Runtime Tests
```bash
# Test 1: All containers running
docker-compose ps
# Expected: 3 containers "Up"

# Test 2: Backend responds
curl http://localhost:5000
# Expected: Response (even if error, means it's running)

# Test 3: Frontend accessible
curl http://localhost:3000
# Expected: HTML content

# Test 4: Database connection
docker exec yolo-backend node -e "console.log('Connected')"
# Expected: No connection errors in logs
```

### Persistence Tests
```bash
# Test data persistence
# 1. Open http://localhost:3000
# 2. Add a product
# 3. docker-compose down
# 4. docker-compose up -d
# 5. Product still visible ✅
```

### Network Tests
```bash
# Test container can reach database by name
docker exec yolo-backend ping database -c 2
# Expected: Successful ping

# Test network isolation
docker network inspect yolo-network
# Expected: All 3 containers listed
```

---

## Troubleshooting Guide

### Issue 1: "Cannot connect to MongoDB"

**Symptoms:**
```
MongoNetworkError: failed to connect to server
```

**Solutions:**
```bash
# Check database is running
docker-compose ps database

# Check database logs
docker-compose logs database

# Verify connection string in .env
cat .env | grep MONGODB_URI

# Ensure backend is on same network
docker inspect yolo-backend | grep NetworkMode
```

### Issue 2: "Port already in use"

**Symptoms:**
```
Error: bind: address already in use
```

**Solutions:**
```bash
# Find what's using the port
sudo lsof -i :3000
sudo lsof -i :5000

# Kill the process
sudo kill -9 <PID>

# Or change port in docker-compose.yml
ports:
  - "3001:80"  # Use different host port
```

### Issue 3: "Frontend shows 'Cannot reach backend'"

**Solutions:**
```bash
# Check backend is running
docker-compose ps backend

# Check backend logs for errors
docker-compose logs backend

# Verify REACT_APP_API_URL
# Should be: http://localhost:5000

# Test backend directly
curl http://localhost:5000
```

### Issue 4: "npm install fails in Dockerfile"

**Symptoms:**
```
npm ERR! network
npm ERR! errno ENOTFOUND
```

**Solutions:**
```bash
# Check internet connection
ping google.com

# Try building with --no-cache
docker-compose build --no-cache

# Check package.json exists
ls backend/package.json
ls client/package.json

# Verify COPY command in Dockerfile
```

### Issue 5: "Data doesn't persist"

**Solutions:**
```bash
# Check volume is created
docker volume ls | grep mongodb

# Check volume is mounted
docker inspect yolo-database | grep Mounts -A 10

# Verify volume in docker-compose.yml
# Should have:
volumes:
  - mongodb-data:/data/db
```

---

## Lessons Learned

### Docker Best Practices Applied

1. **Multi-Stage Builds**
   - Reduced frontend from 300MB to 40MB
   - Separated build and runtime concerns

2. **Alpine Base Images**
   - Minimized security vulnerabilities
   - Faster downloads and deployments

3. **Layer Optimization**
   - Proper COPY order for cache efficiency
   - Reduced build times significantly

4. **Security Measures**
   - Non-root users in containers
   - Environment variables for secrets
   - Network isolation

5. **Health Checks**
   - Automatic restart of failed containers
   - Proper service dependencies

### Challenges Overcome

1. **Node Version Compatibility**
   - **Problem:** Package.json specified old Node 13
   - **Solution:** Removed engines restriction, upgraded to Node 18

2. **Permission Errors**
   - **Problem:** npm couldn't write files as node user
   - **Solution:** Added `chown -R node:node /app` before USER directive

3. **Frontend Size**
   - **Problem:** 300MB image with Node.js
   - **Solution:** Multi-stage build with nginx (40MB)

4. **Network Communication**
   - **Problem:** Backend couldn't find database
   - **Solution:** Custom bridge network with DNS resolution

### Key Takeaways

1. **Planning Matters:** Architecture design before implementation
2. **Incremental Development:** Build → Test → Commit → Repeat
3. **Documentation:** Essential for debugging and collaboration
4. **Image Size:** Matters for deployment speed and costs
5. **Testing:** Verify at each stage, not just at the end

---

## Image Optimization Results

### Before Optimization

| Service | Original Size | Issues |
|---------|---------------|--------|
| Backend | ~400MB | Full Node.js + all dependencies |
| Frontend | ~300MB | Node.js serving React in dev mode |
| **Total** | **~700MB** | Too large! |

### After Optimization

| Service | Optimized Size | Improvements |
|---------|----------------|--------------|
| Backend | ~200MB | Multi-stage, production deps only |
| Frontend | ~40MB | Nginx serving static build |
| **Total** | **~240MB** | **66% reduction!** ✅ |

### Optimization Techniques Used

1. Multi-stage builds
2. Alpine base images
3. Production dependencies only (`--omit=dev`)
4. Nginx for static file serving
5. Proper .dockerignore files
6. Build caching optimization

---

## Future Improvements

1. **CI/CD Pipeline**
   - Automated builds on git push
   - Automated testing
   - Automated deployment

2. **Security Enhancements**
   - Docker secrets instead of .env
   - Image vulnerability scanning
   - Network policies

3. **Performance**
   - Redis caching layer
   - Load balancing
   - CDN for static assets

4. **Monitoring**
   - Prometheus metrics
   - Grafana dashboards
   - Logging aggregation

5. **Scalability**
   - Kubernetes orchestration
   - Horizontal pod autoscaling
   - Database replication

---

## References

- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [MongoDB Docker Hub](https://hub.docker.com/_/mongo)
- [Nginx Alpine](https://hub.docker.com/_/nginx)
- [Node.js Best Practices](https://github.com/goldbergyoni/nodebestpractices)

---

## Conclusion

This project successfully demonstrates:
- ✅ Containerization of a multi-tier application
- ✅ Microservices architecture implementation
- ✅ Docker best practices and optimization
- ✅ Data persistence with volumes
- ✅ Network isolation and communication
- ✅ Production-ready deployment


The YOLO e-commerce application is now fully containerized, optimized, and ready for production deployment!

---

## What this repo contains

- `client/` — This is React frontend (served at port 8080 by default in this project)

- `backend/` — Node/Express API (serves REST endpoints, usually port 5000)

- `database/` — Dockerfile and configuration for MongoDB

- `docker-compose.yaml` — Compose setup to build and bring up all services together at once

- `README.md` — project README (overview, instructions and how to build microservices from scratch)

> NB: You can verify filenames and exact port numbers in `docker-compose.yaml`, `backend/server.js`, and `client/package.json`.

## Architecture (high level)

- Client -> Backend  | Backend -> MongoDB 

This separation allows independent builds and scaling of each service.

## Prerequisites
As outlined in the README, the following are the requirements for running this project

- [Docker](https://www.docker.com/get-started)

- [Docker compose](https://docs.docker.com/compose/install/)

- [Git](https://git-scm.com/)

## Environment variables

Copy `.env.sample` to `.env` (or create `.env`) in the project root and populate required values. Typical vars used for the MongoDB service and backend include:

```bash
MONGO_INITDB_ROOT_USERNAME=admin
MONGO_INITDB_ROOT_PASSWORD=example
MONGO_INITDB_DATABASE=dbname
BACKEND_PORT=5000
CLIENT_PORT=8080
```

Adjust these values and key to match `docker-compose.yaml` and the services' Dockerfiles (backend)

## Quick start (local, Docker Compose)

1. Build and start all services (from the root directory):

```bash
docker-compose up --build
```

2. Run in detached mode:

```bash
docker-compose up -d --build
```

3. Stop and remove containers, networks and volumes:

```bash
docker-compose down -v
```

4. View logs:

```bash
docker-compose logs -f
```

5. to view last 50 logs

```bash
docker-compose logs -f --tail 50
```
## Useful image build test

Before you push to Dockerhub, build each images for test separately:

```bash
docker build -t yolo-client_test_image:v1.0.0 ./client
docker build -t yolo-backend_test_image:v1.0.0./backend
docker build -t yolo-db_test_image:v1.0.0 ./database
```

## Common troubleshooting

- Port conflicts: 
ensure ports used by services (e.g., 8080, 5000, 27017) are free.

- MongoDB authentication: 
confirm `MONGO_INITDB_ROOT_USERNAME` and `MONGO_INITDB_ROOT_PASSWORD` in the `.env` match what's referenced in the backend `MONGODB_URI`.

- MongoDB Connection Fails Inside Docker:
When starting the backend container, you may see this error in the logs:

```bash
MongoServerSelectionError: connect ECONNREFUSED 127.0.0.1:27017
```

or 

```bash
MongoCompatibilityError: Server at pmc-yolo-database:27017 reports maximum wire version 3, but this version of the Node.js Driver requires at least 8 (MongoDB 4.2)
```

1. To fix this, Use the Docker service name as the hostname in your `.env` file and make sure both containers share the same network.

2. Version incompatibility between MongoDB and the Node.js drive: To fix this you can upgrage or downgrade mongoose.


- Persistent data: If data is unexpectedly missing, ensure volumes are configured correctly in `docker-compose.yaml`.


## Author & License

Author: [Jacob Taraya](https://github.com/jtaraya)

The original project was forked from [yolo](https://github.com/Vinge1718/yolo).
