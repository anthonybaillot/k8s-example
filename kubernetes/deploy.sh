#!/bin/bash

set -e

ENVIRONMENT=${1:-dev}

echo "🚀 Deploying K8s Example App to $ENVIRONMENT environment..."

# Detect Kubernetes environment and build images accordingly
echo "📦 Building Docker images..."

# Check if we're using minikube
if kubectl config current-context | grep -q "minikube"; then
    echo "🚀 Using minikube - setting Docker environment..."
    eval $(minikube docker-env)
fi

# Build images
docker build -t k8s-database:latest ./services/database/
docker build -t k8s-backend:latest ./services/backend/
docker build -t k8s-frontend:latest ./services/frontend/

# Check if we're using kind and load images
if kubectl config current-context | grep -q "kind"; then
    echo "🚀 Using kind - loading images into cluster..."
    kind load docker-image k8s-database:latest
    kind load docker-image k8s-backend:latest  
    kind load docker-image k8s-frontend:latest
fi

# Apply Kubernetes manifests
echo "☸️  Applying Kubernetes manifests..."
kubectl apply -k kubernetes/overlays/$ENVIRONMENT

# Wait for deployments to be ready
echo "⏳ Waiting for deployments to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/database -n k8s-example
kubectl wait --for=condition=available --timeout=300s deployment/backend -n k8s-example
kubectl wait --for=condition=available --timeout=300s deployment/frontend -n k8s-example

echo "✅ Deployment complete!"
echo ""
echo "📋 Service Status:"
kubectl get pods -n k8s-example
echo ""
echo "🌐 Services:"
kubectl get svc -n k8s-example
echo ""
echo "🔗 Ingress:"
kubectl get ingress -n k8s-example

echo ""
echo "🎉 Your application is now running!"
echo "Add these entries to your /etc/hosts file:"
echo "127.0.0.1 k8s-example.local"
echo "127.0.0.1 api.k8s-example.local"
echo ""
echo "Then access your application at:"
echo "Frontend: http://k8s-example.local"
echo "Backend API: http://api.k8s-example.local"