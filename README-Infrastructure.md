# Infrastructure as Code for K8s Example App

This repository contains comprehensive Infrastructure as Code (IaC) setup for deploying the K8s Example application reliably to Kubernetes clusters.

## 🏗️ Architecture Overview

The deployment setup includes:

- **Helm Charts**: Template-based Kubernetes manifests with environment-specific configurations
- **CI/CD Pipelines**: Automated testing, building, and deployment workflows
- **GitOps with ArgoCD**: Declarative, git-based deployment management
- **Multi-Environment Support**: Development, Staging, and Production configurations

## 📂 Structure

```
├── helm/k8s-example/           # Helm chart
│   ├── Chart.yaml              # Chart metadata
│   ├── values.yaml             # Default values
│   ├── values-dev.yaml         # Development overrides
│   ├── values-staging.yaml     # Staging overrides
│   ├── values-prod.yaml        # Production overrides
│   └── templates/              # Kubernetes manifests
├── .github/workflows/          # GitHub Actions CI/CD
├── .gitlab-ci.yml             # GitLab CI/CD
├── argocd/                    # ArgoCD GitOps configurations
└── helm-deploy.sh             # Enhanced Helm deployment script
```

## 🚀 Quick Start

### 1. Deploy with Helm

```bash
# Development
./helm-deploy.sh dev

# Staging
./helm-deploy.sh staging

# Production
./helm-deploy.sh prod
```

### 2. Set up GitOps with ArgoCD

```bash
# Install ArgoCD
./argocd/install-argocd.sh

# Access ArgoCD UI
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

## 🛠️ Deployment Methods

### Option 1: Direct Helm Deployment

**Best for**: Local development, manual deployments, testing

```bash
# Install/upgrade with custom values
helm upgrade --install k8s-example ./helm/k8s-example \
  --values ./helm/k8s-example/values-dev.yaml \
  --create-namespace \
  --wait

# Check deployment
helm status k8s-example
kubectl get pods -n k8s-example-dev
```

### Option 2: Enhanced Script Deployment

**Best for**: Consistent deployments across environments

```bash
# Deploy to development with image building
./helm-deploy.sh dev

# Deploy to production with confirmation
./helm-deploy.sh prod
```

### Option 3: CI/CD Pipeline Deployment

**Best for**: Automated deployments triggered by code changes

- **GitHub Actions**: Configured in `.github/workflows/ci-cd.yml`
- **GitLab CI**: Configured in `.gitlab-ci.yml`

Features:
- Automated testing
- Container image building and scanning
- Multi-environment deployment
- Security scanning with Trivy

### Option 4: GitOps with ArgoCD

**Best for**: Production-grade, declarative deployment management

```bash
# Install ArgoCD
./argocd/install-argocd.sh

# Applications will auto-sync from git
# - Development: auto-sync from 'develop' branch
# - Staging: auto-sync from 'main' branch
# - Production: manual sync required
```

## 🌍 Environment Configurations

### Development (`values-dev.yaml`)
- Minimal resources
- Single replicas
- Local ingress hosts
- No HPA
- Fast feedback loop

### Staging (`values-staging.yaml`)
- Production-like resources
- SSL/TLS enabled
- Auto-scaling enabled
- Performance testing ready

### Production (`values-prod.yaml`)
- High availability
- Resource limits optimized
- Advanced monitoring
- Security hardened

## 🔐 Security Features

- **Container Scanning**: Trivy integration in CI/CD
- **RBAC**: Role-based access control in ArgoCD
- **Secrets Management**: Kubernetes secrets with base64 encoding
- **Network Policies**: Ingress traffic control
- **Resource Limits**: CPU and memory constraints

## 📊 Monitoring & Observability

The deployment supports integration with:

- **Prometheus**: Metrics collection
- **Grafana**: Dashboards and visualization
- **Jaeger**: Distributed tracing
- **ELK Stack**: Centralized logging

## 🔄 GitOps Workflow

1. **Code Changes**: Push to `develop` or `main` branch
2. **CI Pipeline**: Tests, builds, and pushes container images
3. **ArgoCD Sync**: Automatically detects changes and deploys
4. **Health Checks**: Monitors application health
5. **Notifications**: Alerts on deployment status

## 🛡️ Disaster Recovery

- **Backup Strategy**: Database and persistent volume backups
- **Rollback**: Helm and ArgoCD rollback capabilities
- **Multi-AZ**: Production deployment across availability zones
- **Blue-Green**: Zero-downtime deployment strategy

## 📋 Prerequisites

- Kubernetes cluster (1.24+)
- Helm 3.12+
- kubectl configured
- Docker for image building
- ArgoCD (for GitOps)

## 🔧 Customization

### Adding New Environments

1. Create `values-{env}.yaml` with environment-specific values
2. Update CI/CD pipeline to include new environment
3. Create ArgoCD application for the environment

### Modifying Resources

Edit the appropriate values file:

```yaml
backend:
  replicas: 3
  resources:
    requests:
      memory: "512Mi"
      cpu: "250m"
```

### Adding New Services

1. Add service manifests to `helm/k8s-example/templates/`
2. Update `values.yaml` with service configuration
3. Modify deployment script if needed

## 🚨 Troubleshooting

### Common Issues

**Helm deployment fails**:
```bash
helm lint ./helm/k8s-example
kubectl describe pod <pod-name> -n <namespace>
```

**ArgoCD sync issues**:
```bash
argocd app get k8s-example-dev
argocd app sync k8s-example-dev --force
```

**Resource constraints**:
```bash
kubectl top nodes
kubectl top pods -n <namespace>
```

## 📚 Additional Resources

- [Helm Documentation](https://helm.sh/docs/)
- [ArgoCD Documentation](https://argo-cd.readthedocs.io/)
- [Kubernetes Best Practices](https://kubernetes.io/docs/concepts/configuration/overview/)
- [GitOps Principles](https://opengitops.dev/)

## 🤝 Contributing

1. Make changes to Helm charts or configurations
2. Test locally with `helm template` and `helm lint`
3. Submit PR with changes
4. CI pipeline will validate changes
5. Deploy to staging for integration testing