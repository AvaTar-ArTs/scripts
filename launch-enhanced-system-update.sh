#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail


# Enhanced macOS Update Launcher
# This script provides easy access to the enhanced update functionality

echo "🚀 Enhanced macOS Update Launcher"
echo "=================================="
echo ""
echo "Choose an option:"
echo "1. Run full system update"
echo "2. Run Homebrew updates only"
echo "3. Run Python package updates only"
echo "4. Run Node.js package updates only"
echo "5. Run shell tools updates only (Oh My Zsh, etc.)"
echo "6. Run custom tools updates only"
echo "7. Check system information only"
echo "8. Run system maintenance only"
echo "9. Exit"
echo ""

read -p "Enter your choice (1-9): " choice

case $choice in
    1)
        echo "Running full system update..."
        /Users/steven/update_enhanced.sh
        ;;
    2)
        echo "Running Homebrew updates..."
        /Users/steven/update_enhanced.sh --brew-only
        ;;
    3)
        echo "Running Python package updates..."
        /Users/steven/update_enhanced.sh --python-only
        ;;
    4)
        echo "Running Node.js package updates..."
        /Users/steven/update_enhanced.sh --node-only
        ;;
    5)
        echo "Running shell tools updates..."
        /Users/steven/update_enhanced.sh --shell-only
        ;;
    6)
        echo "Running custom tools updates..."
        /Users/steven/update_enhanced.sh --custom-only
        ;;
    7)
        echo "Checking system information..."
        /Users/steven/update_enhanced.sh --info-only
        ;;
    8)
        echo "Running system maintenance..."
        /Users/steven/update_enhanced.sh --maintenance-only
        ;;
    9)
        echo "Goodbye!"
        exit 0
        ;;
    *)
        echo "Invalid choice. Please run the script again."
        exit 1
        ;;
esac
