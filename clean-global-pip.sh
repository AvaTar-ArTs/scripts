#!/usr/bin/env bash

# Global Pip Cleanup Script
# Safely remove global pip packages, keeping only essentials

set -e

echo "🧹 Global Pip Cleanup Script"
echo "============================"
echo ""

# Check if we're in a clean environment (not conda/mamba/venv)
if [[ -n "$CONDA_DEFAULT_ENV" ]] || [[ -n "$MAMBA_ACTIVE" ]] || [[ -n "$VIRTUAL_ENV" ]]; then
    echo "❌ Please run this script from a clean environment (run 'tobase' first)"
    echo "   Current environment: ${CONDA_DEFAULT_ENV:-${MAMBA_ACTIVE:-${VIRTUAL_ENV:-'Unknown'}}}"
    exit 1
fi

# Essential packages to keep (system/user level tools)
KEEP_PACKAGES=(
    "pip"
    "setuptools"
    "wheel"
    "virtualenv"
    "pipx"
)

echo "📦 Essential packages that will be kept:"
printf "   • %s\n" "${KEEP_PACKAGES[@]}"
echo ""

# Get current global packages
echo "🔍 Analyzing current global packages..."
ALL_PACKAGES=$(pip list --format=freeze | cut -d= -f1)

# Count packages
TOTAL_PACKAGES=$(echo "$ALL_PACKAGES" | wc -l | tr -d ' ')
echo "📊 Found $TOTAL_PACKAGES global packages"

# Filter packages to remove (exclude kept ones)
PACKAGES_TO_REMOVE=()
for package in $ALL_PACKAGES; do
    keep=false
    for keep_pkg in "${KEEP_PACKAGES[@]}"; do
        if [[ "$package" == "$keep_pkg" ]]; then
            keep=true
            break
        fi
    done
    if [[ "$keep" == false ]]; then
        PACKAGES_TO_REMOVE+=("$package")
    fi
done

REMOVE_COUNT=${#PACKAGES_TO_REMOVE[@]}
KEEP_COUNT=$((TOTAL_PACKAGES - REMOVE_COUNT))

echo "📋 Summary:"
echo "   • Keep: $KEEP_COUNT essential packages"
echo "   • Remove: $REMOVE_COUNT packages"
echo ""

if [ $REMOVE_COUNT -eq 0 ]; then
    echo "✅ No packages to remove - your global pip is already clean!"
    exit 0
fi

# Show what will be removed
echo "🗑️  Packages to be removed:"
for package in "${PACKAGES_TO_REMOVE[@]}"; do
    echo "   • $package"
done
echo ""

# Ask for confirmation
read -p "🤔 Proceed with removal? (y/N): " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Cleanup cancelled."
    exit 0
fi

# Remove packages in batches to avoid command line length limits
echo "🧹 Removing packages..."
BATCH_SIZE=20
for ((i=0; i<REMOVE_COUNT; i+=BATCH_SIZE)); do
    batch=("${PACKAGES_TO_REMOVE[@]:i:BATCH_SIZE}")
    echo "   Removing batch: ${batch[*]}"
    pip uninstall -y "${batch[@]}" 2>/dev/null || {
        echo "⚠️  Some packages in batch failed to uninstall (may be dependencies)"
    }
done

echo ""
echo "✅ Global pip cleanup complete!"
echo ""
echo "📊 Final status:"
pip list --format=short | wc -l | xargs echo "   • Remaining packages:"
echo ""
echo "💡 Going forward:"
echo "   • Use 'mamba activate automation-master' for AI/ML work"
echo "   • Use 'uv init my-project' for new isolated projects"
echo "   • Avoid global pip installs"
echo ""
echo "🧪 Test your setup:"
echo "   pystatus  # Check Python environment"
echo "   pip --version  # Should still work (using uv)"
