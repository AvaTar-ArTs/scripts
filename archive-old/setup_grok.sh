#!/usr/bin/env bash
# ========================================
# 🚀 Grok CLI Setup Script for macOS
# ========================================
# Automated installation and configuration
# Optimized for Intel macOS with Bun/Node.js

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
GROK_CLI_PACKAGE="@vibe-kit/grok-cli"
GROK_CONFIG_DIR="$HOME/.grok"
GROK_CONFIG_FILE="$GROK_CONFIG_DIR/user-settings.json"
ENV_LOADER="$HOME/.env.d/loader.sh"

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check system requirements
check_requirements() {
    print_status "Checking system requirements..."
    
    # Check if we're on macOS
    if [[ "$OSTYPE" != "darwin"* ]]; then
        print_error "This script is designed for macOS only"
        exit 1
    fi
    
    # Check architecture
    ARCH=$(uname -m)
    if [[ "$ARCH" != "x86_64" ]]; then
        print_warning "This script is optimized for Intel macOS (x86_64). You're running on $ARCH"
    fi
    
    # Check for Bun or Node.js
    if command_exists bun; then
        PACKAGE_MANAGER="bun"
        print_success "Found Bun $(bun --version)"
    elif command_exists node; then
        PACKAGE_MANAGER="npm"
        print_success "Found Node.js $(node --version)"
    else
        print_error "Neither Bun nor Node.js found. Please install one of them first:"
        echo "  Bun: curl -fsSL https://bun.sh/install | bash"
        echo "  Node.js: https://nodejs.org/"
        exit 1
    fi
}

# Function to install Grok CLI
install_grok_cli() {
    print_status "Installing Grok CLI..."
    
    if [[ "$PACKAGE_MANAGER" == "bun" ]]; then
        bun add -g "$GROK_CLI_PACKAGE"
    else
        npm install -g "$GROK_CLI_PACKAGE"
    fi
    
    print_success "Grok CLI installed successfully"
}

# Function to check if API key exists
check_api_key() {
    print_status "Checking for XAI API key..."
    
    # Source the environment loader if it exists
    if [[ -f "$ENV_LOADER" ]]; then
        source "$ENV_LOADER" llm-apis
    fi
    
    if [[ -n "$XAI_API_KEY" ]]; then
        print_success "Found XAI API key in environment"
        return 0
    else
        print_warning "XAI_API_KEY not found in environment"
        return 1
    fi
}

# Function to create Grok configuration
create_grok_config() {
    print_status "Creating Grok configuration..."
    
    # Create .grok directory
    mkdir -p "$GROK_CONFIG_DIR"
    
    # Create user settings
    cat > "$GROK_CONFIG_FILE" << EOF
{
  "apiKey": "${XAI_API_KEY:-}",
  "defaultModel": "grok-2",
  "maxTokens": 4000,
  "temperature": 0.7,
  "stream": true,
  "timeout": 30000,
  "retries": 3,
  "verbose": false,
  "theme": "auto",
  "editor": "auto",
  "autoSave": true,
  "historySize": 100,
  "conversationMode": true,
  "systemPrompt": "You are Grok, an AI assistant. Be helpful, accurate, and concise.",
  "customPrompts": {
    "code": "Write clean, well-documented code with proper error handling.",
    "debug": "Help debug this code by identifying issues and providing solutions.",
    "explain": "Explain this concept in simple terms with examples.",
    "refactor": "Refactor this code to improve readability and performance."
  }
}
EOF
    
    # Set proper permissions
    chmod 600 "$GROK_CONFIG_FILE"
    
    print_success "Grok configuration created at $GROK_CONFIG_FILE"
}

# Function to update shell configuration
update_shell_config() {
    print_status "Updating shell configuration..."
    
    # Check if GROK_API_KEY is already in .zshrc
    if grep -q "GROK_API_KEY" "$HOME/.zshrc" 2>/dev/null; then
        print_warning "GROK_API_KEY already exists in .zshrc"
    else
        # Add GROK_API_KEY export to .zshrc
        echo "" >> "$HOME/.zshrc"
        echo "# Grok CLI Configuration" >> "$HOME/.zshrc"
        echo "export GROK_API_KEY=\"\$XAI_API_KEY\"" >> "$HOME/.zshrc"
        print_success "Added GROK_API_KEY to .zshrc"
    fi
}

# Function to test installation
test_installation() {
    print_status "Testing Grok CLI installation..."
    
    if command_exists grok; then
        print_success "Grok CLI is available"
        
        # Test with a simple command
        print_status "Running test command..."
        if grok --help >/dev/null 2>&1; then
            print_success "Grok CLI is working correctly"
        else
            print_warning "Grok CLI installed but may need API key configuration"
        fi
    else
        print_error "Grok CLI not found in PATH"
        return 1
    fi
}

# Function to create aliases
create_aliases() {
    print_status "Creating useful aliases..."
    
    # Add aliases to .zshrc
    cat >> "$HOME/.zshrc" << 'EOF'

# Grok CLI Aliases
alias grok-help="grok --help"
alias grok-version="grok --version"
alias grok-config="cat ~/.grok/user-settings.json | jq ."
alias grok-edit="nano ~/.grok/user-settings.json"
alias grok-test="grok 'Write a simple hello world program in Python'"
alias grok-code="grok 'Write clean, well-documented code for: '"
alias grok-debug="grok 'Help debug this code: '"
alias grok-explain="grok 'Explain this concept in simple terms: '"
alias grok-refactor="grok 'Refactor this code to improve it: '"

# Quick Grok functions
grok-quick() {
    if [ $# -eq 0 ]; then
        echo "Usage: grok-quick 'your question'"
        return 1
    fi
    grok "$*"
}

grok-file() {
    if [ $# -eq 0 ]; then
        echo "Usage: grok-file <filename>"
        return 1
    fi
    if [ -f "$1" ]; then
        grok "Analyze this file: $(cat "$1")"
    else
        echo "File not found: $1"
        return 1
    fi
}
EOF
    
    print_success "Aliases and functions added to .zshrc"
}

# Function to create desktop integration
create_desktop_integration() {
    print_status "Creating desktop integration files..."
    
    # Create Applications directory entry
    mkdir -p "$HOME/Applications/Grok CLI"
    
    # Create a simple launcher script
    cat > "$HOME/Applications/Grok CLI/Grok Terminal.command" << 'EOF'
#!/bin/bash
# Grok CLI Terminal Launcher
cd "$HOME"
source ~/.zshrc
echo "🚀 Grok CLI Terminal Ready!"
echo "Type 'grok' followed by your question to get started."
echo "Try: grok 'Write a Python script to calculate fibonacci numbers'"
echo ""
exec zsh
EOF
    
    chmod +x "$HOME/Applications/Grok CLI/Grok Terminal.command"
    
    print_success "Desktop integration created"
}

# Function to show usage examples
show_usage_examples() {
    echo ""
    echo -e "${CYAN}🎉 Grok CLI Setup Complete!${NC}"
    echo ""
    echo -e "${BLUE}Usage Examples:${NC}"
    echo "  grok 'Write a Python script to sort a list'"
    echo "  grok 'Explain how machine learning works'"
    echo "  grok-code 'a function to validate email addresses'"
    echo "  grok-debug 'this broken Python code'"
    echo "  grok-file script.py"
    echo "  grok-quick 'What is the capital of France?'"
    echo ""
    echo -e "${BLUE}Configuration:${NC}"
    echo "  grok-config    # View current configuration"
    echo "  grok-edit      # Edit configuration"
    echo "  grok-test      # Run a test command"
    echo ""
    echo -e "${BLUE}Desktop Integration:${NC}"
    echo "  Open 'Grok Terminal' from Applications folder"
    echo ""
    echo -e "${YELLOW}Note:${NC} Make sure to reload your shell or run 'source ~/.zshrc' to use the new aliases."
}

# Main execution
main() {
    echo -e "${PURPLE}🚀 Grok CLI Setup Script for macOS${NC}"
    echo -e "${CYAN}=====================================${NC}"
    echo ""
    
    check_requirements
    install_grok_cli
    
    if check_api_key; then
        create_grok_config
        update_shell_config
        create_aliases
        create_desktop_integration
        test_installation
        show_usage_examples
    else
        print_warning "Please set your XAI_API_KEY in ~/.env.d/llm-apis.env and run this script again"
        echo "Or manually set: export GROK_API_KEY='your_api_key_here'"
    fi
    
    echo ""
    print_success "Setup completed! 🎉"
}

# Run main function
main "$@"
