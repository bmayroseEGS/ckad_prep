#!/bin/bash

# =============================================================================
# CKAD Practice Environment Setup Script
# =============================================================================
# This script sets up a lightweight Kubernetes environment for CKAD exam
# practice on Ubuntu/Debian systems.
#
# Components Installed:
#   - Docker (container runtime)
#   - K3s (lightweight Kubernetes)
#   - kubectl (with auto-completion)
#   - Helm (package manager)
#   - k9s (terminal UI for Kubernetes)
#   - kubectx/kubens (context/namespace switching)
#
# Usage: ./setup-machine.sh
# =============================================================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print functions
print_header() {
    echo ""
    echo -e "${BLUE}============================================${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}============================================${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}! $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_info() {
    echo -e "  $1"
}

# Check if running as root
check_sudo() {
    if [ "$EUID" -eq 0 ]; then
        print_error "Please do not run this script as root. Run as regular user with sudo access."
        exit 1
    fi

    if ! sudo -v; then
        print_error "This script requires sudo access."
        exit 1
    fi
}

# Detect OS
detect_os() {
    print_header "Detecting Operating System"

    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$ID
        VERSION=$VERSION_ID
        print_success "Detected: $PRETTY_NAME"
    else
        print_error "Cannot detect OS. This script supports Ubuntu/Debian."
        exit 1
    fi

    case $OS in
        ubuntu|debian)
            print_success "OS is supported"
            ;;
        *)
            print_warning "OS '$OS' is not officially supported. Proceed anyway? (y/n)"
            read -r response
            if [[ ! "$response" =~ ^[Yy]$ ]]; then
                exit 1
            fi
            ;;
    esac
}

# Update system packages
update_system() {
    print_header "Updating System Packages"

    sudo apt-get update -qq
    print_success "Package lists updated"

    # Install essential tools
    sudo apt-get install -y -qq curl wget git jq vim bash-completion apt-transport-https ca-certificates gnupg lsb-release
    print_success "Essential tools installed"
}

# Install Docker
install_docker() {
    print_header "Installing Docker"

    if command -v docker &> /dev/null; then
        print_warning "Docker is already installed: $(docker --version)"
        print_info "Skip Docker installation? (y/n)"
        read -r response
        if [[ "$response" =~ ^[Yy]$ ]]; then
            return 0
        fi
    fi

    print_info "Installing Docker using official script..."

    # Try official Docker script
    if curl -fsSL https://get.docker.com | sudo sh; then
        print_success "Docker installed successfully"
    else
        print_warning "Official script failed, trying apt..."
        sudo apt-get install -y docker.io
    fi

    # Add user to docker group
    sudo usermod -aG docker "$USER"
    print_success "Added $USER to docker group"

    # Start Docker
    sudo systemctl enable docker
    sudo systemctl start docker
    print_success "Docker service started"

    print_warning "NOTE: You may need to log out and back in for docker group to take effect"
}

# Install K3s
install_k3s() {
    print_header "Installing K3s (Lightweight Kubernetes)"

    if command -v k3s &> /dev/null; then
        print_warning "K3s is already installed"
        print_info "Skip K3s installation? (y/n)"
        read -r response
        if [[ "$response" =~ ^[Yy]$ ]]; then
            setup_kubectl
            return 0
        fi
    fi

    print_info "Installing K3s..."

    # Install K3s without Traefik (we'll use simpler ingress for CKAD practice)
    curl -sfL https://get.k3s.io | sh -s - --disable traefik --write-kubeconfig-mode 644

    print_success "K3s installed successfully"

    # Wait for K3s to be ready
    print_info "Waiting for K3s to be ready..."
    sleep 10

    sudo k3s kubectl wait --for=condition=Ready nodes --all --timeout=120s
    print_success "K3s cluster is ready"
}

# Setup kubectl
setup_kubectl() {
    print_header "Setting Up kubectl"

    # Create .kube directory
    mkdir -p ~/.kube

    # Copy K3s kubeconfig
    if [ -f /etc/rancher/k3s/k3s.yaml ]; then
        sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
        sudo chown "$USER:$USER" ~/.kube/config
        chmod 600 ~/.kube/config
        print_success "Kubeconfig copied to ~/.kube/config"
    fi

    # Add kubectl alias to bashrc
    if ! grep -q "alias k=kubectl" ~/.bashrc; then
        echo "" >> ~/.bashrc
        echo "# CKAD aliases" >> ~/.bashrc
        echo "alias k=kubectl" >> ~/.bashrc
        echo "complete -o default -F __start_kubectl k" >> ~/.bashrc
        print_success "Added 'k' alias for kubectl"
    fi

    # Add kubeconfig export
    if ! grep -q "KUBECONFIG" ~/.bashrc; then
        echo "export KUBECONFIG=~/.kube/config" >> ~/.bashrc
    fi

    # Setup kubectl auto-completion
    if ! grep -q "kubectl completion" ~/.bashrc; then
        echo "source <(kubectl completion bash)" >> ~/.bashrc
        print_success "kubectl auto-completion enabled"
    fi

    # Verify kubectl works
    export KUBECONFIG=~/.kube/config
    if kubectl cluster-info &> /dev/null; then
        print_success "kubectl is working"
        kubectl get nodes
    else
        print_error "kubectl cannot connect to cluster"
    fi
}

# Install Helm
install_helm() {
    print_header "Installing Helm"

    if command -v helm &> /dev/null; then
        print_warning "Helm is already installed: $(helm version --short)"
        return 0
    fi

    print_info "Installing Helm..."

    curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

    print_success "Helm installed: $(helm version --short)"

    # Add helm completion
    if ! grep -q "helm completion" ~/.bashrc; then
        echo "source <(helm completion bash)" >> ~/.bashrc
        print_success "Helm auto-completion enabled"
    fi
}

# Install k9s
install_k9s() {
    print_header "Installing k9s (Terminal UI)"

    if command -v k9s &> /dev/null; then
        print_warning "k9s is already installed: $(k9s version --short 2>/dev/null || echo 'installed')"
        return 0
    fi

    print_info "Installing k9s..."

    # Get latest release
    K9S_VERSION=$(curl -s https://api.github.com/repos/derailed/k9s/releases/latest | jq -r '.tag_name')

    # Download and install
    curl -sL "https://github.com/derailed/k9s/releases/download/${K9S_VERSION}/k9s_Linux_amd64.tar.gz" | sudo tar xz -C /usr/local/bin k9s

    print_success "k9s installed"
}

# Install kubectx and kubens
install_kubectx() {
    print_header "Installing kubectx/kubens"

    if command -v kubectx &> /dev/null; then
        print_warning "kubectx is already installed"
        return 0
    fi

    print_info "Installing kubectx and kubens..."

    sudo git clone https://github.com/ahmetb/kubectx /opt/kubectx 2>/dev/null || true
    sudo ln -sf /opt/kubectx/kubectx /usr/local/bin/kubectx
    sudo ln -sf /opt/kubectx/kubens /usr/local/bin/kubens

    print_success "kubectx and kubens installed"
}

# Create CKAD practice namespaces
create_practice_namespaces() {
    print_header "Creating CKAD Practice Namespaces"

    export KUBECONFIG=~/.kube/config

    # Create namespaces for different practice scenarios
    namespaces=("ckad-practice" "ckad-dev" "ckad-prod" "ckad-network")

    for ns in "${namespaces[@]}"; do
        if kubectl get namespace "$ns" &> /dev/null; then
            print_warning "Namespace '$ns' already exists"
        else
            kubectl create namespace "$ns"
            print_success "Created namespace: $ns"
        fi
    done

    # Set default namespace to ckad-practice
    kubectl config set-context --current --namespace=ckad-practice
    print_success "Default namespace set to 'ckad-practice'"
}

# Create helpful vim config for YAML
setup_vim() {
    print_header "Setting Up Vim for YAML Editing"

    cat > ~/.vimrc << 'EOF'
" CKAD Exam Vim Configuration
set tabstop=2
set shiftwidth=2
set expandtab
set autoindent
set smartindent
set paste
set number
set cursorline

" YAML specific
autocmd FileType yaml setlocal ts=2 sts=2 sw=2 expandtab

" Highlight trailing whitespace
highlight ExtraWhitespace ctermbg=red guibg=red
match ExtraWhitespace /\s\+$/
EOF

    print_success "Vim configured for YAML editing"
}

# Print summary
print_summary() {
    print_header "Installation Summary"

    echo ""
    echo -e "${GREEN}CKAD Practice Environment Setup Complete!${NC}"
    echo ""
    echo "Installed Components:"
    echo "  - Docker:    $(docker --version 2>/dev/null || echo 'Not installed')"
    echo "  - K3s:       $(k3s --version 2>/dev/null | head -1 || echo 'Not installed')"
    echo "  - kubectl:   $(kubectl version --client --short 2>/dev/null || echo 'Not installed')"
    echo "  - Helm:      $(helm version --short 2>/dev/null || echo 'Not installed')"
    echo "  - k9s:       $(k9s version --short 2>/dev/null || echo 'Installed')"
    echo "  - kubectx:   $(command -v kubectx &>/dev/null && echo 'Installed' || echo 'Not installed')"
    echo ""
    echo "Practice Namespaces:"
    echo "  - ckad-practice (default)"
    echo "  - ckad-dev"
    echo "  - ckad-prod"
    echo "  - ckad-network"
    echo ""
    echo "Quick Start:"
    echo "  1. Log out and log back in (for docker group)"
    echo "  2. Run: source ~/.bashrc"
    echo "  3. Test: k get nodes"
    echo ""
    echo "Useful Commands:"
    echo "  k          - alias for kubectl"
    echo "  k9s        - terminal UI for Kubernetes"
    echo "  kubectx    - switch contexts"
    echo "  kubens     - switch namespaces"
    echo ""
    echo "Happy CKAD studying!"
}

# Main execution
main() {
    echo ""
    echo -e "${BLUE}╔═══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║     CKAD Practice Environment Setup Script                ║${NC}"
    echo -e "${BLUE}╚═══════════════════════════════════════════════════════════╝${NC}"
    echo ""

    check_sudo
    detect_os

    echo ""
    echo "This script will install:"
    echo "  - Docker"
    echo "  - K3s (Lightweight Kubernetes)"
    echo "  - kubectl with auto-completion"
    echo "  - Helm"
    echo "  - k9s (terminal UI)"
    echo "  - kubectx/kubens"
    echo ""
    echo "Continue? (y/n)"
    read -r response

    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        echo "Aborted."
        exit 0
    fi

    update_system
    install_docker
    install_k3s
    setup_kubectl
    install_helm
    install_k9s
    install_kubectx
    create_practice_namespaces
    setup_vim
    print_summary
}

main "$@"
