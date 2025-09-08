#!/bin/bash

set -e

ENVIRONMENT=${1:-dev}

echo "🧹 Cleaning up K8s Example App from $ENVIRONMENT environment..."

# Delete Kubernetes resources
kubectl delete -k kubernetes/overlays/$ENVIRONMENT --ignore-not-found=true

# Wait for namespace cleanup
echo "⏳ Waiting for cleanup to complete..."
kubectl wait --for=delete namespace/k8s-example --timeout=60s || true

echo "✅ Cleanup complete!"