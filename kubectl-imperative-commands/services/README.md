# Services - Imperative Commands

## Service Types Overview

| Type | Description |
|------|-------------|
| ClusterIP | Internal cluster access only (default) |
| NodePort | Exposes on each node's IP at a static port |
| LoadBalancer | External load balancer (cloud providers) |
| ExternalName | Maps to external DNS name |

## Exposing Resources

### Expose a Deployment

```bash
# ClusterIP (default)
kubectl expose deployment nginx --port=80

# Specify target port (container port)
kubectl expose deployment nginx --port=80 --target-port=8080

# NodePort
kubectl expose deployment nginx --port=80 --type=NodePort

# NodePort with specific port
kubectl expose deployment nginx --port=80 --type=NodePort --node-port=30080

# LoadBalancer
kubectl expose deployment nginx --port=80 --type=LoadBalancer

# With custom name
kubectl expose deployment nginx --port=80 --name=nginx-svc
```

### Expose a Pod

```bash
# Expose a pod directly
kubectl expose pod nginx --port=80

# With specific type
kubectl expose pod nginx --port=80 --type=NodePort
```

### Expose a ReplicaSet

```bash
kubectl expose rs nginx --port=80
```

## Generate YAML (Don't Create)

```bash
# Generate service YAML
kubectl expose deployment nginx --port=80 --dry-run=client -o yaml

# Save to file
kubectl expose deployment nginx --port=80 --type=NodePort --dry-run=client -o yaml > svc.yaml
```

## Create Service Directly

```bash
# Create ClusterIP service
kubectl create service clusterip nginx --tcp=80:80

# Create NodePort service
kubectl create service nodeport nginx --tcp=80:80

# Create LoadBalancer service
kubectl create service loadbalancer nginx --tcp=80:80

# Create ExternalName service
kubectl create service externalname external-svc --external-name=api.example.com
```

## Service Management

```bash
# List services
kubectl get services
kubectl get svc
kubectl get svc -o wide

# Describe service
kubectl describe service nginx

# Get service YAML
kubectl get svc nginx -o yaml

# Delete service
kubectl delete service nginx

# Delete all services
kubectl delete svc --all
```

## Testing Services

```bash
# Get service endpoint
kubectl get endpoints nginx

# Test from within cluster
kubectl run curl --image=curlimages/curl --rm -it --restart=Never -- curl http://nginx

# Test with service DNS
kubectl run curl --image=curlimages/curl --rm -it --restart=Never -- curl http://nginx.default.svc.cluster.local

# Check DNS resolution
kubectl run nslookup --image=busybox --rm -it --restart=Never -- nslookup nginx
```

## Service DNS

Services are accessible via DNS within the cluster:

```
<service-name>.<namespace>.svc.cluster.local
```

Examples:
```bash
# Same namespace - short name works
curl http://nginx

# Full DNS name
curl http://nginx.default.svc.cluster.local

# Cross-namespace
curl http://nginx.other-namespace.svc.cluster.local
```

## Port Forwarding (Local Testing)

```bash
# Forward local port to service
kubectl port-forward service/nginx 8080:80

# Forward to pod directly
kubectl port-forward pod/nginx 8080:80

# Listen on all interfaces
kubectl port-forward --address 0.0.0.0 service/nginx 8080:80
```

## Common CKAD Scenarios

### Scenario 1: Expose deployment and test
```bash
# Create deployment
kubectl create deployment webapp --image=nginx --replicas=3

# Expose as ClusterIP
kubectl expose deployment webapp --port=80

# Test connectivity
kubectl run curl --image=curlimages/curl --rm -it --restart=Never -- curl http://webapp
```

### Scenario 2: Create NodePort for external access
```bash
kubectl expose deployment webapp --port=80 --type=NodePort
# Find assigned port
kubectl get svc webapp -o jsonpath='{.spec.ports[0].nodePort}'
```

### Scenario 3: Multi-port service (requires YAML)
```bash
# Generate base YAML
kubectl expose deployment webapp --port=80 --dry-run=client -o yaml > svc.yaml
# Edit to add additional ports
```

### Scenario 4: Headless service (for StatefulSets)
```bash
# Generate YAML and set clusterIP: None
kubectl create service clusterip headless-svc --tcp=80:80 --dry-run=client -o yaml > headless.yaml
# Edit: add clusterIP: None
```

### Scenario 5: Service with selector targeting specific labels
```bash
# Generate YAML and modify selector
kubectl expose deployment webapp --port=80 --dry-run=client -o yaml > svc.yaml
# Edit selector to match specific pod labels
```

## Network Policies (Related)

```bash
# Network policies require YAML, but useful to know:
kubectl get networkpolicies
kubectl get netpol

kubectl describe networkpolicy my-policy
```

## Key Flags Reference

| Flag | Description |
|------|-------------|
| `--port` | Service port (what clients connect to) |
| `--target-port` | Container port (where traffic goes) |
| `--type` | Service type (ClusterIP, NodePort, LoadBalancer) |
| `--node-port` | Specific NodePort (30000-32767) |
| `--name` | Custom service name |
| `--tcp` | Port mapping for create service |
| `--external-name` | External DNS for ExternalName type |
| `--dry-run=client` | Don't create, just validate |
| `-o yaml` | Output as YAML |

## Quick Tips

1. **Default type is ClusterIP** - no need to specify for internal services

2. **Port vs TargetPort**:
   - `--port`: The port the service listens on
   - `--target-port`: The port on the container (defaults to --port if not specified)

3. **NodePort range**: 30000-32767 (can be auto-assigned or specified)

4. **Service discovery**: Use DNS names, not IPs:
   ```bash
   # Good
   curl http://my-service
   # Bad (IPs can change)
   curl http://10.96.45.123
   ```

5. **Debug connectivity**:
   ```bash
   # Check endpoints exist
   kubectl get endpoints my-service

   # If empty, check pod labels match service selector
   kubectl get pods --show-labels
   kubectl describe svc my-service
   ```
