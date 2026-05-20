#!/usr/bin/env bash
# grok_integration.sh
# Integrates Grok CLI with your existing AI infrastructure

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

print_header() {
    echo -e "${CYAN}========================================${NC}"
    echo -e "  🤖 ${BLUE}Grok CLI Integration Setup${NC}"
    echo -e "${CYAN}========================================${NC}"
    echo ""
}

print_success() { echo -e "${GREEN}✅ $1${NC}"; }
print_warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
print_error() { echo -e "${RED}❌ $1${NC}"; }
print_info() { echo -e "${BLUE}ℹ️  $1${NC}"; }

# Check if Grok CLI is installed
check_grok() {
    if command -v grok &> /dev/null; then
        print_success "Grok CLI is installed"
        grok --version
        return 0
    else
        print_error "Grok CLI not found"
        print_info "Installing Grok CLI..."
        npm install -g @vibe-kit/grok-cli
        print_success "Grok CLI installed"
        return 0
    fi
}

# Create aliases
create_aliases() {
    print_info "Creating convenient aliases..."
    
    # Add to .zshrc
    cat >> ~/.zshrc << 'EOF'

# Grok CLI Integration Aliases
alias grok-menu="$HOME/Documents/script/api-operations/grok_menu.sh"
alias ai-menu="$HOME/Documents/script/ai_unified_menu.sh"
alias grok-quick="grok --prompt"
alias grok-file="grok --prompt 'Analyze this file: '"
alias grok-code="grok --prompt 'Review this code: '"
alias grok-git="grok --prompt 'Analyze git status and recent commits: '"

# Quick AI access
alias ai="source ~/.env.d/loader.sh llm-apis && grok --prompt"
alias ask-grok="grok --prompt"
alias ask-ollama="ollama run llama3.1:8b"
EOF

    print_success "Aliases added to ~/.zshrc"
}

# Test integration
test_integration() {
    print_info "Testing Grok CLI integration..."
    
    # Load environment
    source ~/.env.d/loader.sh llm-apis 2>/dev/null || true
    
    # Test basic functionality
    if grok --help &> /dev/null; then
        print_success "Grok CLI is working"
    else
        print_error "Grok CLI test failed"
        return 1
    fi
    
    # Test API key
    if [ -n "$XAI_API_KEY" ]; then
        export GROK_API_KEY="$XAI_API_KEY"
        print_success "API key configured"
    else
        print_warning "XAI_API_KEY not found in environment"
    fi
}

# Create usage examples
create_examples() {
    print_info "Creating usage examples..."
    
    cat > ~/grok_examples.md << 'EOF'
# Grok CLI Usage Examples

## Quick Commands

```bash
# Quick questions
grok-quick "Explain machine learning in simple terms"

# Analyze files
grok-file "script.py"

# Code review
grok-code "function.py"

# Git analysis
grok-git

# Interactive menu
grok-menu

# Unified AI menu
ai-menu
```

## Advanced Usage

```bash
# Specific model
grok --model grok-2 --prompt "Your question"

# File analysis
grok --prompt "Review this code for bugs: $(cat script.py)"

# Git analysis
grok --prompt "Analyze this git repo: $(git status --porcelain)"
```

## Integration with Your Workflow

```bash
# Load environment and use Grok
source ~/.env.d/loader.sh llm-apis
grok --prompt "Help me debug this Python error"

# Use with your existing scripts
./Documents/script/ai_unified_menu.sh
```

## Available Models

- grok-2 (default)
- grok-code-fast-1
- grok-4-latest
EOF

    print_success "Examples created at ~/grok_examples.md"
}

# Main execution
main() {
    print_header
    
    print_info "Checking Grok CLI installation..."
    check_grok
    
    print_info "Creating aliases and shortcuts..."
    create_aliases
    
    print_info "Testing integration..."
    test_integration
    
    print_info "Creating usage examples..."
    create_examples
    
    echo ""
    print_success "🎉 Grok CLI integration complete!"
    echo ""
    echo -e "${CYAN}Next steps:${NC}"
    echo "1. Reload your shell: ${GREEN}source ~/.zshrc${NC}"
    echo "2. Try the unified menu: ${GREEN}ai-menu${NC}"
    echo "3. Quick Grok access: ${GREEN}grok-quick 'your question'${NC}"
    echo "4. Read examples: ${GREEN}cat ~/grok_examples.md${NC}"
    echo ""
    print_success "Happy coding with Grok! 🚀"
}

main "$@"
