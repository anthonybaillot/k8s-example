#!/bin/bash

set -e

echo "🚀 Installing ArgoCD on Kubernetes cluster..."

# Create ArgoCD namespace
kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -

# Install ArgoCD
echo "📦 Installing ArgoCD..."
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Wait for ArgoCD to be ready
echo "⏳ Waiting for ArgoCD to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n argocd
kubectl wait --for=condition=available --timeout=300s deployment/argocd-repo-server -n argocd
kubectl wait --for=condition=available --timeout=300s deployment/argocd-application-controller -n argocd

# Get initial admin password
echo "🔑 Getting ArgoCD admin password..."
ARGOCD_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)

# Create ArgoCD project
echo "📋 Creating ArgoCD project..."
kubectl apply -f argocd/projects/k8s-example.yaml

# Create ArgoCD applications
echo "🎯 Creating ArgoCD applications..."
kubectl apply -f argocd/applications/

# Port forward for access (optional)
echo "🌐 Setting up port forwarding..."
echo "Run the following command to access ArgoCD UI:"
echo "kubectl port-forward svc/argocd-server -n argocd 8080:443"
echo ""
echo "ArgoCD UI will be available at: https://localhost:8080"
echo "Username: admin"
echo "Password: $ARGOCD_PASSWORD"
echo ""
echo "✅ ArgoCD installation complete!"

# Optional: Install ArgoCD CLI
echo ""
echo "💡 To install ArgoCD CLI:"
echo "curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64"
echo "sudo install -m 555 argocd-linux-amd64 /usr/local/bin/argocd"
echo "rm argocd-linux-amd64"