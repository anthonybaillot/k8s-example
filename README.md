# K8s Example Application

A microservices application demonstrating Kubernetes deployment with modern Infrastructure as Code practices.

## 🏗️ Architecture

- **Database**: PostgreSQL with persistent storage
- **Backend**: FastAPI application with health checks
- **Frontend**: React application

## 🚀 Quick Deployment

### Prerequisites

When using minikube:

```bash
eval $(minikube docker-env)
```

### Option 1: Helm (Recommended)

```bash
# Deploy to development
./helm-deploy.sh dev

# Deploy to staging
./helm-deploy.sh staging

# Deploy to production
./helm-deploy.sh prod
```

### Option 2: GitOps with ArgoCD

```bash
# Install ArgoCD
./argocd/install-argocd.sh

# Applications will auto-deploy from git
```

## 📋 Prerequisites

- Kubernetes cluster (1.24+)
- Helm 3.12+
- kubectl configured
- Docker (for building images)

## 📚 Documentation

For detailed infrastructure setup and deployment options, see [README-Infrastructure.md](./README-Infrastructure.md)

## 🛠️ Development

The application consists of three services:

- `services/database/` - PostgreSQL database
- `services/backend/` - FastAPI backend service
- `services/frontend/` - React frontend application

Each service includes its own Dockerfile for containerization.

## 🌍 Environments

- **Development**: `k8s-example-dev.local`
- **Staging**: `k8s-example-staging.com`
- **Production**: `k8s-example.com`

## 🔧 Local Development

```bash
# Build and deploy locally
./helm-deploy.sh dev

# Access the application
# Add to /etc/hosts: 127.0.0.1 k8s-example-dev.local
# Frontend: http://k8s-example-dev.local
# API: http://api.k8s-example-dev.local
```