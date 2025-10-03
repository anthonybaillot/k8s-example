#!/bin/bash

set -e

# Configuration
ENVIRONMENT=${1:-dev}
NAMESPACE="k8s-example"
CHART_PATH="./helm/k8s-example"
RELEASE_NAME="k8s-example"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 Deploying K8s Example App with Helm to $ENVIRONMENT environment...${NC}"

# Check if Helm is installed
if ! command -v helm &> /dev/null; then
    echo -e "${RED}❌ Helm is not installed. Please install Helm first.${NC}"
    echo "Visit: https://helm.sh/docs/intro/install/"
    exit 1
fi

# Check if kubectl is configured
if ! kubectl cluster-info &> /dev/null; then
    echo -e "${RED}❌ kubectl is not configured or cluster is not accessible.${NC}"
    exit 1
fi

# Set environment-specific values
VALUES_FILE="$CHART_PATH/values-${ENVIRONMENT}.yaml"
if [[ ! -f "$VALUES_FILE" ]]; then
    echo -e "${YELLOW}⚠️  Environment-specific values file not found: $VALUES_FILE${NC}"
    echo -e "${YELLOW}   Using default values.yaml${NC}"
    VALUES_FILE="$CHART_PATH/values.yaml"
fi

# Update namespace for environment
if [[ "$ENVIRONMENT" != "dev" ]]; then
    NAMESPACE="k8s-example-${ENVIRONMENT}"
    RELEASE_NAME="k8s-example-${ENVIRONMENT}"
fi

echo -e "${BLUE}📋 Deployment Configuration:${NC}"
echo -e "  Environment: ${YELLOW}$ENVIRONMENT${NC}"
echo -e "  Namespace: ${YELLOW}$NAMESPACE${NC}"
echo -e "  Release: ${YELLOW}$RELEASE_NAME${NC}"
echo -e "  Values: ${YELLOW}$VALUES_FILE${NC}"
echo ""

# Detect Kubernetes environment and build images accordingly
echo -e "${BLUE}📦 Building Docker images...${NC}"

# Check if we're using minikube
if kubectl config current-context | grep -q "minikube"; then
    echo -e "${GREEN}🚀 Using minikube - setting Docker environment...${NC}"
    eval $(minikube docker-env)
fi

# Build images with consistent tags
IMAGE_TAG=${IMAGE_TAG:-latest}
echo -e "${BLUE}   Building with tag: $IMAGE_TAG${NC}"

docker build -t k8s-database:$IMAGE_TAG ./services/database/
docker build -t k8s-backend:$IMAGE_TAG ./services/backend/
docker build -t k8s-frontend:$IMAGE_TAG ./services/frontend/

# Check if we're using kind and load images
if kubectl config current-context | grep -q "kind"; then
    echo -e "${GREEN}🚀 Using kind - loading images into cluster...${NC}"
    kind load docker-image k8s-database:$IMAGE_TAG
    kind load docker-image k8s-backend:$IMAGE_TAG
    kind load docker-image k8s-frontend:$IMAGE_TAG
fi

# Validate Helm chart
echo -e "${BLUE}🔍 Validating Helm chart...${NC}"
helm lint $CHART_PATH

# Dry run to check what will be deployed
echo -e "${BLUE}🧪 Running Helm dry-run...${NC}"
helm upgrade --install $RELEASE_NAME $CHART_PATH \
    --values $VALUES_FILE \
    --set database.image.tag=$IMAGE_TAG \
    --set backend.image.tag=$IMAGE_TAG \
    --set frontend.image.tag=$IMAGE_TAG \
    --dry-run --debug

# Confirm deployment
if [[ "$ENVIRONMENT" == "prod" ]]; then
    echo -e "${RED}⚠️  You are about to deploy to PRODUCTION!${NC}"
    read -p "Are you sure you want to continue? (yes/no): " -r
    if [[ ! $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
        echo -e "${YELLOW}Deployment cancelled.${NC}"
        exit 1
    fi
fi

# Deploy with Helm
echo -e "${BLUE}☸️  Deploying with Helm...${NC}"
helm upgrade --install $RELEASE_NAME $CHART_PATH \
    --values $VALUES_FILE \
    --set database.image.tag=$IMAGE_TAG \
    --set backend.image.tag=$IMAGE_TAG \
    --set frontend.image.tag=$IMAGE_TAG \
    --create-namespace \
    --wait \
    --timeout=5m

# Wait for deployments to be ready
echo -e "${BLUE}⏳ Waiting for deployments to be ready...${NC}"
kubectl wait --for=condition=available --timeout=300s deployment/database -n $NAMESPACE
kubectl wait --for=condition=available --timeout=300s deployment/backend -n $NAMESPACE
kubectl wait --for=condition=available --timeout=300s deployment/frontend -n $NAMESPACE

echo -e "${GREEN}✅ Deployment complete!${NC}"
echo ""

# Show deployment status
echo -e "${BLUE}📋 Deployment Status:${NC}"
helm status $RELEASE_NAME -n $NAMESPACE
echo ""

echo -e "${BLUE}🏃 Running Pods:${NC}"
kubectl get pods -n $NAMESPACE
echo ""

echo -e "${BLUE}🌐 Services:${NC}"
kubectl get svc -n $NAMESPACE
echo ""

echo -e "${BLUE}🔗 Ingress:${NC}"
kubectl get ingress -n $NAMESPACE
echo ""

# Environment-specific instructions
case $ENVIRONMENT in
    "dev")
        echo -e "${GREEN}🎉 Your development application is now running!${NC}"
        echo -e "${YELLOW}Add these entries to your /etc/hosts file:${NC}"
        echo "127.0.0.1 k8s-example-dev.local"
        echo "127.0.0.1 api.k8s-example-dev.local"
        echo ""
        echo -e "${YELLOW}Then access your application at:${NC}"
        echo "Frontend: http://k8s-example-dev.local"
        echo "Backend API: http://api.k8s-example-dev.local"
        ;;
    "staging")
        echo -e "${GREEN}🎉 Your staging application is now running!${NC}"
        echo -e "${YELLOW}Access your application at:${NC}"
        echo "Frontend: https://k8s-example-staging.com"
        echo "Backend API: https://api.k8s-example-staging.com"
        ;;
    "prod")
        echo -e "${GREEN}🎉 Your production application is now running!${NC}"
        echo -e "${YELLOW}Access your application at:${NC}"
        echo "Frontend: https://k8s-example.com"
        echo "Backend API: https://api.k8s-example.com"
        ;;
esac

echo ""
echo -e "${BLUE}📊 Useful commands:${NC}"
echo "  View logs: kubectl logs -f deployment/backend -n $NAMESPACE"
echo "  Scale backend: kubectl scale deployment backend --replicas=3 -n $NAMESPACE"
echo "  Update deployment: helm upgrade $RELEASE_NAME $CHART_PATH --values $VALUES_FILE"
echo "  Rollback: helm rollback $RELEASE_NAME -n $NAMESPACE"
echo "  Uninstall: helm uninstall $RELEASE_NAME -n $NAMESPACE"