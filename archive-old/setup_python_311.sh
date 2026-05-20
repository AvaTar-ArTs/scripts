#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail

# Set up Python 3.11 or 3.12 as primary Python

echo "🐍 Setting up Python 3.11/3.12..."
echo ""

# Check what's available
echo "=== Checking Available Python Versions ==="
PYTHON_311=$(which python3.11 2>/dev/null || brew --prefix python@3.11 2>/dev/null)
PYTHON_312=$(which python3.12 2>/dev/null || brew --prefix python@3.12 2>/dev/null)

# Check if installed via Homebrew
if brew list python@3.11 &>/dev/null 2>&1; then
    echo "✅ Python 3.11 installed via Homebrew"
    PYTHON_311_PATH=$(brew --prefix python@3.11)/bin/python3.11
elif brew list python@3.12 &>/dev/null 2>&1; then
    echo "✅ Python 3.12 installed via Homebrew"
    PYTHON_312_PATH=$(brew --prefix python@3.12)/bin/python3.12
else
    echo "⚠️  Python 3.11/3.12 not found via Homebrew"
fi

echo ""
echo "=== Installing Python 3.11 (Preferred) ==="
if ! brew list python@3.11 &>/dev/null 2>&1; then
    echo "Installing Python 3.11..."
    brew install python@3.11
else
    echo "✅ Python 3.11 already installed"
fi

echo ""
echo "=== Setting Up PATH ==="
PYTHON_311_BIN=$(brew --prefix python@3.11)/bin

# Check current shell
SHELL_RC=""
if [ -n "$ZSH_VERSION" ]; then
    SHELL_RC="$HOME/.zshrc"
elif [ -n "$BASH_VERSION" ]; then
    SHELL_RC="$HOME/.bashrc"
fi

if [ -n "$SHELL_RC" ] && [ -f "$SHELL_RC" ]; then
    echo "Found shell config: $SHELL_RC"
    
    # Check if Python 3.11 is already in PATH
    if grep -q "python@3.11" "$SHELL_RC"; then
        echo "✅ Python 3.11 already in PATH"
    else
        echo "Adding Python 3.11 to PATH..."
        echo "" >> "$SHELL_RC"
        echo "# Python 3.11 (preferred)" >> "$SHELL_RC"
        echo "export PATH=\"$PYTHON_311_BIN:\$PATH\"" >> "$SHELL_RC"
        echo "✅ Added to $SHELL_RC"
        echo ""
        echo "💡 Run: source $SHELL_RC"
    fi
else
    echo "⚠️  Shell config not found. Add this to your shell config:"
    echo "   export PATH=\"$PYTHON_311_BIN:\$PATH\""
fi

echo ""
echo "=== Creating Aliases ==="
if [ -n "$SHELL_RC" ] && [ -f "$SHELL_RC" ]; then
    if ! grep -q "alias python3=" "$SHELL_RC"; then
        echo "" >> "$SHELL_RC"
        echo "# Python aliases" >> "$SHELL_RC"
        echo "alias python3='python3.11'" >> "$SHELL_RC"
        echo "alias pip3='pip3.11'" >> "$SHELL_RC"
        echo "✅ Aliases added"
    else
        echo "✅ Aliases already exist"
    fi
fi

echo ""
echo "=== Verification ==="
echo "After sourcing your shell config, verify with:"
echo "  python3 --version  # Should show 3.11.x"
echo "  which python3      # Should point to Python 3.11"
echo ""
echo "✅ Setup complete!"
