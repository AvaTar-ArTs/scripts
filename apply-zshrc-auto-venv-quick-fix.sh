#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail

# Quick fix for .venv error in zshrc

echo "🔧 Fixing auto-venv error in .zshrc..."

# Backup zshrc
cp ~/.zshrc ~/.zshrc.backup.$(date +%Y%m%d_%H%M%S)

# The fix is already applied if you've updated the _auto_venv function
# This script just verifies the fix is in place

if grep -q "if \[ -f \"\$venv_path/bin/activate\" \]; then" ~/.zshrc; then
  echo "✅ Fix already applied - auto-venv function checks for activate script"
else
  echo "⚠️  Fix not found - you may need to update the _auto_venv function manually"
  echo "   See zshrc_config_answers.md for details"
fi

echo ""
echo "📋 Review configuration answers:"
echo "   cat ~/scripts/zshrc_config_answers.md"
echo ""
