#!/usr/bin/env bash

# Python Environment Migration Script
# Move critical packages from global pip to mamba automation-master environment

set -e

echo "🐍 Starting Python Environment Migration"
echo "========================================"

# Check if we're in the right environment
if [[ -n "$CONDA_DEFAULT_ENV" ]] || [[ -n "$MAMBA_ACTIVE" ]]; then
    echo "❌ Please run this script from a clean shell (run 'tobase' first)"
    exit 1
fi

# Initialize mamba shell if needed
echo "🔧 Initializing mamba shell..."
eval "$(mamba shell hook --shell bash)" || {
    echo "❌ Failed to initialize mamba shell"
    exit 1
}

# Activate automation-master environment
echo "🔄 Activating automation-master environment..."
mamba activate automation-master

# Verify we're in the right environment
if [[ "$CONDA_DEFAULT_ENV" != "automation-master" ]]; then
    echo "❌ Failed to activate automation-master environment"
    exit 1
fi

echo "✅ Successfully activated automation-master environment"

# Install critical AI/ML packages
echo "🤖 Installing AI/ML packages..."
mamba install -c conda-forge -y \
    aider-chat \
    python-openai \
    anthropic \
    langchain \
    transformers \
    torch \
    sentence-transformers \
    openai-whisper \
    claude-agent-sdk || {
    echo "⚠️  Some packages may not be available in conda. Will try pip..."
}

# Install packages that might not be in conda
echo "📦 Installing additional packages with pip..."
pip install --upgrade \
    aider-chat \
    anthropic \
    openai \
    claude \
    langchain \
    langchain-community \
    langchain-openai \
    sentence-transformers \
    openai-whisper

# Install data science packages
echo "📊 Installing data science packages..."
mamba install -c conda-forge -y \
    pandas \
    numpy \
    matplotlib \
    jupyter \
    requests || {
    echo "⚠️  Using pip for data science packages..."
    pip install pandas numpy matplotlib jupyter requests
}

echo "✅ Migration to mamba automation-master complete!"
echo ""
echo "🧪 Test your setup:"
echo "   mamba activate automation-master"
echo "   python -c 'import aider_chat, anthropic, openai; print(\"AI packages working!\")'"
echo ""
echo "💡 Going forward:"
echo "   - Use 'mamba activate automation-master' for AI/ML work"
echo "   - Use 'uv init' for new isolated projects"
echo "   - Avoid global pip installs"
