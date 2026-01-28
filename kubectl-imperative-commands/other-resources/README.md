# Other Resources - Imperative Commands

This guide covers Namespaces, ServiceAccounts, ResourceQuotas, LimitRanges, and other commonly used resources in the CKAD exam.

---

## Namespaces

### Create Namespace

```bash
# Create namespace
kubectl create namespace myns
kubectl create ns myns

# Generate YAML
kubectl create ns myns --dry-run=client -o yaml
```

### Namespace Management

```bash
# List namespaces
kubectl get namespaces
kubectl get ns

# Describe namespace
kubectl describe ns myns

# Delete namespace (deletes all resources in it!)
kubectl delete ns myns

# Set default namespace for context
kubectl config set-context --current --namespace=myns

# View current namespace
kubectl config view --minify | grep namespace
```

### Working with Namespaces

```bash
# Run command in specific namespace
kubectl get pods -n myns
kubectl get pods --namespace=myns

# Run command in all namespaces
kubectl get pods -A
kubectl get pods --all-namespaces

# Create resource in namespace
kubectl run nginx --image=nginx -n myns
kubectl create deployment nginx --image=nginx -n myns
```

---

## ServiceAccounts

### Create ServiceAccount

```bash
# Create ServiceAccount
kubectl create serviceaccount mysa
kubectl create sa mysa

# Create in specific namespace
kubectl create sa mysa -n myns

# Generate YAML
kubectl create sa mysa --dry-run=client -o yaml
```

### ServiceAccount Management

```bash
# List ServiceAccounts
kubectl get serviceaccounts
kubectl get sa

# Describe ServiceAccount
kubectl describe sa mysa

# Get ServiceAccount YAML
kubectl get sa mysa -o yaml

# Delete ServiceAccount
kubectl delete sa mysa
```

### Using ServiceAccount in Pod

```bash
# Generate pod YAML and edit
kubectl run mypod --image=nginx --dry-run=client -o yaml > pod.yaml
```

```yaml
# Add to pod spec:
spec:
  serviceAccountName: mysa
  containers:
  - name: mypod
    image: nginx
```

---

## Roles and RoleBindings (RBAC)

### Create Role

```bash
# Create Role with specific permissions
kubectl create role pod-reader --verb=get,list,watch --resource=pods

# Role for specific resource names
kubectl create role pod-reader --verb=get --resource=pods --resource-name=mypod

# Generate YAML
kubectl create role pod-reader --verb=get,list --resource=pods --dry-run=client -o yaml
```

### Create ClusterRole

```bash
# Create ClusterRole (cluster-wide)
kubectl create clusterrole pod-reader --verb=get,list,watch --resource=pods

# Generate YAML
kubectl create clusterrole pod-reader --verb=get,list --resource=pods --dry-run=client -o yaml
```

### Create RoleBinding

```bash
# Bind Role to ServiceAccount
kubectl create rolebinding sa-pod-reader --role=pod-reader --serviceaccount=default:mysa

# Bind Role to User
kubectl create rolebinding user-pod-reader --role=pod-reader --user=jane

# Bind Role to Group
kubectl create rolebinding group-pod-reader --role=pod-reader --group=developers

# Generate YAML
kubectl create rolebinding sa-pod-reader --role=pod-reader --serviceaccount=default:mysa --dry-run=client -o yaml
```

### Create ClusterRoleBinding

```bash
# Bind ClusterRole to ServiceAccount
kubectl create clusterrolebinding sa-pod-reader --clusterrole=pod-reader --serviceaccount=default:mysa

# Bind ClusterRole to User
kubectl create clusterrolebinding user-pod-reader --clusterrole=pod-reader --user=jane

# Generate YAML
kubectl create clusterrolebinding sa-pod-reader --clusterrole=pod-reader --serviceaccount=default:mysa --dry-run=client -o yaml
```

### RBAC Management

```bash
# List Roles
kubectl get roles
kubectl get clusterroles

# List RoleBindings
kubectl get rolebindings
kubectl get clusterrolebindings

# Check permissions
kubectl auth can-i get pods --as=system:serviceaccount:default:mysa
kubectl auth can-i create deployments --as=jane
kubectl auth can-i '*' '*'  # Check if admin
```

---

## ResourceQuotas

### Create ResourceQuota

```bash
# Generate YAML (no imperative create with values)
kubectl create quota myquota --dry-run=client -o yaml > quota.yaml
```

```yaml
# Edit quota.yaml:
apiVersion: v1
kind: ResourceQuota
metadata:
  name: myquota
spec:
  hard:
    pods: "10"
    requests.cpu: "4"
    requests.memory: 4Gi
    limits.cpu: "8"
    limits.memory: 8Gi
    configmaps: "10"
    secrets: "10"
    services: "5"
```

### ResourceQuota Management

```bash
# List ResourceQuotas
kubectl get resourcequotas
kubectl get quota

# Describe (shows usage)
kubectl describe quota myquota

# Delete
kubectl delete quota myquota
```

---

## LimitRanges

LimitRanges set default and min/max resource limits for containers.

```yaml
# limitrange.yaml
apiVersion: v1
kind: LimitRange
metadata:
  name: mylimits
spec:
  limits:
  - default:          # Default limits
      cpu: 500m
      memory: 256Mi
    defaultRequest:   # Default requests
      cpu: 100m
      memory: 128Mi
    max:              # Maximum allowed
      cpu: "2"
      memory: 1Gi
    min:              # Minimum allowed
      cpu: 50m
      memory: 64Mi
    type: Container
```

### LimitRange Management

```bash
# Apply LimitRange
kubectl apply -f limitrange.yaml

# List LimitRanges
kubectl get limitranges
kubectl get limits

# Describe
kubectl describe limits mylimits

# Delete
kubectl delete limits mylimits
```

---

## Ingress

### Create Ingress

```bash
# Create simple ingress
kubectl create ingress myingress --rule="host.com/path=service:port"

# With multiple rules
kubectl create ingress myingress \
  --rule="foo.com/=svc1:80" \
  --rule="bar.com/app=svc2:8080"

# With TLS
kubectl create ingress myingress \
  --rule="host.com/=svc:80,tls=my-tls-secret"

# Generate YAML
kubectl create ingress myingress --rule="host.com/=svc:80" --dry-run=client -o yaml
```

### Ingress Management

```bash
# List Ingresses
kubectl get ingress
kubectl get ing

# Describe
kubectl describe ingress myingress

# Delete
kubectl delete ingress myingress
```

---

## PersistentVolumeClaims (PVC)

### Create PVC (YAML Required)

```yaml
# pvc.yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: mypvc
spec:
  accessModes:
    - ReadWriteOnce    # RWO, ROX, RWX
  resources:
    requests:
      storage: 1Gi
  storageClassName: standard  # Optional
```

### PVC Management

```bash
# Apply PVC
kubectl apply -f pvc.yaml

# List PVCs
kubectl get pvc

# Describe
kubectl describe pvc mypvc

# Delete
kubectl delete pvc mypvc
```

### Using PVC in Pod

```yaml
spec:
  containers:
  - name: app
    image: nginx
    volumeMounts:
    - name: data
      mountPath: /data
  volumes:
  - name: data
    persistentVolumeClaim:
      claimName: mypvc
```

---

## NetworkPolicies

NetworkPolicies control pod-to-pod traffic (requires CNI support).

```yaml
# networkpolicy.yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: deny-all
spec:
  podSelector: {}        # Applies to all pods
  policyTypes:
  - Ingress
  - Egress
  # No ingress/egress rules = deny all
```

```yaml
# Allow specific traffic
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-frontend
spec:
  podSelector:
    matchLabels:
      app: backend
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: frontend
    ports:
    - port: 8080
```

### NetworkPolicy Management

```bash
# Apply
kubectl apply -f networkpolicy.yaml

# List
kubectl get networkpolicies
kubectl get netpol

# Describe
kubectl describe netpol deny-all

# Delete
kubectl delete netpol deny-all
```

---

## Common CKAD Scenarios

### Scenario 1: Create ServiceAccount and use in Pod
```bash
# Create SA
kubectl create sa app-sa

# Create pod using SA
kubectl run myapp --image=nginx --dry-run=client -o yaml > pod.yaml
# Edit to add: serviceAccountName: app-sa
kubectl apply -f pod.yaml

# Verify
kubectl get pod myapp -o jsonpath='{.spec.serviceAccountName}'
```

### Scenario 2: Grant SA permission to list pods
```bash
# Create SA
kubectl create sa pod-lister

# Create Role
kubectl create role pod-list-role --verb=get,list --resource=pods

# Bind Role to SA
kubectl create rolebinding pod-list-binding --role=pod-list-role --serviceaccount=default:pod-lister

# Test
kubectl auth can-i list pods --as=system:serviceaccount:default:pod-lister
```

### Scenario 3: Create namespace with resource limits
```bash
# Create namespace
kubectl create ns limited

# Apply ResourceQuota
kubectl apply -f quota.yaml -n limited

# Apply LimitRange
kubectl apply -f limitrange.yaml -n limited
```

### Scenario 4: Create Ingress for multiple services
```bash
kubectl create ingress multi-app \
  --rule="app.com/api=api-svc:8080" \
  --rule="app.com/web=web-svc:80"
```

### Scenario 5: Deny all network traffic to namespace
```bash
# Create deny-all policy
kubectl apply -f - <<EOF
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: deny-all
  namespace: secure-ns
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
EOF
```

---

## Labels and Annotations

### Labels

```bash
# Add label to resource
kubectl label pod mypod app=web

# Add label to multiple resources
kubectl label pods --all env=dev

# Update existing label (overwrite)
kubectl label pod mypod app=api --overwrite

# Remove label
kubectl label pod mypod app-

# Select by label
kubectl get pods -l app=web
kubectl get pods -l 'app in (web,api)'
kubectl get pods -l app!=web
```

### Annotations

```bash
# Add annotation
kubectl annotate pod mypod description="My application pod"

# Update annotation
kubectl annotate pod mypod description="Updated" --overwrite

# Remove annotation
kubectl annotate pod mypod description-

# View annotations
kubectl get pod mypod -o jsonpath='{.metadata.annotations}'
```

---

## Quick Reference

### Common Verbs for RBAC

| Verb | Description |
|------|-------------|
| `get` | Read single resource |
| `list` | List resources |
| `watch` | Watch for changes |
| `create` | Create resources |
| `update` | Update resources |
| `patch` | Partial update |
| `delete` | Delete resources |
| `*` | All verbs |

### Access Modes for PVC

| Mode | Description |
|------|-------------|
| `ReadWriteOnce` (RWO) | Single node read-write |
| `ReadOnlyMany` (ROX) | Multiple nodes read-only |
| `ReadWriteMany` (RWX) | Multiple nodes read-write |

### Quick Tips

1. **Check API resources**: `kubectl api-resources`
2. **Check verbs for resource**: `kubectl api-resources -o wide`
3. **Explain any resource**: `kubectl explain pod.spec.serviceAccountName`
4. **Fast namespace switch**: `kubens myns` (if kubens installed)
5. **View all resources in namespace**: `kubectl get all -n myns`
