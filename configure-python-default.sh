#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail

# Configure Python 3.11 as default, remove false positives from conflict checker

echo "🐍 Configuring Python 3.11 as Default..."
echo ""

# Find shell config
if [ -n "$ZSH_VERSION" ]; then
    SHELL_RC="$HOME/.zshrc"
elif [ -n "$BASH_VERSION" ]; then
    SHELL_RC="$HOME/.bashrc"
else
    SHELL_RC="$HOME/.zshrc"  # Default to zsh
fi

echo "Using: $SHELL_RC"
echo ""

# Get Python 3.11 path
PYTHON_311_PATH=$(brew --prefix python@3.11)/bin
PYTHON_312_PATH=$(brew --prefix python@3.12)/bin

echo "=== Adding Python 3.11 to PATH ==="
# Remove any existing python@3.x PATH entries
if [ -f "$SHELL_RC" ]; then
    # Create backup
    cp "$SHELL_RC" "$SHELL_RC.backup.$(date +%Y%m%d_%H%M%S)"
    
    # Remove old python@3.x entries
    sed -i.bak '/python@3\./d' "$SHELL_RC" 2>/dev/null || sed -i '' '/python@3\./d' "$SHELL_RC"
    
    # Add Python 3.11 to PATH (preferred)
    if ! grep -q "$PYTHON_311_PATH" "$SHELL_RC"; then
        echo "" >> "$SHELL_RC"
        echo "# Python 3.11 (preferred default)" >> "$SHELL_RC"
        echo "export PATH=\"$PYTHON_311_PATH:\$PATH\"" >> "$SHELL_RC"
        echo "✅ Added Python 3.11 to PATH"
    fi
    
    # Add Python 3.12 as secondary option
    if ! grep -q "$PYTHON_312_PATH" "$SHELL_RC"; then
        echo "# Python 3.12 (alternative)" >> "$SHELL_RC"
        echo "# export PATH=\"$PYTHON_312_PATH:\$PATH\"  # Uncomment to use 3.12 instead" >> "$SHELL_RC"
    fi
fi

echo ""
echo "=== Setting Up Aliases ==="
if [ -f "$SHELL_RC" ]; then
    # Remove old python aliases
    sed -i.bak '/^alias python3=/d' "$SHELL_RC" 2>/dev/null || sed -i '' '/^alias python3=/d' "$SHELL_RC"
    sed -i.bak '/^alias pip3=/d' "$SHELL_RC" 2>/dev/null || sed -i '' '/^alias pip3=/d' "$SHELL_RC"
    
    # Add new aliases
    if ! grep -q "^alias python3=" "$SHELL_RC"; then
        echo "" >> "$SHELL_RC"
        echo "# Python aliases (default to 3.11)" >> "$SHELL_RC"
        echo "alias python3='python3.11'" >> "$SHELL_RC"
        echo "alias pip3='pip3.11'" >> "$SHELL_RC"
        echo "✅ Aliases configured"
    fi
fi

echo ""
echo "=== Summary ==="
echo "✅ Python 3.11 configured as default"
echo "✅ Python 3.12 available as alternative"
echo ""
echo "💡 To activate:"
echo "   source $SHELL_RC"
echo ""
echo "💡 To switch to Python 3.12:"
echo "   Uncomment the Python 3.12 line in $SHELL_RC"
echo ""
echo "✅ Configuration complete!"
