# ConfigMaps & Secrets - Imperative Commands

## ConfigMaps

### Create ConfigMap from Literals

```bash
# Single key-value
kubectl create configmap myconfig --from-literal=key1=value1

# Multiple key-values
kubectl create configmap myconfig --from-literal=key1=value1 --from-literal=key2=value2

# With special characters (use quotes)
kubectl create configmap myconfig --from-literal=db.host=mysql --from-literal=db.port=3306
```

### Create ConfigMap from Files

```bash
# From a single file (filename becomes key)
kubectl create configmap myconfig --from-file=config.txt

# From file with custom key name
kubectl create configmap myconfig --from-file=mykey=config.txt

# From multiple files
kubectl create configmap myconfig --from-file=file1.txt --from-file=file2.txt

# From entire directory
kubectl create configmap myconfig --from-file=/path/to/config/dir/
```

### Create ConfigMap from Env File

```bash
# From .env style file (key=value per line)
kubectl create configmap myconfig --from-env-file=app.env
```

### Generate YAML (Don't Create)

```bash
# Generate ConfigMap YAML
kubectl create configmap myconfig --from-literal=key=value --dry-run=client -o yaml

# Save to file
kubectl create configmap myconfig --from-literal=key=value --dry-run=client -o yaml > cm.yaml
```

### ConfigMap Management

```bash
# List ConfigMaps
kubectl get configmaps
kubectl get cm

# Describe ConfigMap
kubectl describe configmap myconfig

# Get ConfigMap YAML
kubectl get cm myconfig -o yaml

# View ConfigMap data
kubectl get cm myconfig -o jsonpath='{.data}'

# Delete ConfigMap
kubectl delete configmap myconfig
```

---

## Secrets

### Secret Types

| Type | Description |
|------|-------------|
| `generic` | Arbitrary key-value data |
| `docker-registry` | Docker registry credentials |
| `tls` | TLS certificate and key |

### Create Generic Secret from Literals

```bash
# Single key-value
kubectl create secret generic mysecret --from-literal=password=secret123

# Multiple key-values
kubectl create secret generic mysecret --from-literal=username=admin --from-literal=password=secret123
```

### Create Secret from Files

```bash
# From file
kubectl create secret generic mysecret --from-file=ssh-key=id_rsa

# From multiple files
kubectl create secret generic mysecret --from-file=username.txt --from-file=password.txt

# From directory
kubectl create secret generic mysecret --from-file=/path/to/secrets/
```

### Create Docker Registry Secret

```bash
# For private registry authentication
kubectl create secret docker-registry regcred \
  --docker-server=registry.example.com \
  --docker-username=myuser \
  --docker-password=mypassword \
  --docker-email=user@example.com
```

### Create TLS Secret

```bash
# From cert and key files
kubectl create secret tls tls-secret --cert=tls.crt --key=tls.key
```

### Generate YAML (Don't Create)

```bash
# Generate Secret YAML
kubectl create secret generic mysecret --from-literal=password=secret --dry-run=client -o yaml

# Save to file
kubectl create secret generic mysecret --from-literal=password=secret --dry-run=client -o yaml > secret.yaml
```

### Secret Management

```bash
# List Secrets
kubectl get secrets

# Describe Secret (values hidden)
kubectl describe secret mysecret

# Get Secret YAML (values base64 encoded)
kubectl get secret mysecret -o yaml

# Decode secret value
kubectl get secret mysecret -o jsonpath='{.data.password}' | base64 -d

# Delete Secret
kubectl delete secret mysecret
```

---

## Using ConfigMaps in Pods

### As Environment Variables

```bash
# Generate pod YAML and edit to add envFrom
kubectl run myapp --image=nginx --dry-run=client -o yaml > pod.yaml
```

```yaml
# Add to pod spec:
spec:
  containers:
  - name: myapp
    image: nginx
    envFrom:
    - configMapRef:
        name: myconfig
```

### Single Key as Env Variable

```yaml
spec:
  containers:
  - name: myapp
    image: nginx
    env:
    - name: DATABASE_HOST
      valueFrom:
        configMapKeyRef:
          name: myconfig
          key: db.host
```

### As Volume Mount

```yaml
spec:
  containers:
  - name: myapp
    image: nginx
    volumeMounts:
    - name: config-volume
      mountPath: /etc/config
  volumes:
  - name: config-volume
    configMap:
      name: myconfig
```

---

## Using Secrets in Pods

### As Environment Variables

```yaml
spec:
  containers:
  - name: myapp
    image: nginx
    envFrom:
    - secretRef:
        name: mysecret
```

### Single Key as Env Variable

```yaml
spec:
  containers:
  - name: myapp
    image: nginx
    env:
    - name: DB_PASSWORD
      valueFrom:
        secretKeyRef:
          name: mysecret
          key: password
```

### As Volume Mount

```yaml
spec:
  containers:
  - name: myapp
    image: nginx
    volumeMounts:
    - name: secret-volume
      mountPath: /etc/secrets
      readOnly: true
  volumes:
  - name: secret-volume
    secret:
      secretName: mysecret
```

### ImagePullSecrets (for private registries)

```yaml
spec:
  imagePullSecrets:
  - name: regcred
  containers:
  - name: myapp
    image: registry.example.com/myimage:latest
```

---

## Common CKAD Scenarios

### Scenario 1: Create ConfigMap and use in Pod
```bash
# Create ConfigMap
kubectl create configmap app-config --from-literal=APP_ENV=production --from-literal=LOG_LEVEL=info

# Create pod that uses it (generate YAML and edit)
kubectl run webapp --image=nginx --dry-run=client -o yaml > webapp.yaml
# Edit to add envFrom with configMapRef, then apply
kubectl apply -f webapp.yaml
```

### Scenario 2: Create Secret for database credentials
```bash
# Create secret
kubectl create secret generic db-creds --from-literal=DB_USER=admin --from-literal=DB_PASS=supersecret

# Verify (decode)
kubectl get secret db-creds -o jsonpath='{.data.DB_PASS}' | base64 -d
```

### Scenario 3: Mount config file into container
```bash
# Create ConfigMap from file
echo "server.port=8080" > app.properties
kubectl create configmap app-props --from-file=app.properties

# Pod mounts it at /etc/config/app.properties
```

### Scenario 4: Update ConfigMap and verify
```bash
# Edit ConfigMap
kubectl edit configmap myconfig

# Or replace entirely
kubectl create configmap myconfig --from-literal=key=newvalue --dry-run=client -o yaml | kubectl apply -f -
```

### Scenario 5: Create Secret from file content
```bash
# Create a password file
echo -n 'mypassword' > password.txt

# Create secret (note: -n in echo to avoid newline)
kubectl create secret generic file-secret --from-file=password=password.txt
```

---

## Key Flags Reference

### ConfigMap Flags

| Flag | Description |
|------|-------------|
| `--from-literal` | Key=value pair |
| `--from-file` | File or directory |
| `--from-env-file` | Env-style file |
| `--dry-run=client` | Don't create |
| `-o yaml` | Output as YAML |

### Secret Flags

| Flag | Description |
|------|-------------|
| `--from-literal` | Key=value pair |
| `--from-file` | File or directory |
| `--docker-server` | Registry URL |
| `--docker-username` | Registry username |
| `--docker-password` | Registry password |
| `--cert` | TLS certificate file |
| `--key` | TLS key file |
| `--dry-run=client` | Don't create |
| `-o yaml` | Output as YAML |

---

## Quick Tips

1. **Base64 encoding**: Secrets are base64 encoded, NOT encrypted
   ```bash
   echo -n 'myvalue' | base64        # Encode
   echo 'bXl2YWx1ZQ==' | base64 -d   # Decode
   ```

2. **Use -n with echo**: Avoid trailing newlines in secrets
   ```bash
   echo -n 'password' > pass.txt  # No newline
   ```

3. **ConfigMap vs Secret**: Use Secrets for sensitive data (passwords, tokens, keys)

4. **Immutable ConfigMaps/Secrets** (Kubernetes 1.21+):
   ```yaml
   immutable: true  # Prevents changes, improves performance
   ```

5. **Check mounted content**:
   ```bash
   kubectl exec mypod -- cat /etc/config/key
   kubectl exec mypod -- ls /etc/secrets/
   ```
