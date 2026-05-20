#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail

# Setup script for xsh tool

echo "🔧 Installing xsh tool..."

# Copy the tool to a standard location in your path
cp /Users/steven/xsh_tool.zsh /Users/steven/.local/bin/xsh 2>/dev/null || \
cp /Users/steven/xsh_tool.zsh /usr/local/bin/xsh 2>/dev/null || \
echo "Could not copy to standard bin directory, copying to ~/bin instead..." && \
mkdir -p ~/bin && cp /Users/steven/xsh_tool.zsh ~/bin/xsh

# Make it executable
chmod +x /Users/steven/.local/bin/xsh 2>/dev/null || \
chmod +x /usr/local/bin/xsh 2>/dev/null || \
chmod +x ~/bin/xsh 2>/dev/null

# Add to .zshrc if not already present
if ! grep -q "source.*xsh_tool" ~/.zshrc; then
    echo "" >> ~/.zshrc
    echo "# Enhanced shell command executor for complex environments" >> ~/.zshrc
    echo "source /Users/steven/xsh_tool.zsh" >> ~/.zshrc
    echo "export PATH=\"\$HOME/bin:\$PATH\"" >> ~/.zshrc
    echo "✅ xsh tool added to .zshrc"
else
    echo "ℹ️  xsh tool already in .zshrc"
fi

echo ""
echo "🎉 xsh tool installed successfully!"
echo ""
echo "Usage examples:"
echo "  xsh -c 'echo Hello World'"
echo "  xsh -v -c 'ai --help'"
echo "  xsh -l -c 'source ~/.zshrc && python --version'"
echo ""
echo "The tool is designed to handle complex shell environments like yours"
echo "where standard command execution faces challenges with .zshrc and x-cmd."
