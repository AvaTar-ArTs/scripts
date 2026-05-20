#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail


echo "=== macOS Setup Evaluation for xAI Grok API (Terminal Access) ==="
echo

# macOS version
echo "macOS Version:"
sw_vers
echo

# Homebrew (recommended package manager)
if command -v brew >/dev/null 2>&1; then
    echo "✓ Homebrew: Installed ($(brew --version | head -1))"
else
    echo "✗ Homebrew: Not installed (recommended for easy Python updates)"
fi

# Python 3
if command -v python3 >/dev/null 2>&1; then
    echo "✓ Python 3: Installed ($(python3 --version))"
else
    echo "✗ Python 3: Not installed"
fi

# pip (Python package manager)
if command -v pip3 >/dev/null 2>&1; then
    echo "✓ pip: Installed ($(pip3 --version | head -1))"
else
    echo "✗ pip: Not installed"
fi

# Git (useful for cloning examples or community tools)
if command -v git >/dev/null 2>&1; then
    echo "✓ Git: Installed ($(git --version | head -1))"
else
    echo "✗ Git: Not installed"
fi

# OpenAI Python library (needed for Grok API compatibility)
if pip3 show openai >/dev/null 2>&1; then
    echo "✓ openai Python package: Installed ($(pip3 show openai | grep Version | cut -d ' ' -f2))"
else
    echo "✗ openai Python package: Not installed (required)"
fi

echo
echo "=== Summary of Requirements ==="
echo "You need:"
echo "  • Python 3.10+ (3.12 recommended)"
echo "  • pip"
echo "  • openai Python package"
echo "  • An xAI API key (get it at https://x.ai/api or https://console.grok.com after signing up)"
echo
echo "Run this script again after installing missing items."
