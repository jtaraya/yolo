#!/bin/bash

# YOLO Application - GKE Deployment Script
# Author: Jacob Taraya
# Description: Automated deployment script for YOLO e-commerce app on GKE

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
CLUSTER_NAME="yolo-cluster"
ZONE="us-central1-a"
NUM_NODES=3
MACHINE_TYPE="e2-medium"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  YOLO Application GKE Deployment${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check prerequisites
echo -e "${YELLOW}Checking prerequisites...${NC}"

if ! command_exists gcloud; then
    echo -e "${RED}Error: gcloud CLI is not installed${NC}"
    echo "Install from: https://cloud.google.com/sdk/docs/install"
    exit 1
fi

if ! command_exists kubectl; then
    echo -e "${RED}Error: kubectl is not installed${NC}"
    echo "Install with: gcloud components install kubectl"
    exit 1
fi

echo -e "${GREEN}✓ All prerequisites met${NC}"
echo ""

# Get project ID
echo -e "${YELLOW}Checking Google Cloud project...${NC}"
PROJECT_ID=$(gcloud config get-value project 2>/dev/null)

if [ -z "$PROJECT_ID" ]; then
    echo -e "${RED}Error: No GCP project set${NC}"
    echo "Set project with: gcloud config set project YOUR_PROJECT_ID"
    exit 1
fi

echo -e "${GREEN}✓ Using project: $PROJECT_ID${NC}"
echo ""

# Ask user to confirm
echo -e "${YELLOW}This script will:${NC}"
echo "1. Create GKE cluster: $CLUSTER_NAME"
echo "2. Deploy MongoDB StatefulSet"
echo "3. Deploy Backend API"
echo "4. Deploy Frontend React app"
echo "5. Provision LoadBalancer with external IP"
echo ""
read -p "Continue? (y/n): " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Deployment cancelled${NC}"
    exit 0
fi

# Step 1: Create GKE Cluster
echo -e "${BLUE}Step 1: Creating GKE cluster...${NC}"
if gcloud container clusters describe $CLUSTER_NAME --zone=$ZONE &>/dev/null; then
    echo -e "${YELLOW}Cluster $CLUSTER_NAME already exists${NC}"
    read -p "Use existing cluster? (y/n): " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}Please delete existing cluster or use different name${NC}"
        exit 0
    fi
else
    echo "Creating cluster (this may take 5-10 minutes)..."
    gcloud container clusters create $CLUSTER_NAME \
        --num-nodes=$NUM_NODES \
        --zone=$ZONE \
        --machine-type=$MACHINE_TYPE \
        --disk-size=20 \
        --enable-autoupgrade \
        --enable-autorepair \
        --quiet
    
    echo -e "${GREEN}✓ Cluster created successfully${NC}"
fi
echo ""

# Step 2: Get cluster credentials
echo -e "${BLUE}Step 2: Getting cluster credentials...${NC}"
gcloud container clusters get-credentials $CLUSTER_NAME --zone=$ZONE
echo -e "${GREEN}✓ Credentials configured${NC}"
echo ""

# Step 3: Deploy MongoDB StatefulSet
echo -e "${BLUE}Step 3: Deploying MongoDB StatefulSet...${NC}"
kubectl apply -f manifests/mongodb-statefulset.yaml
echo "Waiting for MongoDB to be ready..."
kubectl wait --for=condition=ready pod -l app=mongodb --timeout=300s
echo -e "${GREEN}✓ MongoDB deployed${NC}"
echo ""

# Step 4: Deploy Backend
echo -e "${BLUE}Step 4: Deploying Backend API...${NC}"
kubectl apply -f manifests/backend-deployment.yaml
echo "Waiting for backend pods to be ready..."
kubectl wait --for=condition=ready pod -l app=backend --timeout=300s
echo -e "${GREEN}✓ Backend deployed${NC}"
echo ""

# Step 5: Deploy Frontend
echo -e "${BLUE}Step 5: Deploying Frontend...${NC}"
kubectl apply -f manifests/frontend-deployment.yaml
echo "Waiting for frontend pods to be ready..."
kubectl wait --for=condition=ready pod -l app=frontend --timeout=300s
echo -e "${GREEN}✓ Frontend deployed${NC}"
echo ""

# Step 6: Wait for LoadBalancer external IP
echo -e "${BLUE}Step 6: Waiting for external IP (may take 2-3 minutes)...${NC}"
EXTERNAL_IP=""
COUNTER=0
MAX_TRIES=20

while [ -z "$EXTERNAL_IP" ] && [ $COUNTER -lt $MAX_TRIES ]; do
    EXTERNAL_IP=$(kubectl get svc frontend-service -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null)
    if [ -z "$EXTERNAL_IP" ]; then
        echo "Waiting... (attempt $((COUNTER+1))/$MAX_TRIES)"
        sleep 10
        COUNTER=$((COUNTER+1))
    fi
done

if [ -z "$EXTERNAL_IP" ]; then
    echo -e "${RED}Warning: External IP not assigned yet${NC}"
    echo "Check status with: kubectl get svc frontend-service"
    echo ""
else
    echo -e "${GREEN}✓ External IP assigned: $EXTERNAL_IP${NC}"
    echo ""
fi

# Display deployment status
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Deployment Summary${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

echo -e "${GREEN}Pods:${NC}"
kubectl get pods
echo ""

echo -e "${GREEN}Services:${NC}"
kubectl get svc
echo ""

echo -e "${GREEN}PersistentVolumeClaims:${NC}"
kubectl get pvc
echo ""

# Display access information
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Access Information${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

if [ -n "$EXTERNAL_IP" ]; then
    echo -e "${GREEN}Application URL: http://$EXTERNAL_IP${NC}"
    echo ""
    echo "Test with curl:"
    echo "  curl http://$EXTERNAL_IP"
    echo ""
else
    echo "Get external IP with:"
    echo "  kubectl get svc frontend-service"
    echo ""
fi

echo -e "${YELLOW}Useful Commands:${NC}"
echo "  View pods:        kubectl get pods"
echo "  View services:    kubectl get svc"
echo "  View logs:        kubectl logs -f <pod-name>"
echo "  Delete app:       kubectl delete -f manifests/"
echo "  Delete cluster:   gcloud container clusters delete $CLUSTER_NAME --zone=$ZONE"
echo ""

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Deployment Complete! 🎉${NC}"
echo -e "${GREEN}========================================${NC}"
