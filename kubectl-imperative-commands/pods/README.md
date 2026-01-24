# Pods - Imperative Commands

## Basic Pod Creation

```bash
# Create a simple pod
kubectl run nginx --image=nginx

# Create pod with a specific port exposed
kubectl run nginx --image=nginx --port=80

# Create pod with labels
kubectl run nginx --image=nginx --labels="app=web,env=prod"

# Create pod in a specific namespace
kubectl run nginx --image=nginx -n mynamespace

# Create pod with environment variables
kubectl run nginx --image=nginx --env="DB_HOST=mysql" --env="DB_PORT=3306"

# Create pod with resource requests/limits
kubectl run nginx --image=nginx --requests="cpu=100m,memory=128Mi" --limits="cpu=200m,memory=256Mi"
```

## Generate YAML (Don't Create)

```bash
# Generate pod YAML without creating
kubectl run nginx --image=nginx --dry-run=client -o yaml

# Save to file for editing
kubectl run nginx --image=nginx --dry-run=client -o yaml > pod.yaml
```

## Pod with Command Override

```bash
# Run a pod with a custom command
kubectl run busybox --image=busybox --command -- sleep 3600

# Run a pod with arguments
kubectl run busybox --image=busybox -- sleep 3600

# Run a one-off command (pod deleted after completion)
kubectl run busybox --image=busybox --rm -it --restart=Never -- wget -qO- http://nginx
```

## Interactive Pods

```bash
# Start an interactive shell
kubectl run -it busybox --image=busybox --restart=Never -- sh

# Attach to a running pod
kubectl attach mypod -it

# Execute command in running pod
kubectl exec mypod -- ls /
kubectl exec -it mypod -- sh
```

## Pod Management

```bash
# List pods
kubectl get pods
kubectl get pods -o wide
kubectl get pods --show-labels

# Describe pod (detailed info)
kubectl describe pod nginx

# Get pod YAML
kubectl get pod nginx -o yaml

# Delete pod
kubectl delete pod nginx

# Delete pod immediately (force)
kubectl delete pod nginx --grace-period=0 --force

# Delete all pods in namespace
kubectl delete pods --all -n mynamespace
```

## Pod Logs

```bash
# View logs
kubectl logs nginx

# Follow logs (stream)
kubectl logs -f nginx

# View logs from specific container (multi-container pod)
kubectl logs nginx -c sidecar

# View previous container logs (if crashed)
kubectl logs nginx --previous

# Tail last N lines
kubectl logs nginx --tail=100
```

## Temporary Debug Pods

```bash
# Quick curl test pod
kubectl run curl --image=curlimages/curl --rm -it --restart=Never -- curl http://nginx

# DNS lookup test
kubectl run nslookup --image=busybox --rm -it --restart=Never -- nslookup nginx

# Network debug pod
kubectl run netshoot --image=nicolaka/netshoot --rm -it --restart=Never -- bash
```

## Common CKAD Scenarios

### Scenario 1: Create pod and expose port
```bash
kubectl run webapp --image=nginx --port=80
```

### Scenario 2: Create pod with specific restart policy
```bash
kubectl run oneshot --image=busybox --restart=Never -- echo "done"
```

### Scenario 3: Multi-container pod (requires YAML)
```bash
# Generate base YAML, then edit to add sidecar
kubectl run multi --image=nginx --dry-run=client -o yaml > multi-pod.yaml
# Edit the file to add additional containers
```

### Scenario 4: Pod with init container (requires YAML)
```bash
kubectl run myapp --image=nginx --dry-run=client -o yaml > init-pod.yaml
# Edit to add initContainers section
```

## Key Flags Reference

| Flag | Description |
|------|-------------|
| `--image` | Container image to use |
| `--port` | Port to expose |
| `--labels` | Labels to apply (key=value) |
| `--env` | Environment variables |
| `--requests` | Resource requests |
| `--limits` | Resource limits |
| `--restart` | Restart policy (Always, OnFailure, Never) |
| `--rm` | Delete pod after it exits |
| `-it` | Interactive terminal |
| `--command` | Use command (vs args) |
| `--dry-run=client` | Don't create, just validate |
| `-o yaml` | Output as YAML |
