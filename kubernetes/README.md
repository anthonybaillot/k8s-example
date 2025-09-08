# Kubernetes Configuration

This directory contains Kubernetes manifests for deploying the microservices application.

## Directory Structure

```
kubernetes/
├── base/                   # Base Kubernetes resources
│   ├── namespace.yaml     # Application namespace
│   ├── configmap.yaml     # Configuration data
│   └── secret.yaml        # Sensitive data
├── services/              # Service-specific manifests
│   ├── database/          # PostgreSQL database
│   ├── backend/           # FastAPI backend
│   └── frontend/          # React frontend
├── overlays/              # Environment-specific configurations
│   └── dev/               # Development environment
├── deploy.sh              # Deployment script
├── cleanup.sh             # Cleanup script
└── README.md              # This file
```

## Quick Start

1. **Deploy the application:**
   ```bash
   ./kubernetes/deploy.sh dev
   ```

2. **Access the application:**
   Add to your `/etc/hosts`:
   ```
   127.0.0.1 k8s-example.local
   127.0.0.1 api.k8s-example.local
   ```
   
   Then visit:
   - Frontend: http://k8s-example.local
   - Backend API: http://api.k8s-example.local

3. **Clean up:**
   ```bash
   ./kubernetes/cleanup.sh dev
   ```

## Manual Deployment

If you prefer manual deployment:

```bash
# Build images
docker build -t k8s-database:latest ./services/database/
docker build -t k8s-backend:latest ./services/backend/
docker build -t k8s-frontend:latest ./services/frontend/

# Deploy using Kustomize
kubectl apply -k kubernetes/overlays/dev

# Check status
kubectl get pods -n k8s-example
kubectl get svc -n k8s-example
```

## Components

### Database (PostgreSQL)
- **Image:** `k8s-database:latest`
- **Port:** 5432
- **Storage:** 1Gi PVC
- **Service:** `database-service`

### Backend (FastAPI)
- **Image:** `k8s-backend:latest`
- **Port:** 8000
- **Replicas:** 2 (1 in dev)
- **Service:** `backend-service`
- **Health checks:** `/health` endpoint
- **HPA:** CPU 70%, Memory 80%

### Frontend (React)
- **Image:** `k8s-frontend:latest`
- **Port:** 3000
- **Replicas:** 2 (1 in dev)
- **Service:** `frontend-service` (LoadBalancer)
- **Ingress:** nginx with custom domains

## Environment Variables

Configuration is managed through ConfigMaps and Secrets:

- **ConfigMap (app-config):**
  - `DB_HOST`, `DB_NAME`, `DB_USER`, `DB_PORT`
  - `REACT_APP_BACKEND_URL`

- **Secret (app-secrets):**
  - `DB_PASSWORD` (base64 encoded)

## Scaling

The backend includes Horizontal Pod Autoscaler (HPA) for automatic scaling based on CPU and memory usage.

Manual scaling:
```bash
kubectl scale deployment backend --replicas=3 -n k8s-example
```

## Troubleshooting

Check logs:
```bash
kubectl logs -f deployment/backend -n k8s-example
kubectl logs -f deployment/frontend -n k8s-example
kubectl logs -f deployment/database -n k8s-example
```

Check service status:
```bash
kubectl get pods -n k8s-example
kubectl describe pod <pod-name> -n k8s-example
```