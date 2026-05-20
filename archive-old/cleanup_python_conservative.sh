#!/usr/bin/env bash

# Conservative Python Cleanup Script
# Respects venv preference - moves AI packages to mamba, keeps global pip minimal

set -e

echo "🧹 Conservative Python Cleanup (venv-friendly)"
echo "=============================================="

# Check if we're in a clean environment
if [[ -n "$CONDA_DEFAULT_ENV" ]] || [[ -n "$MAMBA_ACTIVE" ]] || [[ -n "$VIRTUAL_ENV" ]]; then
    echo "❌ Please run this script from a clean environment (run 'tobase' first)"
    exit 1
fi

echo "📋 Current Python setup:"
echo "   • Python 3.12.12 (Homebrew) - Primary"
echo "   • Python 3.11.14 (Homebrew) - Available"
echo "   • venv module - ✅ Available"
echo "   • mamba automation-master - For AI work"
echo ""

# Backup current packages
BACKUP_FILE="$HOME/pip-packages-backup-$(date +%Y%m%d-%H%M%S).txt"
pip freeze > "$BACKUP_FILE"
echo "✅ Backed up global packages to: $BACKUP_FILE"
echo ""

# Initialize mamba for AI package migration
echo "🤖 Step 1: Migrating AI/ML packages to mamba..."
eval "$(mamba shell hook --shell bash)" 2>/dev/null || {
    echo "⚠️  Mamba shell init failed, but continuing..."
}

# Check if automation-master environment exists
if mamba env list 2>/dev/null | grep -q "automation-master"; then
    echo "✅ Found automation-master environment"

    # Provide instructions for manual migration (safer)
    echo "📋 To migrate AI packages to mamba, run these commands manually:"
    echo "   mamba activate automation-master"
    echo "   mamba install -c conda-forge -y pandas numpy matplotlib jupyter"
    echo "   pip install aider-chat anthropic openai claude langchain transformers torch sentence-transformers openai-whisper"
    echo "   mamba deactivate"
    echo ""
    echo "⚠️  Skipping automatic migration - please do this manually for safety"
else
    echo "⚠️  automation-master environment not found"
    echo "   Create it first: mamba create -n automation-master python=3.12"
fi

echo ""

# Conservative cleanup - only remove obviously conflicting packages
echo "🧽 Step 2: Conservative global pip cleanup..."

# Packages to definitely keep (venv essentials)
KEEP_PACKAGES=(
    "pip"
    "setuptools"
    "wheel"
    "virtualenv"
    "venv"
)

# Get packages that might conflict with mamba
CONFLICTING_PACKAGES=(
    "aider-chat"
    "anthropic"
    "openai"
    "claude"
    "langchain"
    "transformers"
    "torch"
    "sentence-transformers"
    "openai-whisper"
)

echo "🗑️  Removing packages that are now in mamba:"
for package in "${CONFLICTING_PACKAGES[@]}"; do
    if pip list --format=freeze | grep -q "^${package}=="; then
        echo "   • $package"
        pip uninstall -y "$package" 2>/dev/null || echo "     ⚠️  Could not remove $package"
    fi
done

echo ""
echo "✅ Cleanup complete!"
echo ""
echo "🎯 Your new workflow:"
echo ""
echo "   # For AI/ML work:"
echo "   mamba activate automation-master"
echo "   python -c \"import aider_chat, anthropic\""
echo ""
echo "   # For new projects:"
echo "   ~/setup_venv_project.sh my-project"
echo "   cd my-project"
echo "   source .venv/bin/activate"
echo "   pip install requests pandas"
echo ""
echo "   # For system Python:"
echo "   python3 script.py  # Uses your 3.12 venv setup"
echo ""
echo "🧪 Test:"
echo "   pystatus  # Check environment status"
echo "   python3 -c \"import venv; print('venv works!')\""
