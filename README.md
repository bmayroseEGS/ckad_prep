# CKAD Exam Preparation

A collection of practice questions, scenarios, and exercises to prepare for the Certified Kubernetes Application Developer (CKAD) exam.

## Quick Start - Setup Practice Environment

```bash
# Clone this repo
git clone git@github.com:bmayroseEGS/ckad_prep.git
cd ckad_prep

# Run setup on Ubuntu/Debian
cd deployment_infrastructure
chmod +x setup-machine.sh
./setup-machine.sh
```

This installs K3s, kubectl, Helm, k9s, and other tools needed for CKAD practice.

See [deployment_infrastructure/](deployment_infrastructure/) for full setup details.

## Exam Domains

The CKAD exam covers the following domains:

| Domain | Weight |
|--------|--------|
| Application Design and Build | 20% |
| Application Deployment | 20% |
| Application Observability and Maintenance | 15% |
| Application Environment, Configuration and Security | 25% |
| Services and Networking | 20% |

## Repository Structure

```
ckad_prep/
├── deployment_infrastructure/     # Setup scripts for practice environment
│   ├── setup-machine.sh          # Installs K3s, kubectl, Helm, k9s
│   └── README.md
├── kubectl-imperative-commands/   # Imperative command reference
│   ├── pods/
│   ├── deployments/
│   ├── services/
│   └── ...
├── 01-application-design-build/
├── 02-application-deployment/
├── 03-observability-maintenance/
├── 04-environment-config-security/
├── 05-services-networking/
└── scenarios/
```

## Exam Tips

- The exam is **2 hours** long
- You need **66%** to pass
- Use `kubectl` imperative commands to save time
- Familiarize yourself with the [official Kubernetes documentation](https://kubernetes.io/docs/)
- Practice with `kubectl explain` to quickly find resource specs

## Useful Commands

```bash
# Set alias (saves time)
alias k=kubectl

# Generate YAML templates
kubectl run nginx --image=nginx --dry-run=client -o yaml
kubectl create deployment nginx --image=nginx --dry-run=client -o yaml

# Quick resource info
kubectl explain pod.spec.containers
```

## Resources

- [CKAD Curriculum](https://github.com/cncf/curriculum)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [kubectl Cheat Sheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)
