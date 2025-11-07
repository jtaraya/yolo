# YOLO E-Commerce Application - Kubernetes Orchestration Explanation

## Project Overview
This document explains the Kubernetes orchestration implementation for the YOLO e-commerce application, deployed on Google Kubernetes Engine (GKE). The YOLO application is a full-stack e-commerce platform consisting of a React frontend, Node.js/Express backend, and MongoDB database.

**Author:** [Jacob Taraya]  
**GitHub:** https://github.com/jtaraya/yolo.git  
**DockerHub:** https://hub.docker.com/u/jtaraya

---

## 1. Choice of Kubernetes Objects Used for Deployment

### 1.1 StatefulSet for MongoDB Database

**File:** `mongodb-statefulset.yaml`

I implemented a **StatefulSet** for the MongoDB database instead of a regular Deployment. This decision was made for the following critical reasons:

#### Why StatefulSet for Database?

**Stable Network Identity:**
- StatefulSets provide stable, unique network identifiers for each pod
- MongoDB pod will always have predictable DNS name: `mongodb-0.mongodb-service.default.svc.cluster.local`
- Essential for database clustering and replication in production scenarios

**Ordered, Graceful Deployment and Scaling:**
- Pods are created sequentially (mongodb-0, mongodb-1, etc.)
- Ensures data consistency during scaling operations
- Critical for database integrity

**Persistent Storage Management:**
- Each StatefulSet pod gets its own PersistentVolumeClaim (PVC)
- Storage persists even if pods are deleted or rescheduled
- Solves the assignment requirement: "deletion of database pod does not lead to loss of items"

**Configuration:**
```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: mongodb
spec:
  serviceName: "mongodb-service"  # Headless service for stable DNS
  replicas: 1
  volumeClaimTemplates:
  - metadata:
      name: mongodb-data
    spec:
      accessModes: [ "ReadWriteOnce" ]
      resources:
        requests:
          storage: 5Gi
```

#### Headless Service for StatefulSet:
```yaml
apiVersion: v1
kind: Service
metadata:
  name: mongodb-service
spec:
  clusterIP: None  # Headless service - no load balancing needed
  ports:
  - port: 27017
```

**Benefits:**
- ✅ Persistent storage survives pod restarts
- ✅ Stable network identity for database connections
- ✅ Ordered deployment ensures data safety
- ✅ Meets extra credit requirements for StatefulSets

**Alternative (Not Used):**
A regular Deployment with PersistentVolumeClaim would work but lacks:
- Stable pod naming
- Ordered deployment guarantees
- Built-in storage management per replica

---

### 1.2 Deployment for Backend API

**File:** `backend-deployment.yaml`

The backend uses a standard **Deployment** object with the following characteristics:

**Replicas:** 2
- Provides high availability for the API
- Load balances requests across multiple instances
- Enables zero-downtime updates

**Labels and Annotations:**
```yaml
metadata:
  labels:
    app: backend
    tier: api  # Helps identify application tier
```

**Environment Configuration:**
```yaml
env:
- name: MONGO_URI
  value: "mongodb://admin:password@mongodb-service:27017/yolomy?authSource=admin"
- name: PORT
  value: "5000"
```

**Health Checks:**
- **Liveness Probe:** Restarts unhealthy containers
- **Readiness Probe:** Prevents traffic to non-ready pods
- Both critical for production reliability

**Resource Management:**
```yaml
resources:
  requests:
    memory: "128Mi"
    cpu: "100m"
  limits:
    memory: "256Mi"
    cpu: "200m"
```

---

### 1.3 Deployment for Frontend

**File:** `frontend-deployment.yaml`

The React frontend also uses a **Deployment** for similar reasons:

**Key Features:**
- 2 replicas for availability
- Proper labeling (`app: frontend`, `tier: ui`)
- Environment variable for backend connection
- Health probes for reliability

**Why Deployment (not StatefulSet)?**
- Frontend is stateless (no data to persist)
- No need for stable network identity
- Benefits from flexible scheduling
- Easier to scale up/down based on traffic

---

## 2. Method Used to Expose Pods to Internet Traffic

### 2.1 Service Architecture

The application uses a **three-tier service architecture**:

#### Frontend Service - LoadBalancer (Internet-Facing)
```yaml
apiVersion: v1
kind: Service
metadata:
  name: frontend-service
spec:
  type: LoadBalancer  # Exposes to internet
  selector:
    app: frontend
  ports:
  - port: 80          # External port
    targetPort: 80  # Container port
```

**Why LoadBalancer?**
1. **Automatic External IP:** GKE provisions a Google Cloud Load Balancer
2. **Production-Ready:** Enterprise-grade load balancing
3. **Simple Configuration:** No Ingress controller needed for basic setup
4. **Health Checking:** GCP health checks ensure traffic only goes to healthy pods

**Traffic Flow:**
```
Internet User → External IP:80 → LoadBalancer → Frontend Pod:3000
```

#### Backend Service - ClusterIP (Internal Only)
```yaml
apiVersion: v1
kind: Service
metadata:
  name: backend-service
spec:
  type: ClusterIP  # Internal only
  selector:
    app: backend
  ports:
  - port: 5000
```

**Why ClusterIP?**
- Backend should NOT be directly accessible from internet
- Security best practice: only expose what's necessary
- Frontend communicates with backend internally
- Reduces attack surface

**Internal Communication:**
```
Frontend Pod → backend-service:5000 → Backend Pod:5000
```

#### MongoDB Service - Headless (StatefulSet)
```yaml
apiVersion: v1
kind: Service
metadata:
  name: mongodb-service
spec:
  clusterIP: None  # Headless
  selector:
    app: mongodb
```

**Why Headless?**
- StatefulSets need predictable DNS names
- No load balancing needed for single database instance
- Direct pod-to-pod communication
- Supports future database replication

---

### 2.2 Alternative Exposure Methods (Not Used)

**NodePort:**
- ❌ Requires accessing via `<NodeIP>:<NodePort>`
- ❌ Exposes node's IP addresses
- ❌ Limited port range (30000-32767)
- ❌ Not suitable for production

**Ingress:**
- ✅ Would enable advanced features:
  - SSL/TLS termination
  - Path-based routing
  - Domain name mapping
- ❌ Requires Ingress Controller (nginx, traefik)
- ❌ More complex for simple use case
- Future enhancement for production

---

## 3. Use of Persistent Storage

### 3.1 Implementation: PersistentVolumeClaim via StatefulSet

**Storage is implemented through StatefulSet's volumeClaimTemplates:**

```yaml
volumeClaimTemplates:
- metadata:
    name: mongodb-data
  spec:
    accessModes: [ "ReadWriteOnce" ]
    resources:
      requests:
        storage: 5Gi
    storageClassName: standard
```

#### How It Works:

**1. Automatic PVC Creation:**
When the StatefulSet creates a pod, Kubernetes automatically:
- Creates a PersistentVolumeClaim (PVC) named `mongodb-data-mongodb-0`
- Provisions a PersistentVolume (PV) from GKE's storage backend
- Binds the PVC to the PV
- Mounts the volume to the pod at `/data/db`

**2. Volume Mount:**
```yaml
volumeMounts:
- name: mongodb-data
  mountPath: /data/db  # MongoDB data directory
```

**3. Data Persistence:**
- Data stored in `/data/db` persists on Google Persistent Disk
- If pod crashes/restarts, same PVC is reattached
- If pod is deleted, PVC remains (manual deletion required)
- Shopping cart items survive pod failures

#### Storage Class: `standard`
- Uses Google Compute Engine persistent disks
- Standard performance (not SSD)
- Suitable for development/testing
- Can be upgraded to `ssd` for production

---

### 3.2 Testing Data Persistence

**Scenario:** Add items to cart → Delete MongoDB pod → Verify items still exist

**Test Commands:**
```bash
# 1. Add items to cart through the application UI

# 2. Check current MongoDB pod
kubectl get pods -l app=mongodb

# 3. Delete the MongoDB pod
kubectl delete pod mongodb-0

# 4. Watch pod recreation
kubectl get pods -l app=mongodb -w

# 5. Verify data persists
# Access application - cart items should still be there

# 6. Verify PVC exists
kubectl get pvc
# Output shows: mongodb-data-mongodb-0   Bound
```

**Result:** ✅ Items persist because data is on PersistentVolume, not in ephemeral container storage.

---

### 3.3 Why Frontend and Backend Don't Use Persistent Storage

**Frontend:**
- Stateless React application
- No data to persist
- Rebuilt on every deployment
- Uses browser localStorage for temporary client-side data

**Backend:**
- Stateless API server
- No local data storage
- All data stored in MongoDB
- Following 12-factor app principles

**Benefits of Stateless Design:**
- Easy horizontal scaling
- Simple rolling updates
- No complex volume management
- Better resource utilization

---

## 4. Git Workflow Used to Achieve the Task

### 4.1 Repository Structure

```
yolo/
├── backend/
│   ├── server.js
│   ├── package.json
│   └── Dockerfile
├── client/
│   ├── src/
│   ├── public/
│   ├── package.json
│   └── Dockerfile
├── manifests/
│   ├── mongodb-statefulset.yaml
│   ├── backend-deployment.yaml
│   └── frontend-deployment.yaml
├── .gitignore
├── README.md
└── explanation.md
```

### 4.2 Git Workflow Process

#### Initial Setup:
```bash
# Fork and clone the YOLO repository
git clone https://github.com/jtaraya/yolo.git
cd yolo

# Create feature branch for Kubernetes implementation
git checkout -b feature/kubernetes-orchestration
```

#### Development Workflow:

**Phase 1: Build Docker Images**
```bash
# Build backend image
cd backend
docker build -t jtaraya/yolo-backend:v1.0.0 .
docker push jtaraya/yolo-backend:v1.0.0

git add Dockerfile
git commit -m "feat: Add Dockerfile for backend API with Node.js 16"

# Build frontend image
cd ../client
docker build -t jtaraya/yolo-frontend:v1.0.0 .
docker push jtaraya/yolo-frontend:v1.0.0

git add Dockerfile
git commit -m "feat: Add Dockerfile for React frontend with nginx"
```

**Phase 2: Create Kubernetes Manifests**
```bash
# Create manifests directory
mkdir -p manifests
cd manifests

# Create MongoDB StatefulSet
touch mongodb-statefulset.yaml
git add mongodb-statefulset.yaml
git commit -m "feat: Add MongoDB StatefulSet with PVC for data persistence"

# Create backend deployment
touch backend-deployment.yaml
git add backend-deployment.yaml
git commit -m "feat: Add backend Deployment with 2 replicas and health probes"

# Create frontend deployment
touch frontend-deployment.yaml
git add frontend-deployment.yaml
git commit -m "feat: Add frontend Deployment with LoadBalancer service"
```

**Phase 3: Testing and Debugging**
```bash
# Test deployment locally with minikube
minikube start
kubectl apply -f manifests/

# Fix issues
git add manifests/backend-deployment.yaml
git commit -m "fix: Correct MongoDB connection string format"

git add manifests/frontend-deployment.yaml
git commit -m "fix: Update frontend service to use LoadBalancer type"
```

**Phase 4: GKE Deployment**
```bash
# Deploy to GKE
gcloud container clusters create yolo-cluster --num-nodes=3
kubectl apply -f manifests/

# Document deployment
git add README.md
git commit -m "docs: Add GKE deployment instructions with screenshots"

git add explanation.md
git commit -m "docs: Complete explanation of Kubernetes object choices"
```

**Phase 5: Final Updates**
```bash
# Update documentation
git add README.md
git commit -m "docs: Add live application URL and testing instructions"

# Merge to main
git checkout main
git merge feature/kubernetes-orchestration
git push origin main
```

### 4.3 Commit Standards

**Format:** `<type>: <description>`

**Types Used:**
- `feat:` New features (manifests, configurations)
- `fix:` Bug fixes (configuration errors)
- `docs:` Documentation (README, explanation.md)
- `refactor:` Code restructuring
- `test:` Testing updates
- `chore:` Maintenance tasks

**Example Good Commits:**
```
✅ feat: Add StatefulSet for MongoDB with 5Gi persistent storage
✅ fix: Correct backend containerPort from string to integer
✅ docs: Add architecture diagram and deployment screenshots
✅ refactor: Organize manifests into separate directory structure
```

**Example Bad Commits:**
```
❌ update files
❌ fix bug
❌ changes
❌ wip
```

### 4.4 Git Best Practices Applied

1. **Descriptive Commit Messages:** Each commit explains what and why
2. **Atomic Commits:** Each commit is a logical unit of work
3. **Minimum 10 Commits:** Project demonstrates progression
4. **Feature Branch:** Work isolated from main branch
5. **`.gitignore` Configured:** Excludes node_modules, .env files
6. **Documentation:** README and explanation.md committed at appropriate times

---

## 5. Deployment Process and Debugging

### 5.1 Successful Deployment Steps

**Prerequisites:**
```bash
# Install gcloud CLI
curl https://sdk.cloud.google.com | bash

# Install kubectl
gcloud components install kubectl

# Authenticate
gcloud auth login
gcloud config set project YOUR_PROJECT_ID
```

**Step 1: Create GKE Cluster**
```bash
# Create cluster with 3 nodes
gcloud container clusters create yolo-cluster \
    --num-nodes=3 \
    --zone=us-central1-a \
    --machine-type=e2-medium

# Get credentials
gcloud container clusters get-credentials yolo-cluster \
    --zone=us-central1-a
```

**Step 2: Deploy Application**
```bash
# Apply manifests in order
kubectl apply -f manifests/mongodb-statefulset.yaml
kubectl apply -f manifests/backend-deployment.yaml
kubectl apply -f manifests/frontend-deployment.yaml
```

**Step 3: Verify Deployment**
```bash
# Check all resources
kubectl get all

# Check StatefulSet status
kubectl get statefulset mongodb
kubectl get pvc

# Check services
kubectl get svc

# Get external IP for frontend
kubectl get svc frontend-service
# Wait for EXTERNAL-IP (may take 2-3 minutes)
```

**Step 4: Test Application**
```bash
# Access application via external IP
# Example: http://34.67.157.94/

# Test functionality:
# 1. Browse products
# 2. Add items to cart
# 3. Verify cart persistence
```

### 5.2 Common Issues and Debugging Measures

#### Issue 1: Pods Not Starting (ImagePullBackOff)
**Symptom:**
```bash
kubectl get pods
# NAME                    READY   STATUS             RESTARTS
# backend-deployment-xxx  0/1     ImagePullBackOff   0
```

**Debugging:**
```bash
# Check pod details
kubectl describe pod backend-deployment-xxx

# Common causes:
# - Wrong image name
# - Image doesn't exist on Docker Hub
# - Private image without imagePullSecrets
```

**Solution:**
```bash
# Verify image exists
docker pull jtaraya/yolo-backend:v1.0.0

# Update manifest with correct image name
kubectl apply -f manifests/backend-deployment.yaml
```

#### Issue 2: Backend Can't Connect to MongoDB
**Symptom:**
```bash
# Backend logs show connection errors
kubectl logs backend-deployment-xxx
# Error: connect ECONNREFUSED mongodb-service:27017
```

**Debugging:**
```bash
# Check MongoDB pod is running
kubectl get pods -l app=mongodb

# Check MongoDB service exists
kubectl get svc mongodb-service

# Test DNS resolution from backend pod
kubectl exec -it backend-deployment-xxx -- nslookup mongodb-service

# Check MongoDB logs
kubectl logs mongodb-0
```

**Solution:**
```bash
# Ensure MongoDB is fully ready before backend starts
# Add initContainer or increase initialDelaySeconds in probes
```

#### Issue 3: External IP Pending
**Symptom:**
```bash
kubectl get svc frontend-service
# NAME               TYPE           CLUSTER-IP       EXTERNAL-IP     PORT(S)
# frontend-service   LoadBalancer   34.118.233.41    34.67.157.94   80:30141/TCP
```

**Debugging:**
```bash
# Check service events
kubectl describe svc frontend-service

# Verify GKE has permission to create load balancers
# Check GCP quotas
```

**Solution:**
```bash
# Wait 2-3 minutes for GCP provisioning
# If still pending after 5 minutes, recreate service:
kubectl delete svc frontend-service
kubectl apply -f manifests/frontend-deployment.yaml
```

#### Issue 4: Application Works But Cart Doesn't Persist
**Symptom:**
- Items added to cart
- MongoDB pod deleted/restarted
- Cart is empty

**Debugging:**
```bash
# Verify PVC exists and is bound
kubectl get pvc
# NAME                        STATUS   VOLUME
# mongodb-data-mongodb-0      Bound    pvc-xxxxx

# Check if volume is mounted
kubectl describe pod mongodb-0
# Look for: Mounts: /data/db from mongodb-data

# Check MongoDB data directory
kubectl exec -it mongodb-0 -- ls -la /data/db
```

**Solution:**
```bash
# Ensure volumeClaimTemplates is correctly configured
# Verify storageClassName is valid for GKE
kubectl get storageclass
```

#### Issue 5: High Memory/CPU Usage
**Symptom:**
```bash
# Pods being OOMKilled or CPU throttled
kubectl top pods
```

**Debugging:**
```bash
# Check resource usage
kubectl top pods
kubectl top nodes

# Check pod events
kubectl get events --sort-by='.lastTimestamp'
```

**Solution:**
```bash
# Increase resource limits in manifests
resources:
  limits:
    memory: "512Mi"  # Increased from 256Mi
    cpu: "500m"      # Increased from 200m
```

### 5.3 Monitoring and Logging

**View Pod Logs:**
```bash
# Frontend logs
kubectl logs -f frontend-deployment-xxx

# Backend logs
kubectl logs -f backend-deployment-xxx

# MongoDB logs
kubectl logs -f mongodb-0

# Previous container logs (if crashed)
kubectl logs backend-deployment-xxx --previous
```

**Access Pod Shell:**
```bash
# Backend shell
kubectl exec -it backend-deployment-xxx -- /bin/bash

# MongoDB shell
kubectl exec -it mongodb-0 -- mongosh -u admin -p password
```

**Monitor Resources:**
```bash
# Real-time pod status
kubectl get pods -w

# Resource usage
kubectl top pods
kubectl top nodes
```

---

## 6. Good Practices Applied

### 6.1 Docker Image Tag Naming Standards

**Convention Used:** `jtaraya/yolo:v1.0.0`

**Examples:**
- `jtaraya/yolo-backend:v1.0.0`
- `jtaraya/yolo-frontend:v1.0.0`

**Benefits:**
- ✅ Clear identification of image owner
- ✅ Descriptive application name
- ✅ Semantic versioning for tracking changes
- ✅ Easy to identify in Docker Hub registry

**Versioning Strategy:**
- `v1.0.0` - Initial production release
- `v1.0.1` - Bug fix
- `v1.1.0` - New feature
- `v2.0.0` - Breaking changes

### 6.2 Kubernetes Labels and Annotations

**Labels Used:**
```yaml
labels:
  app: backend
  tier: api
  version: v1.0.0
  environment: production
```

**Benefits:**
- Easy pod selection with kubectl
- Service selector matching
- Organized resource management
- Supports monitoring and metrics

### 6.3 Resource Management

**All deployments include:**
- Resource requests (guaranteed resources)
- Resource limits (maximum allowed)
- Prevents resource starvation
- Enables efficient cluster utilization

### 6.4 Health Checks

**Every deployment has:**
- Liveness probes (restart unhealthy containers)
- Readiness probes (control traffic flow)
- Appropriate delay and period settings

### 6.5 Security Practices

**Applied:**
- ClusterIP for internal services
- LoadBalancer only for frontend
- No root containers (where possible)
- Environment variables for configuration

**Production Improvements Needed:**
- Use Secrets for MongoDB credentials
- Enable RBAC
- Network Policies for pod isolation
- Use private Docker registry

---

## 7. Architecture Diagram

```
                                    Internet
                                        |
                                        v
                                [LoadBalancer]
                                        |
                                        v
                            +----------------------+
                            |  Frontend Service    |
                            |  (LoadBalancer)      |
                            |  Port: 80            |
                            +----------------------+
                                        |
                            +-----------+-----------+
                            |           |           |
                            v           v           v
                    [Frontend]  [Frontend]  [Frontend]
                    [Pod 1]     [Pod 2]     [Pod 3]
                    Port: 3000  Port: 3000  Port: 3000
                            |
                            |  (Internal Network)
                            |
                            v
                    +----------------------+
                    |  Backend Service     |
                    |  (ClusterIP)         |
                    |  Port: 5000          |
                    +----------------------+
                            |
                    +-------+-------+
                    |               |
                    v               v
            [Backend Pod 1]  [Backend Pod 2]
            Port: 5000       Port: 5000
                    |
                    |  (Internal Network)
                    |
                    v
            +----------------------+
            |  MongoDB Service     |
            |  (Headless)          |
            |  Port: 27017         |
            +----------------------+
                    |
                    v
            [MongoDB StatefulSet]
            [Pod: mongodb-0]
            Port: 27017
                    |
                    v
            [PersistentVolume]
            [5Gi Storage]
            /data/db
```

---

## 8. Conclusion

This Kubernetes orchestration implementation successfully deploys the YOLO e-commerce application on GKE with:

✅ **StatefulSet** for MongoDB with persistent storage  
✅ **Deployments** for stateless frontend and backend  
✅ **LoadBalancer** service for internet access  
✅ **Health probes** for reliability  
✅ **Resource management** for efficiency  
✅ **Proper labeling** for organization  
✅ **Data persistence** surviving pod failures  
✅ **High availability** with multiple replicas  

The application is production-ready with room for enhancements like:
- Ingress for advanced routing
- Horizontal Pod Autoscaling
- Network Policies for security
- Monitoring with Prometheus/Grafana
- CI/CD integration with Cloud Build

---

**Live Application URL:** http://34.67.157.94/  
**Repository:** https://github.com/jtaraya/yolo.git  
**DockerHub:** https://hub.docker.com/u/jtaraya