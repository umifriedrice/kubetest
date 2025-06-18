# Multi-Application Kubernetes Setup

This project demonstrates how to run multiple applications in a single Kubernetes cluster using separate namespaces.

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
│   └── cleanup-all.sh     # Clean up both applications
└── README.md
```

## Applications

### kube-app
- **Namespace**: `kube-app`
- **Service**: `kube-app-service`
- **Port**: 8080 (when port-forwarding)
- **Host**: `kube-app.local` (with ingress)

### kube-app-2
- **Namespace**: `kube-app-2`
- **Service**: `kube-app-2-service`
- **Port**: 8081 (when port-forwarding)
- **Host**: `kube-app-2.local` (with ingress)

## Prerequisites

- Docker Desktop or Docker Engine
- Minikube (for local Kubernetes cluster)
- kubectl CLI tool

## Quick Start

### 1. Start Kubernetes Cluster

```bash
minikube start --driver=docker
```

### 2. Deploy All Applications

```bash
# Deploy both applications at once
./k8s-shared/deploy-all.sh
```

### 3. Access Applications

```bash
# Access kube-app
kubectl port-forward service/kube-app-service 8080:80 -n kube-app
# Visit: http://localhost:8080

# Access kube-app-2 (in another terminal)
kubectl port-forward service/kube-app-2-service 8081:80 -n kube-app-2
# Visit: http://localhost:8081
```

### 4. Clean Up

```bash
# Clean up both applications
./k8s-shared/cleanup-all.sh
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
# View all pods across namespaces
kubectl get pods --all-namespaces

# View all services across namespaces
kubectl get services --all-namespaces

# View all ingress across namespaces
kubectl get ingress --all-namespaces
```

### Check Specific Application

```bash
# Check kube-app resources
kubectl get all -n kube-app

# Check kube-app-2 resources
kubectl get all -n kube-app-2
```

### View Logs

```bash
# View logs for kube-app
kubectl logs -l app=kube-app -n kube-app

# View logs for kube-app-2
kubectl logs -l app=kube-app-2 -n kube-app-2
```

## Using Ingress (Optional)

If you want to use ingress instead of port-forwarding:

### 1. Enable NGINX Ingress Controller

```bash
minikube addons enable ingress
```

### 2. Add Host Entries

Add these lines to your `/etc/hosts` file:
```
127.0.0.1 kube-app.local
127.0.0.1 kube-app-2.local
```

### 3. Access via Ingress

```bash
# Get the ingress IP
kubectl get ingress --all-namespaces

# Access applications
curl http://kube-app.local
curl http://kube-app-2.local
```

## Architecture Benefits

### Namespace Isolation
- Each application runs in its own namespace
- No resource naming conflicts
- Easy to manage and monitor separately

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
3. **Namespace Issues**: Ensure you're targeting the correct namespace
4. **Resource Limits**: Check if your cluster has enough resources

### Debug Commands

```bash
# Check cluster status
minikube status

# Check events
kubectl get events --all-namespaces --sort-by='.lastTimestamp'

# Check node resources
kubectl describe nodes

# Check pod details
kubectl describe pod <pod-name> -n <namespace>
```

## Next Steps

- Add more applications following the same pattern
- Implement shared services (databases, message queues)
- Add monitoring and logging infrastructure
- Set up CI/CD pipelines for automated deployment
- Implement security policies and network policies 