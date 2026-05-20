#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail

# Quick environment activation helper

if [ -z "$1" ]; then
    echo "🐍 Mamba Environment Activator"
    echo ""
    echo "Usage: activate.sh <environment-name>"
    echo ""
    echo "Available environments:"
    mamba env list | grep -E "(automation-master|ai-voice-agents|data-analysis|content-generation|web-scraping)" | awk '{print "  - " $1}'
    echo ""
    echo "Example:"
    echo "  ./activate.sh automation-master"
    echo ""
    echo "Or directly:"
    echo "  mamba activate automation-master"
    exit 1
fi

ENV_NAME="$1"

# Check if environment exists
if ! mamba env list | grep -q "^$ENV_NAME "; then
    echo "❌ Environment '$ENV_NAME' not found"
    echo ""
    echo "Available environments:"
    mamba env list | grep -E "(automation-master|ai-voice-agents|data-analysis|content-generation|web-scraping)" | awk '{print "  - " $1}'
    echo ""
    echo "Create it with:"
    echo "  mamba env create -f ~/ai-sites/environments/$ENV_NAME.yml"
    exit 1
fi

echo "✅ Activating environment: $ENV_NAME"
echo ""
echo "Run this command:"
echo "  mamba activate $ENV_NAME"
echo ""
echo "Or add to your shell startup for auto-sourcing:"
echo "  eval \"\$(mamba shell hook -s zsh)\""
