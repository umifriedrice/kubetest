# Multi-Application Kubernetes Setup

This project demonstrates how to run multiple applications in a single Kubernetes cluster with path-based routing.

## 🏗️ Architecture Overview

```
localhost/
├── /kube-app      → Routes to kube-app (Next.js application)
└── /kube-app-2    → Routes to kube-app-2 (Next.js application)
```

Both applications run in the same Kubernetes namespace (`kube-app`) and are accessible through a single ingress controller with path-based routing.

## Project Structure

```
kubetest/
├── app/
│   ├── kube-app/          # First Next.js application
│   │   ├── Dockerfile
│   │   ├── k8s/           # Kubernetes manifests for kube-app
│   │   ├── deploy.sh      # Individual deployment script
│   │   └── cleanup.sh     # Individual cleanup script
│   └── kube-app-2/        # Second Next.js application
│       ├── Dockerfile
│       ├── k8s/           # Kubernetes manifests for kube-app-2
│       ├── deploy.sh      # Individual deployment script
│       └── cleanup.sh     # Individual cleanup script
├── k8s-shared/
│   ├── deploy-all.sh      # Deploy both applications
│   ├── cleanup-all.sh     # Clean up both applications
│   └── ingress.yaml       # Shared ingress configuration
└── README.md
```

## Applications

### kube-app
- **Namespace**: `kube-app`
- **Service**: `kube-app-service`
- **Path**: `/kube-app` (with ingress)
- **Port**: 8080 (when port-forwarding)

### kube-app-2
- **Namespace**: `kube-app` (shared with kube-app)
- **Service**: `kube-app-2-service`
- **Path**: `/kube-app-2` (with ingress)
- **Port**: 8081 (when port-forwarding)

## Prerequisites

- Docker Desktop or Docker Engine
- Minikube (for local Kubernetes cluster)
- kubectl CLI tool

## Quick Start

### 1. Start Kubernetes Cluster

```bash
minikube start --driver=docker
```

### 2. Enable Ingress Controller

```bash
minikube addons enable ingress
```

### 3. Deploy All Applications

```bash
# Deploy both applications at once
./k8s-shared/deploy-all.sh
```

### 4. Access Applications

#### Option A: Using Ingress (Recommended)

```bash
# Start minikube tunnel (keep this running)
minikube tunnel

# Access applications
curl http://localhost/kube-app
curl http://localhost/kube-app-2
```

#### Option B: Using Port Forwarding

```bash
# Access kube-app
kubectl port-forward service/kube-app-service 8080:80 -n kube-app
# Visit: http://localhost:8080

# Access kube-app-2 (in another terminal)
kubectl port-forward service/kube-app-2-service 8081:80 -n kube-app
# Visit: http://localhost:8081
```

## Individual Application Management

### Deploy Single Application

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

### Clean Up Single Application

```bash
# Clean up only kube-app
cd app/kube-app
./cleanup.sh

# Clean up only kube-app-2
cd app/kube-app-2
./cleanup.sh
```

## Monitoring and Management

### Check All Resources

```bash
# View all pods in kube-app namespace
kubectl get pods -n kube-app

# View all services in kube-app namespace
kubectl get services -n kube-app

# View ingress
kubectl get ingress -n kube-app
```

### View Logs

```bash
# View logs for kube-app
kubectl logs -l app=kube-app -n kube-app

# View logs for kube-app-2
kubectl logs -l app=kube-app-2 -n kube-app
```

### Scale Applications

```bash
# Scale kube-app
kubectl scale deployment kube-app --replicas=5 -n kube-app

# Scale kube-app-2
kubectl scale deployment kube-app-2 --replicas=3 -n kube-app
```

## 🛑 Stopping and Cleaning Up Everything

To fully stop and clean up your local Kubernetes environment:

### 1. Clean Up Kubernetes Resources

Remove all deployed applications and ingress:

```bash
./k8s-shared/cleanup-all.sh
```

Or, to clean up a single app:

```bash
cd app/kube-app
./cleanup.sh
# or for kube-app-2
cd app/kube-app-2
./cleanup.sh
```

### 2. Stop the Ingress Tunnel (if running)

If you started `minikube tunnel` in a terminal, stop it by closing the terminal or running:

```bash
pkill -f "minikube tunnel"
```

### 3. Stop Minikube

This will stop the local Kubernetes cluster:

```bash
minikube stop
```

### 4. (Optional) Delete the Minikube Cluster

If you want to remove the cluster entirely:

```bash
minikube delete
```

## Architecture Benefits

### Shared Namespace
- Both applications run in the same namespace for easier management
- Shared ingress configuration
- Simplified networking and service discovery

### Path-Based Routing
- Single domain with different paths
- No need for multiple hostnames
- Easier SSL/TLS configuration

### Independent Scaling
- Scale applications independently
- Different resource limits per application
- Isolated failure domains

### Shared Infrastructure
- Single Kubernetes cluster
- Shared ingress controller
- Centralized monitoring and logging

## Troubleshooting

### Common Issues

1. **Image Pull Errors**: Make sure to run `eval $(minikube docker-env)` before building images
2. **Port Conflicts**: Use different ports for port-forwarding (8080, 8081)
3. **Ingress Not Working**: Ensure NGINX Ingress Controller is enabled and tunnel is running
4. **Resource Limits**: Check if your cluster has enough resources

### Debug Commands

```bash
# Check cluster status
minikube status

# Check events
kubectl get events -n kube-app --sort-by='.lastTimestamp'

# Check ingress controller
kubectl get pods -n ingress-nginx

# Check node resources
kubectl describe nodes
```

## Next Steps

- Add more applications following the same pattern
- Implement shared services (databases, message queues)
- Add monitoring and logging infrastructure
- Set up CI/CD pipelines for automated deployment
- Implement security policies and network policies
- Configure SSL/TLS certificates for production 