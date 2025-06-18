#!/bin/bash

set -e

echo "🧹 Cleaning up all applications from Kubernetes cluster..."

# Clean up shared ingress
echo "🗑️  Cleaning up shared ingress..."
kubectl delete -f k8s-shared/ingress.yaml --ignore-not-found=true

# Clean up kube-app
echo "🗑️  Cleaning up kube-app..."
cd app/kube-app
kubectl delete -k k8s/ --ignore-not-found=true
docker rmi kube-app:latest --force 2>/dev/null || true
cd ../..

# Clean up kube-app-2
echo "🗑️  Cleaning up kube-app-2..."
cd app/kube-app-2
kubectl delete -k k8s/ --ignore-not-found=true
docker rmi kube-app-2:latest --force 2>/dev/null || true
cd ../..

echo "✅ All cleanup complete!" 