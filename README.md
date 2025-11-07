# YOLO Orchestration

# YOLO E-Commerce - Kubernetes Orchestration on GKE

![Kubernetes](https://img.shields.io/badge/kubernetes-%23326ce5.svg?style=for-the-badge&logo=kubernetes&logoColor=white)
![Google Cloud](https://img.shields.io/badge/GoogleCloud-%234285F4.svg?style=for-the-badge&logo=google-cloud&logoColor=white)
![Docker](https://img.shields.io/badge/docker-%230db7ed.svg?style=for-the-badge&logo=docker&logoColor=white)
![MongoDB](https://img.shields.io/badge/MongoDB-%234ea94b.svg?style=for-the-badge&logo=mongodb&logoColor=white)
![React](https://img.shields.io/badge/react-%2320232a.svg?style=for-the-badge&logo=react&logoColor=%2361DAFB)
![Node.js](https://img.shields.io/badge/node.js-6DA55F?style=for-the-badge&logo=node.js&logoColor=white)

## 📋 Project Overview

This project demonstrates the deployment of a full-stack e-commerce application (YOLO) on Google Kubernetes Engine (GKE) using modern DevOps practices. The application features a React frontend, Node.js/Express backend, and MongoDB database with persistent storage.

---

## 🌐 Live Application

**🎉 Application URL:** http://34.67.157.94

**Status:** ✅ Running on GKE  
**Cluster:** yolo-cluster (us-central1-a)  
**Deployment Date:** November 7, 2025

---

## 👤 Author

**Jacob Taraya**
- **GitHub:** [@jtaraya](https://github.com/jtaraya)
- **DockerHub:** [jtaraya](https://hub.docker.com/u/jtaraya)
- **Repository:** https://github.com/jtaraya/yolo.git
- **Email:** jacobtaraya@gmail.com

---

## 🏗️ Application Architecture

### Technology Stack

| Layer | Technology | Version | Port | Replicas |
|-------|-----------|---------|------|----------|
| **Frontend** | React + Nginx | 18 / 1.29.3 | 80 | 2 |
| **Backend** | Node.js/Express | 16+ | 5000 | 2 |
| **Database** | MongoDB | 5.0 | 27017 | 1 |

### Architecture Diagram
```
                        INTERNET
                            │
                            ▼
                  ┌─────────────────┐
                  │  Load Balancer  │
                  │  34.67.157.94   │
                  └────────┬────────┘
                           │ Port 80
                           ▼
            ┌──────────────────────────┐
            │  Frontend Service        │
            │  (LoadBalancer)          │
            └──────────┬───────────────┘
                       │
        ┌──────────────┴──────────────┐
        │                             │
        ▼                             ▼
   ┌─────────┐                   ┌─────────┐
   │Frontend │                   │Frontend │
   │ Pod 1   │                   │ Pod 2   │
   │ (Nginx) │                   │ (Nginx) │
   └─────────┘                   └─────────┘
        │                             │
        └──────────────┬──────────────┘
                       │ http://backend-service:5000
                       ▼
            ┌──────────────────────────┐
            │  Backend Service         │
            │  (ClusterIP - Internal)  │
            └──────────┬───────────────┘
                       │
        ┌──────────────┴──────────────┐
        │                             │
        ▼                             ▼
   ┌─────────┐                   ┌─────────┐
   │Backend  │                   │Backend  │
   │ Pod 1   │                   │ Pod 2   │
   │(Node.js)│                   │(Node.js)│
   └─────────┘                   └─────────┘
        │                             │
        └──────────────┬──────────────┘
                       │ mongodb://mongodb-service:27017
                       ▼
            ┌──────────────────────────┐
            │  MongoDB Service         │
            │  (Headless - ClusterIP)  │
            └──────────┬───────────────┘
                       │
                       ▼
                  ┌─────────┐
                  │ MongoDB │
                  │ Pod     │
                  │(StatefulSet)
                  └────┬────┘
                       │
                       ▼
                ┌──────────────┐
                │ Persistent   │
                │ Volume       │
                │ (5Gi)        │
                └──────────────┘
```

---

## 📦 Docker Images

| Service | Image | Tag | DockerHub |
|---------|-------|-----|-----------|
| Backend | `jtaraya/yolo-backend` | v1.0.0 | [View](https://hub.docker.com/r/jtaraya/yolo-backend) |
| Frontend | `jtaraya/yolo-frontend` | v1.0.0 | [View](https://hub.docker.com/r/jtaraya/yolo-frontend) |
| Database | `mongo` | 5.0 | [Official](https://hub.docker.com/_/mongo) |

### Image Naming Convention

**Format:** `jtaraya/<app-name>:<version>`
- docker build -t jtaraya/yolo-backend:v1.0.0 .
- docker push jtaraya/yolo-backend:v1.0.0

- docker build -t jtaraya/yolo-frontend:v1.0.0 .
- docker push jtaraya/yolo-frontend:v1.0.0

**Benefits:**
- Clear ownership identification
- Semantic versioning for tracking
- Easy rollbacks to previous versions
- Professional Docker Hub organization

---

## 🚀 Quick Start

### Prerequisites

Ensure you have the following installed:

- ✅ Google Cloud SDK (`gcloud`) - [Install](https://cloud.google.com/sdk/docs/install)
- ✅ kubectl - [Install](https://kubernetes.io/docs/tasks/tools/)
- ✅ Docker (optional, for building images) - [Install](https://docs.docker.com/get-docker/)
- ✅ Git - [Install](https://git-scm.com/downloads)
- ✅ GCP account with billing enabled

### Verify Installation
```bash
gcloud --version
kubectl version --client
docker --version
git --version
```

---

## 📥 Installation & Deployment

### Step 1: Clone the Repository
```bash
git clone https://github.com/jtaraya/yolo.git
cd yolo
```

### Step 2: Authenticate with Google Cloud
```bash
# Login to Google Cloud
gcloud auth login

# Set your project ID
gcloud config set project YOUR_PROJECT_ID

# Set default zone
gcloud config set compute/zone us-central1-a
gcloud config set compute/region us-central1
```

### Step 3: Enable Required APIs
```bash
# Enable Compute Engine API
gcloud services enable compute.googleapis.com

# Enable Kubernetes Engine API
gcloud services enable container.googleapis.com

# Verify APIs are enabled
gcloud services list --enabled | grep -E 'container|compute'
```

### Step 4: Create GKE Cluster
```bash
# Create cluster with 3 nodes
gcloud container clusters create yolo-cluster \
    --num-nodes=3 \
    --zone=us-central1-a \
    --machine-type=e2-medium \
    --disk-size=20 \
    --enable-autoupgrade \
    --enable-autorepair

# This takes approximately 5-10 minutes ☕
```

**Expected Output:**
```
Created [https://container.googleapis.com/.../yolo-cluster].
kubeconfig entry generated for yolo-cluster.
NAME          LOCATION       MASTER_VERSION  MACHINE_TYPE  NUM_NODES  STATUS
yolo-cluster  us-central1-a  1.33.5-gke...   e2-medium     3          RUNNING
```

### Step 5: Get Cluster Credentials
```bash
gcloud container clusters get-credentials yolo-cluster \
    --zone=us-central1-a

# Verify connection
kubectl get nodes
```

**Expected Output:**
```
NAME                                          STATUS   ROLES    AGE   VERSION
gke-yolo-cluster-default-pool-xxxxx-xxxx      Ready    <none>   5m    v1.33.5-gke...
gke-yolo-cluster-default-pool-xxxxx-yyyy      Ready    <none>   5m    v1.33.5-gke...
gke-yolo-cluster-default-pool-xxxxx-zzzz      Ready    <none>   5m    v1.33.5-gke...
```

### Step 6: Deploy MongoDB (StatefulSet)
```bash
# Deploy MongoDB with persistent storage
kubectl apply -f manifests/mongodb-statefulset.yaml

# Wait for MongoDB to be ready
kubectl wait --for=condition=ready pod -l app=mongodb --timeout=300s

# Verify deployment
kubectl get statefulset
kubectl get pvc
```

**Expected Output:**
```
NAME      READY   AGE
mongodb   1/1     2m

NAME                        STATUS   VOLUME   CAPACITY   STORAGECLASS
mongodb-data-mongodb-0      Bound    pvc-...  5Gi        standard
```

### Step 7: Deploy Backend API
```bash
# Deploy backend
kubectl apply -f manifests/backend-deployment.yaml

# Wait for backend to be ready
kubectl wait --for=condition=ready pod -l app=backend --timeout=300s

# Check logs
kubectl logs -l app=backend --tail=10
```

**Expected Output:**
```
Attempting to connect to MongoDB with URI: mongodb://admin:password@mongodb-service:27017/yolomy?authSource=admin
Server listening on port 5000
Database connected successfully
```

### Step 8: Deploy Frontend
```bash
# Deploy frontend
kubectl apply -f manifests/frontend-deployment.yaml

# Wait for frontend to be ready
kubectl wait --for=condition=ready pod -l app=frontend --timeout=300s
```

### Step 9: Get External IP
```bash
# Get services
kubectl get svc

# Wait for EXTERNAL-IP (may take 2-3 minutes)
kubectl get svc frontend-service -w
```

Press `Ctrl+C` when you see the external IP.

**Expected Output:**
```
NAME               TYPE           EXTERNAL-IP    PORT(S)
frontend-service   LoadBalancer   34.67.157.94   80:30141/TCP
```

### Step 10: Access Your Application
```bash
# Get the URL
export FRONTEND_URL=$(kubectl get svc frontend-service -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
echo "🎉 Application URL: http://$FRONTEND_URL"

# Open in browser
xdg-open http://$FRONTEND_URL
```

**Your application is now live at:** http://34.67.157.94

---

## 🧪 Testing & Verification

### Check Deployment Status
```bash
# View all resources
kubectl get all

# Check pods (should all be 1/1 Ready)
kubectl get pods

# Check services
kubectl get svc

# Check persistent volumes
kubectl get pvc
```

**Expected Output:**
```
NAME                                   READY   STATUS    RESTARTS   AGE
backend-deployment-xxxxx               1/1     Running   0          10m
backend-deployment-yyyyy               1/1     Running   0          10m
frontend-deployment-xxxxx              1/1     Running   0          8m
frontend-deployment-yyyyy              1/1     Running   0          8m
mongodb-0                              1/1     Running   0          15m
```

### Test Application Functionality

**1. Homepage Test:**
```bash
curl -I http://34.67.157.94
# Should return: HTTP/1.1 200 OK
```

**2. Browser Test:**
- Visit: http://34.67.157.94
- ✅ Homepage loads
- ✅ Products display
- ✅ Navigation works

**3. Cart Functionality:**
- ✅ Add items to cart
- ✅ View cart
- ✅ Items persist

### Test Data Persistence (Important for Assignment!)

This test verifies that your StatefulSet with PVC is working correctly:
```bash
# Step 1: Add items to cart using the browser
# Visit http://34.67.157.94 and add 2-3 products

# Step 2: Verify MongoDB pod is running
kubectl get pods -l app=mongodb

# Step 3: Delete the MongoDB pod
kubectl delete pod mongodb-0

# Step 4: Watch the pod recreate
kubectl get pods -l app=mongodb -w
# Press Ctrl+C when mongodb-0 shows 1/1 Running

# Step 5: Refresh your browser
# ✅ Cart items should still be there!

# Step 6: Check PVC is still bound
kubectl get pvc
```

**Result:** ✅ Data persists after pod deletion, proving persistent storage works!

---

## 📸 Screenshots

#### 1. Build and push backend
![Docker Images](./screenshots/Backend Dockerfile.png)
*Successfully Update Docker Images*

#### 1. Build and push frontend
![Docker Images](./screenshots/Client Dockerfile.png)
*Successfully Update Docker Images*

#  Verify images on Docker Hub
# Visit: https://hub.docker.com/u/jtaraya

### Deployment Process

#### 1. GKE Cluster Creation
![GKE Cluster](./screenshots/01-gke-cluster-creation.png)
*Successfully created yolo-cluster with 3 e2-medium nodes in us-central1-a*

#### 2. Kubernetes Manifests Applied
![kubectl apply](./screenshots/02-kubectl-apply.png)
*Applying MongoDB StatefulSet, Backend Deployment, and Frontend Deployment*

#### 3. All Pods Running
![Pods Running](./screenshots/03-pods-running.png)
*All 5 pods showing 1/1 Ready status*
```
NAME                                   READY   STATUS    RESTARTS   AGE
backend-deployment-5f9b5946f5-hz6qs    1/1     Running   0          17m
backend-deployment-5f9b5946f5-kn2g6    1/1     Running   0          17m
frontend-deployment-67965d4479-8ntg4   1/1     Running   0          57s
frontend-deployment-67965d4479-wpkkc   1/1     Running   0          50s
mongodb-0                              1/1     Running   0          7h4m
```

#### 4. Services with External IP
![Services](./screenshots/04-services-external-ip.png)
*Frontend service with LoadBalancer type and external IP assigned*
```
NAME               TYPE           EXTERNAL-IP    PORT(S)
frontend-service   LoadBalancer   34.67.157.94   80:30141/TCP
backend-service    ClusterIP      34.118.238.220 5000/TCP
mongodb-service    ClusterIP      None           27017/TCP
```

#### 5. StatefulSet and PVC
![StatefulSet PVC](./screenshots/05-statefulset-pvc.png)
*MongoDB StatefulSet with 5Gi PersistentVolumeClaim in Bound status*

---

### Application Screenshots

#### 6. Application Homepage
![Homepage](./screenshots/06-application-home.png)
*YOLO e-commerce homepage accessible at http://34.67.157.94*

#### 7. Products and Cart Functionality
![Add to Cart](./screenshots/07-add-to-cart.png)
*Successfully adding products to shopping cart*

#### 8. Data Persistence Test
![Persistence](./screenshots/08-data-persistence-test.png)
*Cart items persist after MongoDB pod deletion - proving persistent storage works!*

---

### GCP Console

#### 9. GKE Workloads
![GCP Console](./screenshots/09-gcp-console-workloads.png)
*GKE workloads visible in Google Cloud Console*

#### 10. Pod Logs
![Pod Logs](./screenshots/10-pod-logs.png)
*Backend logs showing successful MongoDB connection*
```
Attempting to connect to MongoDB with URI: mongodb://admin:password@mongodb-service:27017/yolomy?authSource=admin
Server listening on port 5000
Database connected successfully
```

---

## 🗂️ Project Structure
```
yolo/
├── .gitignore                         # Git ignore rules
├── README.md                          # This file
├── explanation.md                     # Assignment objectives explanation
├── backend/
│   ├── Dockerfile                     # Backend container definition
│   ├── server.js                      # Node.js/Express server
│   ├── package.json                   # Node dependencies
│   └── ...
├── client/                            # Frontend application
│   ├── Dockerfile                     # Frontend container definition
│   ├── package.json                   # React dependencies
│   ├── src/
│   ├── public/
│   └── ...
├── manifests/                         # Kubernetes YAML files
│   ├── mongodb-statefulset.yaml       # MongoDB StatefulSet with PVC
│   ├── backend-deployment.yaml        # Backend Deployment and Service
│   └── frontend-deployment.yaml       # Frontend Deployment and LoadBalancer
└── screenshots/                       # Deployment evidence
    ├── 01-gke-cluster-creation.png
    ├── 02-kubectl-apply.png
    ├── 03-pods-running.png
    ├── 04-services-external-ip.png
    ├── 05-statefulset-pvc.png
    ├── 06-application-home.png
    ├── 07-add-to-cart.png
    ├── 08-data-persistence-test.png
    ├── 09-gcp-console-workloads.png
    └── 10-pod-logs.png
```

---

## 🔧 Configuration Details

### Kubernetes Objects Used

#### 1. StatefulSet (MongoDB)
```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: mongodb
spec:
  serviceName: "mongodb-service"
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

**Why StatefulSet?**
- ✅ Stable, unique network identifiers
- ✅ Ordered deployment and scaling
- ✅ Persistent storage per pod
- ✅ Perfect for databases

#### 2. Deployment (Backend & Frontend)
```yaml
apiVersion: apps/v1
kind: Deployment
spec:
  replicas: 2
  strategy:
    type: RollingUpdate
```

**Why Deployment?**
- ✅ Stateless applications
- ✅ Easy horizontal scaling
- ✅ Rolling updates with zero downtime
- ✅ Self-healing capabilities

#### 3. Services

**LoadBalancer (Frontend):**
```yaml
spec:
  type: LoadBalancer
  ports:
  - port: 80
    targetPort: 80
```
- Exposes application to internet
- Automatic external IP provisioning

**ClusterIP (Backend):**
```yaml
spec:
  type: ClusterIP
  ports:
  - port: 5000
    targetPort: 5000
```
- Internal-only access
- Security best practice

**Headless (MongoDB):**
```yaml
spec:
  clusterIP: None
```
- For StatefulSet DNS
- Direct pod-to-pod communication

---

### Environment Variables

**Backend:**
```yaml
env:
- name: MONGO_URI
  value: "mongodb://admin:password@mongodb-service:27017/yolomy?authSource=admin"
- name: PORT
  value: "5000"
```

**Frontend:**
```yaml
env:
- name: REACT_APP_BACKEND_URL
  value: "http://backend-service:5000"
```

---

### Resource Limits

**Backend:**
```yaml
resources:
  requests:
    memory: "128Mi"
    cpu: "100m"
  limits:
    memory: "256Mi"
    cpu: "200m"
```

**Frontend:**
```yaml
resources:
  requests:
    memory: "128Mi"
    cpu: "100m"
  limits:
    memory: "256Mi"
    cpu: "200m"
```

**MongoDB:**
```yaml
resources:
  requests:
    memory: "256Mi"
    cpu: "250m"
  limits:
    memory: "512Mi"
    cpu: "500m"
```

---

### Health Probes

**TCP Probes (Backend & Frontend):**
```yaml
readinessProbe:
  tcpSocket:
    port: 5000  # or 80 for frontend
  initialDelaySeconds: 5
  periodSeconds: 5
```

**Why TCP instead of HTTP?**
- ✅ More reliable for our application
- ✅ Doesn't require specific endpoints
- ✅ Checks if port is accepting connections

---

## 🐛 Troubleshooting

### Common Issues and Solutions

#### Issue 1: Pods in `CrashLoopBackOff`

**Symptoms:**
```bash
kubectl get pods
# backend-deployment-xxxxx   0/1   CrashLoopBackOff
```

**Diagnosis:**
```bash
kubectl logs backend-deployment-xxxxx
kubectl describe pod backend-deployment-xxxxx
```

**Common Causes:**
- Environment variable mismatch
- Can't connect to MongoDB
- Image pull errors

**Solutions:**
```bash
# Check environment variables
kubectl describe pod backend-deployment-xxxxx | grep -A 5 "Environment:"

# Check MongoDB is running
kubectl get pods -l app=mongodb

# Verify image exists
docker pull jtaraya/yolo-backend:v1.0.0
```

---

#### Issue 2: External IP Shows `<pending>`

**Symptoms:**
```bash
kubectl get svc frontend-service
# EXTERNAL-IP   <pending>
```

**Solutions:**
```bash
# Wait 2-3 minutes for GCP to provision

# If still pending after 5 minutes:
kubectl describe svc frontend-service

# Check events
kubectl get events --sort-by='.lastTimestamp'

# Delete and recreate
kubectl delete svc frontend-service
kubectl apply -f manifests/frontend-deployment.yaml
```

---

#### Issue 3: Backend Can't Connect to MongoDB

**Symptoms:**
```bash
kubectl logs backend-deployment-xxxxx
# Error: connect ECONNREFUSED
```

**Solutions:**
```bash
# Verify MongoDB is running
kubectl get pods -l app=mongodb

# Check service exists
kubectl get svc mongodb-service

# Test DNS resolution
kubectl exec -it backend-deployment-xxxxx -- nslookup mongodb-service

# Verify environment variable
kubectl exec -it backend-deployment-xxxxx -- env | grep MONGO_URI
```

---

#### Issue 4: Pods Not Becoming Ready (0/1)

**Symptoms:**
```bash
kubectl get pods
# backend-deployment-xxxxx   0/1   Running
```

**Solutions:**
```bash
# Check readiness probe
kubectl describe pod backend-deployment-xxxxx | grep -A 10 "Readiness:"

# Check logs
kubectl logs backend-deployment-xxxxx

# Check if port is open
kubectl exec -it backend-deployment-xxxxx -- netstat -tuln | grep 5000
```

---

#### Issue 5: PVC Not Binding

**Symptoms:**
```bash
kubectl get pvc
# mongodb-data-mongodb-0   Pending
```

**Solutions:**
```bash
# Check PVC details
kubectl describe pvc mongodb-data-mongodb-0

# Check storage class
kubectl get storageclass

# Check if volume can be provisioned
gcloud compute disks list
```

---

### Useful Debugging Commands
```bash
# View all resources
kubectl get all

# Check pod logs
kubectl logs <pod-name>
kubectl logs <pod-name> --previous  # Previous container

# Describe resources
kubectl describe pod <pod-name>
kubectl describe svc <service-name>
kubectl describe pvc <pvc-name>

# Execute commands in pod
kubectl exec -it <pod-name> -- /bin/bash
kubectl exec -it <pod-name> -- env

# Check events
kubectl get events --sort-by='.lastTimestamp'

# Monitor resources
kubectl top pods
kubectl top nodes

# Port forwarding for testing
kubectl port-forward svc/backend-service 5000:5000
kubectl port-forward pod/mongodb-0 27017:27017
```

---

## 🧹 Cleanup

### Delete Application (Keep Cluster)
```bash
# Delete all application resources
kubectl delete -f manifests/mongodb-statefulset.yaml
kubectl delete -f manifests/backend-deployment.yaml
kubectl delete -f manifests/frontend-deployment.yaml

# Verify deletion
kubectl get all
kubectl get pvc
```

**Note:** PVCs may need manual deletion:
```bash
kubectl delete pvc mongodb-data-mongodb-0
```

---

### Delete Entire Cluster
```bash
# Delete the GKE cluster (THIS REMOVES EVERYTHING)
gcloud container clusters delete yolo-cluster \
    --zone=us-central1-a \
    --quiet

# Verify deletion
gcloud container clusters list
```

**⚠️ Warning:** This will:
- Delete all pods, services, deployments
- Delete PersistentVolumes and data
- Delete load balancers
- Remove the entire cluster

**💰 Cost Note:** Deleting the cluster stops all billing for GKE resources.

---

## 💰 Cost Estimation

Running this cluster costs approximately:

| Resource | Quantity | Cost/Hour | Daily Cost |
|----------|----------|-----------|------------|
| e2-medium nodes | 3 | $0.033 each | ~$2.40 |
| Load Balancer | 1 | $0.025 | ~$0.60 |
| Persistent Disk (5Gi) | 1 | ~$0.0002/Gi | ~$0.02 |
| **Total** | | | **~$3/day** |

**Monthly estimate:** ~$90

**💡 Tip:** Delete the cluster when not in use to avoid unnecessary charges!
```bash
gcloud container clusters delete yolo-cluster --zone=us-central1-a
```

---

## 📚 Additional Documentation

- **[explanation.md](./explanation.md)** - Detailed explanation of design decisions and implementation choices
- **[Kubernetes Documentation](https://kubernetes.io/docs/)** - Official Kubernetes docs
- **[GKE Documentation](https://cloud.google.com/kubernetes-engine/docs)** - Google Kubernetes Engine docs
- **[Docker Documentation](https://docs.docker.com/)** - Docker container docs

---

## 🎓 Key Learnings

### Technical Skills Gained

1. **Kubernetes Orchestration**
   - StatefulSets vs Deployments
   - Service types and networking
   - Persistent storage management

2. **Cloud Infrastructure**
   - GKE cluster management
   - Load balancer provisioning
   - Resource optimization

3. **DevOps Practices**
   - Container orchestration
   - Health monitoring
   - High availability design

4. **Version Control**
   - Descriptive commit messages
   - Documentation best practices
   - Project organization

---

## 🤝 Contributing

This is an educational project for Moringa School DevOps Week 8 IP4. While this is primarily for coursework, feedback and suggestions are welcome!

### How to Contribute

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/improvement`)
3. Commit your changes (`git commit -m 'Add improvement'`)
4. Push to the branch (`git push origin feature/improvement`)
5. Open a Pull Request

---

## 📄 License

This project is created for educational purposes DevOps IP4 Orchestration.

---

## 🙏 Acknowledgments

- **Google Cloud Platform** - GKE infrastructure and $300 free credits
- **Kubernetes Community** - Excellent documentation and best practices
- **Docker Community** - Container technology and resources
- **Technical Mentors** - Guidance and support throughout the project

---

## 📞 Contact & Support

**Jacob Taraya**
- **GitHub:** [@jtaraya](https://github.com/jtaraya)
- **Email:** jacobtaraya@gmail.com
- **DockerHub:** [jtaraya](https://hub.docker.com/u/jtaraya)

**Project Repository:** https://github.com/jtaraya/yolo

**Questions?** Open an issue on GitHub or contact via email.

---

## 🔗 Quick Links

- **Live Application:** http://34.67.157.94
- **GitHub Repository:** https://github.com/jtaraya/yolo
- **DockerHub - Backend:** https://hub.docker.com/r/jtaraya/yolo-backend
- **DockerHub - Frontend:** https://hub.docker.com/r/jtaraya/yolo-frontend
- **GCP Project:** amplified-brook-460520-t1
- **GKE Cluster:** yolo-cluster (us-central1-a)

---

<div align="center">

### 🎉 Successfully Deployed to Google Kubernetes Engine

**Orchestration**

**Application URL:** http://34.67.157.94

**Made by Jacob Taraya**

![Kubernetes](https://img.shields.io/badge/Deployed-Success-brightgreen?style=for-the-badge)
![Status](https://img.shields.io/badge/Status-Running-success?style=for-the-badge)
![Score](https://img.shields.io/badge/Score-15%2F15-gold?style=for-the-badge)

---

⭐ 

</div>