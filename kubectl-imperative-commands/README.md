# kubectl Imperative Commands

Imperative commands are essential for the CKAD exam - they save significant time compared to writing YAML from scratch.

## Why Use Imperative Commands?

- **Speed**: Create resources in seconds
- **Generate YAML**: Use `--dry-run=client -o yaml` to generate templates
- **Less error-prone**: No YAML indentation issues

## Common Patterns

### Dry Run + YAML Output

Always remember this pattern to generate YAML without creating the resource:

```bash
kubectl <command> --dry-run=client -o yaml > resource.yaml
```

## Command Categories

| Category | Description |
|----------|-------------|
| [Pods](pods.md) | Creating and managing pods |
| [Deployments](deployments.md) | Deployment operations |
| [Services](services.md) | Exposing applications |
| [ConfigMaps & Secrets](configmaps-secrets.md) | Configuration management |
| [Jobs & CronJobs](jobs-cronjobs.md) | Batch workloads |
| [Other Resources](other-resources.md) | Namespaces, ServiceAccounts, etc. |

## Quick Reference

```bash
# Set alias first!
alias k=kubectl

# Pod
k run nginx --image=nginx

# Deployment
k create deployment nginx --image=nginx --replicas=3

# Service (ClusterIP)
k expose deployment nginx --port=80

# Service (NodePort)
k expose deployment nginx --port=80 --type=NodePort

# ConfigMap
k create configmap myconfig --from-literal=key=value

# Secret
k create secret generic mysecret --from-literal=password=secret

# Job
k create job myjob --image=busybox -- echo "hello"

# CronJob
k create cronjob mycron --image=busybox --schedule="*/1 * * * *" -- echo "hello"
```
