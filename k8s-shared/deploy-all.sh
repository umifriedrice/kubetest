#!/bin/bash

set -e

echo "🚀 Deploying all applications to Kubernetes cluster..."

# Build and deploy kube-app
echo "📦 Building and deploying kube-app..."
cd app/kube-app
eval $(minikube docker-env)
docker build -t kube-app:latest .
kubectl apply -k k8s/
cd ../..

# Build and deploy kube-app-2
echo "📦 Building and deploying kube-app-2..."
cd app/kube-app-2
eval $(minikube docker-env)
docker build -t kube-app-2:latest .
kubectl apply -k k8s/
cd ../..

# Deploy shared ingress
echo "🌐 Deploying shared ingress..."
kubectl apply -f k8s-shared/ingress.yaml

echo "⏳ Waiting for deployments to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/kube-app -n kube-app
kubectl wait --for=condition=available --timeout=300s deployment/kube-app-2 -n kube-app-2

echo "✅ All deployments complete!"
echo ""
echo "📊 Check the status with:"
echo "   kubectl get pods --all-namespaces"
echo "   kubectl get services --all-namespaces"
echo "   kubectl get ingress --all-namespaces"
echo ""
echo "🌐 To access the applications:"
echo "   # For kube-app (port 8080):"
echo "   kubectl port-forward service/kube-app-service 8080:80 -n kube-app"
echo "   Then visit: http://localhost:8080"
echo ""
echo "   # For kube-app-2 (port 8081):"
echo "   kubectl port-forward service/kube-app-2-service 8081:80 -n kube-app-2"
echo "   Then visit: http://localhost:8081"
echo ""
echo "🌐 To use ingress (after enabling it):"
echo "   minikube addons enable ingress"
echo "   # Add to /etc/hosts:"
echo "   # 127.0.0.1 kube-app.local"
echo "   # 127.0.0.1 kube-app-2.local"
echo "   # Then visit: http://kube-app.local and http://kube-app-2.local" 