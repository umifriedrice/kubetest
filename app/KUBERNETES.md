# Kubernetes Multi-App Deployment Guide

This guide explains how to deploy multiple applications (kube-app and kube-app-2) to a local Kubernetes cluster with path-based routing.

## 🏗️ Architecture Overview

```
localhost/
├── /kube-app      → Routes to kube-app (Next.js application)
└── /kube-app-2    → Routes to kube-app-2 (Next.js application)
```

Both applications run in the same Kubernetes namespace (`kube-app`) and are accessible through a single ingress controller.

## 📋 Prerequisites

- **Docker Desktop** or Docker Engine
- **Minikube** (for local Kubernetes cluster)
- **kubectl** CLI tool
- **NGINX Ingress Controller** (automatically enabled)

## 🚀 Quick Start

### 1. Start Local Kubernetes Cluster

```bash
# Start Minikube with Docker driver
minikube start --driver=docker

# Verify cluster is running
kubectl cluster-info
```

### 2. Enable Ingress Controller

```bash
# Enable NGINX Ingress Controller
minikube addons enable ingress

# Start tunnel for ingress access (keep this running)
minikube tunnel
```

### 3. Deploy All Applications

```bash
# From the project root
./k8s-shared/deploy-all.sh
```

### 4. Access Applications

Once deployed, access your applications at:
- **kube-app**: http://localhost/kube-app
- **kube-app-2**: http://localhost/kube-app-2

## 📁 Project Structure

```
kubetest/
├── app/
│   ├── kube-app/          # First Next.js application
│   │   ├── Dockerfile
│   │   ├── k8s/           # Kubernetes manifests
│   │   ├── deploy.sh      # Individual deployment
│   │   └── cleanup.sh     # Individual cleanup
│   └── kube-app-2/        # Second Next.js application
│       ├── Dockerfile
│       ├── k8s/           # Kubernetes manifests
│       ├── deploy.sh      # Individual deployment
│       └── cleanup.sh     # Individual cleanup
├── k8s-shared/
│   ├── deploy-all.sh      # Deploy both applications
│   ├── cleanup-all.sh     # Clean up both applications
│   └── ingress.yaml       # Shared ingress configuration
└── README.md
```

## 🔧 Deployment Options

### Option 1: Deploy Both Apps Together (Recommended)

```bash
# Deploy both applications at once
./k8s-shared/deploy-all.sh
```

### Option 2: Deploy Individual Applications

```bash
# Deploy only kube-app
cd app/kube-app
eval $(minikube docker-env)
./deploy.sh

# Deploy only kube-app-2
cd app/kube-app-2
eval $(minikube docker-env)
./deploy.sh
```

### Option 3: Manual Deployment

```bash
# Build and deploy kube-app
cd app/kube-app
eval $(minikube docker-env)
docker build -t kube-app:latest .
kubectl apply -k k8s/

# Build and deploy kube-app-2
cd app/kube-app-2
eval $(minikube docker-env)
docker build -t kube-app-2:latest .
kubectl apply -k k8s/

# Deploy shared ingress
kubectl apply -f k8s-shared/ingress.yaml
```

## 🌐 Access Methods

### Method 1: Ingress (Recommended)

```bash
# Start minikube tunnel (keep running)
minikube tunnel

# Access applications
curl http://localhost/kube-app
curl http://localhost/kube-app-2
```

### Method 2: Port Forwarding

```bash
# Access kube-app
kubectl port-forward service/kube-app-service 8080:80 -n kube-app
# Visit: http://localhost:8080

# Access kube-app-2 (in another terminal)
kubectl port-forward service/kube-app-2-service 8081:80 -n kube-app
# Visit: http://localhost:8081
```

## 📊 Monitoring and Management

### Check Application Status

```bash
# View all resources in kube-app namespace
kubectl get all -n kube-app

# Check pods
kubectl get pods -n kube-app

# Check services
kubectl get services -n kube-app

# Check ingress
kubectl get ingress -n kube-app
```

### View Application Logs

```bash
# View logs for kube-app
kubectl logs -l app=kube-app -n kube-app

# View logs for kube-app-2
kubectl logs -l app=kube-app-2 -n kube-app

# View logs for a specific pod
kubectl logs <pod-name> -n kube-app
```

### Scale Applications

```bash
# Scale kube-app
kubectl scale deployment kube-app --replicas=5 -n kube-app

# Scale kube-app-2
kubectl scale deployment kube-app-2 --replicas=3 -n kube-app
```

## 🧹 Cleanup

### Clean Up Everything

```bash
# Remove both applications and ingress
./k8s-shared/cleanup-all.sh
```

### Clean Up Individual Applications

```bash
# Clean up only kube-app
cd app/kube-app
./cleanup.sh

# Clean up only kube-app-2
cd app/kube-app-2
./cleanup.sh
```

### Stop Minikube

```bash
# Stop the cluster
minikube stop

# Delete the cluster (optional)
minikube delete
```

## 🔍 Troubleshooting

### Common Issues

1. **Ingress Not Working**
   ```bash
   # Check if ingress controller is running
   kubectl get pods -n ingress-nginx
   
   # Check ingress status
   kubectl get ingress -n kube-app
   ```

2. **Applications Not Accessible**
   ```bash
   # Check if pods are running
   kubectl get pods -n kube-app
   
   # Check service endpoints
   kubectl get endpoints -n kube-app
   ```

3. **Docker Build Issues**
   ```bash
   # Make sure you're using minikube's Docker daemon
   eval $(minikube docker-env)
   
   # Check Docker context
   docker context ls
   ```

4. **Port Already in Use**
   ```bash
   # Check what's using port 80
   sudo lsof -i :80
   
   # Stop minikube tunnel and restart
   # (Ctrl+C in tunnel terminal, then run minikube tunnel again)
   ```

### Debug Commands

```bash
# Check cluster status
minikube status

# Check events
kubectl get events -n kube-app --sort-by='.lastTimestamp'

# Check ingress controller logs
kubectl logs -n ingress-nginx -l app.kubernetes.io/name=ingress-nginx

# Check node resources
kubectl describe nodes
```

## ⚙️ Configuration Details

### Resource Limits

Both applications use the same resource configuration:
- **Requests**: 100m CPU, 128Mi memory
- **Limits**: 200m CPU, 256Mi memory

### Health Checks

- **Liveness Probe**: HTTP GET `/` every 10s
- **Readiness Probe**: HTTP GET `/` every 5s

### Security

- **Non-root user**: Applications run as user 1001
- **Read-only filesystem**: Enhanced security
- **Dropped capabilities**: All Linux capabilities dropped

## 🔄 Development Workflow

### Making Changes

1. **Update Application Code**
   ```bash
   # Make changes to your Next.js app
   cd app/kube-app
   # Edit files...
   ```

2. **Rebuild and Redeploy**
   ```bash
   # Rebuild Docker image
   eval $(minikube docker-env)
   docker build -t kube-app:latest .
   
   # Redeploy
   kubectl rollout restart deployment/kube-app -n kube-app
   ```

3. **Verify Changes**
   ```bash
   # Check rollout status
   kubectl rollout status deployment/kube-app -n kube-app
   
   # Access the application
   curl http://localhost/kube-app
   ```

### Hot Reloading (Development)

For development with hot reloading:

```bash
# Run locally with port forwarding
kubectl port-forward service/kube-app-service 8080:80 -n kube-app

# In another terminal, run Next.js in development mode
cd app/kube-app
npm run dev
```

## 🚀 Production Considerations

For production deployment, consider:

1. **Image Registry**: Push to a container registry
2. **Secrets Management**: Use Kubernetes secrets for sensitive data
3. **ConfigMaps**: Use ConfigMaps for configuration
4. **Persistent Storage**: Add persistent volumes if needed
5. **Monitoring**: Set up monitoring and alerting
6. **Backup**: Implement backup strategies
7. **Security**: Enable network policies and RBAC
8. **SSL/TLS**: Configure HTTPS with certificates
9. **Load Balancing**: Use proper load balancers
10. **Auto-scaling**: Implement HPA (Horizontal Pod Autoscaler)

## 📚 Additional Resources

- [Minikube Documentation](https://minikube.sigs.k8s.io/docs/)
- [Kubernetes Ingress Documentation](https://kubernetes.io/docs/concepts/services-networking/ingress/)
- [NGINX Ingress Controller](https://kubernetes.github.io/ingress-nginx/)
- [Next.js Docker Deployment](https://nextjs.org/docs/deployment#docker-image) 