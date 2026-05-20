#!/bin/bash
# Harbor-Aider Enhanced Environment Setup Script

set -e  # Exit on any error

echo "🚀 Harbor-Aider Enhanced Environment Setup"
echo "========================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check prerequisites
check_prerequisites() {
    log_info "Checking prerequisites..."
    
    # Check for Docker
    if ! command -v docker &>/dev/null; then
        log_error "Docker is not installed. Please install Docker Desktop first."
        exit 1
    else
        log_success "Docker is installed: $(docker --version)"
    fi
    
    # Check for Docker Compose
    if ! command -v docker-compose &>/dev/null && ! (docker --version &>/dev/null && docker compose version &>/dev/null); then
        log_error "Docker Compose is not installed."
        exit 1
    else
        log_success "Docker Compose is available"
    fi
    
    # Check for Harbor
    if [[ ! -f "$HOME/.harbor/harbor.sh" ]]; then
        log_error "Harbor is not installed. Please install Harbor first."
        echo "Visit: https://github.com/av/harbor"
        exit 1
    else
        log_success "Harbor is installed"
    fi
    
    # Check for Aider
    if ! command -v aider &>/dev/null; then
        log_warn "Aider is not installed. Installing Aider..."
        if command -v pip &>/dev/null; then
            pip install aider-chat
            log_success "Aider installed successfully"
        else
            log_error "Neither pip nor Aider found. Please install Python and pip first."
            exit 1
        fi
    else
        log_success "Aider is installed: $(aider --version 2>/dev/null | head -n1 || echo 'version unknown')"
    fi
}

# Function to verify the enhanced environment
verify_setup() {
    log_info "Verifying Harbor-Aider enhanced environment..."
    
    # Check if our configuration files exist
    if [[ -f "/Users/steven/harbor-aider-enhanced/config/aider.conf.harbor.yml" ]]; then
        log_success "Enhanced Aider configuration found"
    else
        log_error "Enhanced Aider configuration not found"
        return 1
    fi
    
    if [[ -f "/Users/steven/harbor-aider-enhanced/config/aider-config.env" ]]; then
        log_success "Harbor-Aider configuration found"
    else
        log_error "Harbor-Aider configuration not found"
        return 1
    fi
    
    # Check if scripts are executable
    if [[ -x "/Users/steven/harbor-aider-enhanced/scripts/aider-integration.sh" ]]; then
        log_success "Integration script is executable"
    else
        log_error "Integration script is not executable"
        return 1
    fi
    
    if [[ -x "/Users/steven/harbor-aider-enhanced/scripts/aider-enhancements.sh" ]]; then
        log_success "Enhancement script is executable"
    else
        log_error "Enhancement script is not executable"
        return 1
    fi
    
    log_success "All components verified successfully!"
}

# Function to show next steps
show_next_steps() {
    echo ""
    log_info "🎉 Harbor-Aider Enhanced Environment Setup Complete!"
    echo ""
    echo "Your enhanced Harbor-Aider development environment is ready!"
    echo ""
    echo "Next steps:"
    echo "1. Start Harbor with Aider-optimized services:"
    echo "   harbor up ollama webui"
    echo ""
    echo "2. Create your first project workspace:"
    echo "   bash /Users/steven/harbor-aider-enhanced/scripts/aider-integration.sh create-workspace my-first-project"
    echo ""
    echo "3. Navigate to your project:"
    echo "   cd \$HOME/ai-workspaces/my-first-project"
    echo ""
    echo "4. Start Aider:"
    echo "   aider"
    echo ""
    echo "Alternative quick start:"
    echo "   bash /Users/steven/harbor-aider-enhanced/scripts/aider-integration.sh start-env"
    echo ""
    echo "Documentation:"
    echo "- Main README: /Users/steven/harbor-aider-enhanced/README.md"
    echo "- Getting Started Guide: /Users/steven/harbor-aider-enhanced/docs/getting-started.md"
    echo ""
    log_success "Happy coding with your enhanced AI-assisted development environment!"
}

# Main execution
main() {
    log_info "Starting Harbor-Aider enhanced environment setup..."
    
    check_prerequisites
    verify_setup
    show_next_steps
}

# Run the main function
main "$@"