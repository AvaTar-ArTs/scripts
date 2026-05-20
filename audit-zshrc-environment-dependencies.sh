#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail

# ====================================================================
# .zshrc Audit Script - Check what exists vs what's configured
# ====================================================================
# Run this on your Mac to scan all dependencies
# Usage: chmod +x ~/zshrc_audit.sh && zsh ~/zshrc_audit.sh

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo "======================================================================"
echo "🔍 ZSHRC CONFIGURATION AUDIT"
echo "======================================================================"
echo ""

MISSING_COUNT=0
EXISTS_COUNT=0
WARNINGS_COUNT=0

check_path() {
    local path="$1"
    local description="$2"
    local is_critical="${3:-no}"
    
    if [[ -e "$path" ]]; then
        echo "${GREEN}✓${NC} EXISTS: $description"
        echo "   Path: $path"
        EXISTS_COUNT=$((EXISTS_COUNT + 1))
    else
        if [[ "$is_critical" == "yes" ]]; then
            echo "${RED}✗ MISSING (CRITICAL):${NC} $description"
            echo "   Path: $path"
            MISSING_COUNT=$((MISSING_COUNT + 1))
        else
            echo "${YELLOW}⚠ MISSING (Optional):${NC} $description"
            echo "   Path: $path"
            WARNINGS_COUNT=$((WARNINGS_COUNT + 1))
        fi
    fi
    echo ""
}

check_command() {
    local cmd="$1"
    local description="$2"
    
    if command -v "$cmd" &>/dev/null; then
        echo "${GREEN}✓${NC} INSTALLED: $description"
        echo "   Command: $cmd"
        echo "   Location: $(which $cmd)"
        EXISTS_COUNT=$((EXISTS_COUNT + 1))
    else
        echo "${YELLOW}⚠ NOT INSTALLED:${NC} $description"
        echo "   Command: $cmd"
        WARNINGS_COUNT=$((WARNINGS_COUNT + 1))
    fi
    echo ""
}

echo "======================================================================"
echo "📂 DIRECTORY STRUCTURE"
echo "======================================================================"
echo ""

check_path "$HOME/.oh-my-zsh" "Oh-My-Zsh installation" "yes"
check_path "$HOME/.oh-my-zsh/custom" "Oh-My-Zsh custom directory"
check_path "$HOME/.oh-my-zsh/cache" "Oh-My-Zsh cache directory"
check_path "$HOME/.env.d" "Modular environment directory"
check_path "$HOME/.env.d/aliases.sh" "Environment aliases file"
check_path "$HOME/.env.d/llm-apis.env" "LLM API keys file"

echo "======================================================================"
echo "🐍 PYTHON ENVIRONMENT"
echo "======================================================================"
echo ""

check_path "$HOME/global_python_env" "Global Python environment" "yes"
check_path "$HOME/global_python_env/bin/python" "Python binary in global env" "yes"
check_path "$HOME/pythons" "Personal Python scripts directory"

if [[ -d "$HOME/global_python_env" && -f "$HOME/global_python_env/bin/python" ]]; then
    echo "${BLUE}ℹ Python Environment Details:${NC}"
    PYTHON_VERSION=$("$HOME/global_python_env/bin/python" --version 2>&1)
    echo "   Version: $PYTHON_VERSION"
    echo ""
fi

echo "======================================================================"
echo "📦 PACKAGE MANAGERS & TOOLS"
echo "======================================================================"
echo ""

check_command "brew" "Homebrew package manager"
check_command "mamba" "Mamba (conda alternative)"
check_command "conda" "Conda"

check_path "/usr/local/bin/brew" "Homebrew binary (Intel Mac)"
check_path "$HOME/miniforge3" "Miniforge installation"
check_path "$HOME/miniforge3/bin/mamba" "Mamba binary"

echo "======================================================================"
echo "🚀 DEVELOPMENT TOOLS"
echo "======================================================================"
echo ""

check_path "$HOME/.bun" "Bun installation"
check_path "$HOME/.bun/bin" "Bun binaries"
check_command "bun" "Bun runtime"

check_path "$HOME/go" "Go workspace (GOPATH)"
check_path "$HOME/go/bin" "Go binaries"
check_command "go" "Go programming language"

check_path "$HOME/.cargo" "Rust Cargo installation"
check_path "$HOME/.cargo/bin" "Rust binaries"
check_command "cargo" "Rust package manager"

check_path "$HOME/.nvm" "Node Version Manager"
check_path "$HOME/.nvm/nvm.sh" "NVM script"

check_path "$HOME/.local/bin" "Local user binaries (pipx)"
check_command "pipx" "Python package installer"

echo "======================================================================"
echo "🔧 CUSTOM SCRIPTS & ALIASES"
echo "======================================================================"
echo ""

check_path "$HOME/ai_aliases.sh" "AI automation aliases"
check_path "$HOME/api-setup" "API setup script"
check_path "$HOME/pythons/Multi-Modal.py" "Multi-Modal Python script"

echo "======================================================================"
echo "🔌 INTEGRATIONS"
echo "======================================================================"
echo ""

check_path "$HOME/.iterm2_shell_integration.zsh" "iTerm2 shell integration"
check_command "ngrok" "Ngrok tunneling tool"

echo "======================================================================"
echo "🔐 SECURITY & ENVIRONMENT FILES"
echo "======================================================================"
echo ""

check_path "$HOME/.env" "Environment variables file"

if [[ -f "$HOME/.env" ]]; then
    PERMS=$(stat -f "%A" "$HOME/.env" 2>/dev/null)
    if [[ "$PERMS" == "600" ]]; then
        echo "${GREEN}✓${NC} Correct permissions (600) on ~/.env"
    else
        echo "${RED}✗ SECURITY WARNING:${NC} ~/.env has permissions $PERMS (should be 600)"
        echo "   Fix with: chmod 600 ~/.env"
    fi
    echo ""
fi

if [[ -f "$HOME/.env.d/llm-apis.env" ]]; then
    PERMS=$(stat -f "%A" "$HOME/.env.d/llm-apis.env" 2>/dev/null)
    if [[ "$PERMS" == "600" ]]; then
        echo "${GREEN}✓${NC} Correct permissions (600) on ~/.env.d/llm-apis.env"
    else
        echo "${RED}✗ SECURITY WARNING:${NC} ~/.env.d/llm-apis.env has permissions $PERMS (should be 600)"
        echo "   Fix with: chmod 600 ~/.env.d/llm-apis.env"
    fi
    echo ""
fi

echo "======================================================================"
echo "🔍 OH-MY-ZSH PLUGINS"
echo "======================================================================"
echo ""

PLUGINS=(
    "git"
    "zsh-autosuggestions"
    "zsh-syntax-highlighting"
    "brew"
    "macos"
    "python"
    "docker"
)

for plugin in "${PLUGINS[@]}"; do
    if [[ "$plugin" == "zsh-autosuggestions" || "$plugin" == "zsh-syntax-highlighting" ]]; then
        PLUGIN_PATH="$HOME/.oh-my-zsh/custom/plugins/$plugin"
    else
        PLUGIN_PATH="$HOME/.oh-my-zsh/plugins/$plugin"
    fi
    
    if [[ -d "$PLUGIN_PATH" ]]; then
        echo "${GREEN}✓${NC} Plugin installed: $plugin"
    else
        echo "${YELLOW}⚠ Plugin missing:${NC} $plugin"
        if [[ "$plugin" == "zsh-autosuggestions" ]]; then
            echo "   Install: git clone https://github.com/zsh-users/zsh-autosuggestions \${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"
        elif [[ "$plugin" == "zsh-syntax-highlighting" ]]; then
            echo "   Install: git clone https://github.com/zsh-users/zsh-syntax-highlighting.git \${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting"
        fi
    fi
done
echo ""

echo "======================================================================"
echo "📊 PATH ANALYSIS"
echo "======================================================================"
echo ""

echo "${BLUE}Current PATH entries:${NC}"
IFS=':' read -rA path_entries <<< "$PATH"
for entry in "${path_entries[@]}"; do
    if [[ -d "$entry" ]]; then
        echo "${GREEN}✓${NC} $entry"
    else
        echo "${RED}✗${NC} $entry (doesn't exist)"
    fi
done
echo ""

echo "${BLUE}Checking for duplicate PATH entries:${NC}"
DUPLICATES=$(echo "$PATH" | tr ':' '\n' | sort | uniq -d)
if [[ -z "$DUPLICATES" ]]; then
    echo "${GREEN}✓${NC} No duplicates found"
else
    echo "${YELLOW}⚠ Duplicate entries found:${NC}"
    echo "$DUPLICATES"
fi
echo ""

echo "======================================================================"
echo "💡 RECOMMENDATIONS"
echo "======================================================================"
echo ""

if [[ ! -d "$HOME/global_python_env" ]]; then
    echo "${RED}🔴 CRITICAL:${NC} Global Python environment missing!"
    echo "   Your .zshrc expects: $HOME/global_python_env"
    echo "   Create it: python3 -m venv ~/global_python_env"
    echo ""
fi

if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    echo "${RED}🔴 CRITICAL:${NC} Oh-My-Zsh is not installed!"
    echo "   Install: sh -c \"\$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)\""
    echo ""
fi

if [[ ! -d "$HOME/miniforge3" ]]; then
    echo "${RED}🔴 CRITICAL:${NC} Miniforge/Mamba not found!"
    echo "   Download from: https://github.com/conda-forge/miniforge"
    echo ""
fi

if [[ ! -f "$HOME/ai_aliases.sh" ]]; then
    echo "${YELLOW}💡 OPTIONAL:${NC} ai_aliases.sh referenced but not found"
    echo "   Either create this file or comment out line 180-183 in .zshrc"
    echo ""
fi

echo "======================================================================"
echo "📈 SUMMARY"
echo "======================================================================"
echo ""
echo "${GREEN}✓ Found:${NC} $EXISTS_COUNT items"
echo "${RED}✗ Missing (Critical):${NC} $MISSING_COUNT items"
echo "${YELLOW}⚠ Missing (Optional):${NC} $WARNINGS_COUNT items"
echo ""

if [[ $MISSING_COUNT -eq 0 ]]; then
    echo "${GREEN}🎉 All critical components are present!${NC}"
else
    echo "${RED}⚠️  Some critical components are missing. Review the output above.${NC}"
fi

echo ""
echo "======================================================================"
