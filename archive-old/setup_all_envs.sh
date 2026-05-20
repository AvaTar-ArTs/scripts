#!/usr/bin/env bash
set -euo pipefail

echo "╔══════════════════════════════════════════════════════════════════╗"
echo "║                                                                  ║"
echo "║       🐍 MAMBA ENVIRONMENT SETUP - ALL ENVIRONMENTS 🐍         ║"
echo "║                                                                  ║"
echo "╚══════════════════════════════════════════════════════════════════╝"
echo ""

ENVS_DIR="$(cd "$(dirname "$0")" && pwd)"
TOTAL_ENVS=5
CREATED=0
FAILED=0

# Check if mamba is installed
if ! command -v mamba &> /dev/null; then
    echo "❌ Mamba not found. Installing Miniforge..."

    # Detect OS
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        if [[ "$(uname -m)" == "arm64" ]]; then
            INSTALLER="Miniforge3-MacOSX-arm64.sh"
        else
            INSTALLER="Miniforge3-MacOSX-x86_64.sh"
        fi
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        # Linux
        INSTALLER="Miniforge3-Linux-x86_64.sh"
    else
        echo "❌ Unsupported OS: $OSTYPE"
        exit 1
    fi

    # Download and install
    cd /tmp
    curl -L -O "https://github.com/conda-forge/miniforge/releases/latest/download/$INSTALLER"
    bash "$INSTALLER" -b -p "$HOME/miniforge3"

    # Initialize
    "$HOME/miniforge3/bin/mamba" init zsh bash

    echo "✅ Miniforge installed. Please restart your shell and run this script again."
    echo "   Or run: source ~/.zshrc"
    exit 0
fi

echo "✅ Mamba found: $(which mamba)"
echo ""

# Function to create environment
create_env() {
    local env_file="$1"
    local env_name="$(basename "$env_file" .yml)"

    echo "───────────────────────────────────────────────────────────────────"
    echo "📦 Creating environment: $env_name"
    echo "───────────────────────────────────────────────────────────────────"

    # Check if environment already exists
    if mamba env list | grep -q "^$env_name "; then
        echo "⚠️  Environment '$env_name' already exists"
        read -p "   Remove and recreate? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            echo "🗑️  Removing existing environment..."
            mamba env remove -n "$env_name" -y
        else
            echo "⏭️  Skipping $env_name"
            return 0
        fi
    fi

    # Create environment
    if mamba env create -f "$env_file"; then
        echo "✅ Environment '$env_name' created successfully"
        CREATED=$((CREATED + 1))

        # Test activation
        echo "🧪 Testing activation..."
        if eval "$(mamba shell hook -s zsh)" && mamba activate "$env_name" && python --version; then
            echo "✅ Environment activates correctly"
            mamba deactivate
        else
            echo "⚠️  Environment created but activation test failed"
        fi

        return 0
    else
        echo "❌ Failed to create environment '$env_name'"
        FAILED=$((FAILED + 1))
        return 1
    fi
}

# Create all environments
echo "🚀 Creating $TOTAL_ENVS environments..."
echo ""

create_env "$ENVS_DIR/automation-master.yml"
echo ""

create_env "$ENVS_DIR/ai-voice-agents.yml"
echo ""

create_env "$ENVS_DIR/data-analysis.yml"
echo ""

create_env "$ENVS_DIR/content-generation.yml"
echo ""

create_env "$ENVS_DIR/web-scraping.yml"
echo ""

# Summary
echo "═══════════════════════════════════════════════════════════════════"
echo "📊 SUMMARY"
echo "═══════════════════════════════════════════════════════════════════"
echo "Total environments: $TOTAL_ENVS"
echo "Created: $CREATED"
echo "Failed: $FAILED"
echo "Skipped: $((TOTAL_ENVS - CREATED - FAILED))"
echo ""

if [[ $CREATED -gt 0 ]]; then
    echo "✅ Environment setup complete!"
    echo ""
    echo "📋 Available environments:"
    mamba env list | grep -E "(automation-master|ai-voice-agents|data-analysis|content-generation|web-scraping)" || true
    echo ""
    echo "🚀 Quick start:"
    echo "   mamba activate automation-master"
    echo "   python --version"
    echo ""
    echo "📚 Full documentation:"
    echo "   cat $ENVS_DIR/README.md"
fi

if [[ $FAILED -gt 0 ]]; then
    echo ""
    echo "⚠️  Some environments failed to create."
    echo "   Check the output above for errors."
    echo "   Common issues:"
    echo "   - Network problems (retry)"
    echo "   - Package conflicts (check .yml file)"
    echo "   - Disk space (free up space)"
fi

echo ""
echo "═══════════════════════════════════════════════════════════════════"
