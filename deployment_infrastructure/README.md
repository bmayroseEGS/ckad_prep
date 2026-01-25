# CKAD Practice Environment Setup

This directory contains scripts to set up a lightweight Kubernetes environment for CKAD exam practice.

## Prerequisites

- Ubuntu or Debian-based Linux system
- sudo access
- Internet connection

## Quick Start

```bash
# Make executable and run
chmod +x setup-machine.sh
./setup-machine.sh
```

## What Gets Installed

| Component | Purpose |
|-----------|---------|
| Docker | Container runtime |
| K3s | Lightweight Kubernetes distribution |
| kubectl | Kubernetes CLI with auto-completion |
| Helm | Kubernetes package manager |
| k9s | Terminal UI for Kubernetes |
| kubectx/kubens | Context and namespace switching |

## Practice Namespaces

The setup creates these namespaces for practice:

| Namespace | Use Case |
|-----------|----------|
| `ckad-practice` | Default namespace for general practice |
| `ckad-dev` | Simulating dev environment |
| `ckad-prod` | Simulating production environment |
| `ckad-network` | Network policy practice |

## Post-Installation

After running the setup script:

```bash
# Log out and back in (for docker group)
# Or run:
newgrp docker

# Reload bash configuration
source ~/.bashrc

# Verify setup
k get nodes
k get ns
```

## Useful Aliases & Commands

```bash
# kubectl alias (configured automatically)
k get pods

# Terminal UI
k9s

# Switch namespace
kubens ckad-dev

# Switch context (if multiple clusters)
kubectx
```

## Vim Configuration

The script configures vim for YAML editing:
- 2-space indentation
- Auto-indent
- Line numbers
- Tab expansion to spaces

## Cleanup

To uninstall K3s:

```bash
/usr/local/bin/k3s-uninstall.sh
```

To remove Docker:

```bash
sudo apt-get purge docker-ce docker-ce-cli containerd.io
sudo rm -rf /var/lib/docker
```
