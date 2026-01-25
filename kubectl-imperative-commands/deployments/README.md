# Deployments - Imperative Commands

## Basic Deployment Creation

```bash
# Create a deployment
kubectl create deployment nginx --image=nginx

# Create with multiple replicas
kubectl create deployment nginx --image=nginx --replicas=3

# Create with specific port
kubectl create deployment nginx --image=nginx --port=80

# Create in a specific namespace
kubectl create deployment nginx --image=nginx -n mynamespace
```

## Generate YAML (Don't Create)

```bash
# Generate deployment YAML
kubectl create deployment nginx --image=nginx --dry-run=client -o yaml

# Save to file
kubectl create deployment nginx --image=nginx --replicas=3 --dry-run=client -o yaml > deployment.yaml
```

## Scaling Deployments

```bash
# Scale to specific replica count
kubectl scale deployment nginx --replicas=5

# Scale multiple deployments
kubectl scale deployment nginx redis --replicas=3

# Scale based on current size (conditional)
kubectl scale deployment nginx --current-replicas=3 --replicas=5
```

## Updating Deployments

```bash
# Update image
kubectl set image deployment/nginx nginx=nginx:1.19

# Update image for specific container
kubectl set image deployment/nginx nginx=nginx:1.19 sidecar=busybox:1.35

# Update environment variable
kubectl set env deployment/nginx DB_HOST=mysql

# Update resources
kubectl set resources deployment/nginx --requests=cpu=100m,memory=128Mi --limits=cpu=200m,memory=256Mi
```

## Rollouts

```bash
# Check rollout status
kubectl rollout status deployment/nginx

# View rollout history
kubectl rollout history deployment/nginx

# View specific revision
kubectl rollout history deployment/nginx --revision=2

# Undo last rollout (rollback)
kubectl rollout undo deployment/nginx

# Rollback to specific revision
kubectl rollout undo deployment/nginx --to-revision=2

# Pause rollout
kubectl rollout pause deployment/nginx

# Resume rollout
kubectl rollout resume deployment/nginx

# Restart deployment (rolling restart)
kubectl rollout restart deployment/nginx
```

## Deployment Management

```bash
# List deployments
kubectl get deployments
kubectl get deploy -o wide

# Describe deployment
kubectl describe deployment nginx

# Get deployment YAML
kubectl get deployment nginx -o yaml

# Delete deployment
kubectl delete deployment nginx

# Delete all deployments
kubectl delete deployments --all
```

## Autoscaling (HPA)

```bash
# Create HPA for deployment
kubectl autoscale deployment nginx --min=2 --max=10 --cpu-percent=80

# List HPAs
kubectl get hpa

# Delete HPA
kubectl delete hpa nginx
```

## Common CKAD Scenarios

### Scenario 1: Create deployment and scale
```bash
kubectl create deployment webapp --image=nginx --replicas=3
kubectl scale deployment webapp --replicas=5
```

### Scenario 2: Update image and rollback
```bash
# Update to new version
kubectl set image deployment/webapp webapp=nginx:1.19

# Check status
kubectl rollout status deployment/webapp

# Oops! Rollback
kubectl rollout undo deployment/webapp
```

### Scenario 3: Blue-Green style update
```bash
# Create with specific labels for canary/blue-green
kubectl create deployment webapp-v1 --image=nginx:1.18 --dry-run=client -o yaml > v1.yaml
# Edit to add version labels, then apply
```

### Scenario 4: Deployment with resource limits
```bash
kubectl create deployment webapp --image=nginx --dry-run=client -o yaml > deploy.yaml
# Edit to add resources section, then apply
```

### Scenario 5: Record change cause
```bash
# Annotate deployment for history
kubectl annotate deployment nginx kubernetes.io/change-cause="Updated to nginx 1.19"
```

## Deployment Strategies (YAML Required)

These require editing YAML - use `--dry-run=client -o yaml` to generate base:

```yaml
# RollingUpdate (default)
spec:
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 25%
      maxUnavailable: 25%

# Recreate
spec:
  strategy:
    type: Recreate
```

## Key Flags Reference

| Flag | Description |
|------|-------------|
| `--image` | Container image to use |
| `--replicas` | Number of replicas |
| `--port` | Container port |
| `-n, --namespace` | Target namespace |
| `--dry-run=client` | Don't create, just validate |
| `-o yaml` | Output as YAML |
| `--current-replicas` | Precondition for scale |
| `--revision` | Specific revision for history/undo |
| `--to-revision` | Target revision for rollback |
| `--cpu-percent` | CPU threshold for HPA |
| `--min` | Minimum replicas for HPA |
| `--max` | Maximum replicas for HPA |

## Quick Tips

1. **Always check rollout status** after updates:
   ```bash
   kubectl rollout status deployment/myapp
   ```

2. **Use `--record`** (deprecated but still works) to track changes:
   ```bash
   kubectl set image deployment/nginx nginx=nginx:1.19 --record
   ```

3. **Annotate for change-cause** (preferred method):
   ```bash
   kubectl annotate deployment nginx kubernetes.io/change-cause="reason"
   ```

4. **Quick restart** to pick up ConfigMap/Secret changes:
   ```bash
   kubectl rollout restart deployment/nginx
   ```
