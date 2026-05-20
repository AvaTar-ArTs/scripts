#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail


# Cursor Extension Management Script
# This script helps you manage extensions via terminal

echo "🚀 Cursor Extension Manager"
echo "=============================="
echo ""

# Define extensions to enable
TO_ENABLE=(
    "formulahendry.auto-close-tag"
    "formulahendry.auto-rename-tag"
    "rvest.vs-code-prettier-eslint"
    "hex-inc.stylelint-plus"
    "bradlc.vscode-tailwindcss"
    "DavidAnson.vscode-markdownlint"
    "lglong519.terminal-tools"
)

# Define extensions to uninstall
TO_UNINSTALL=(
    "ms-dotnettools.vscode-dotnet-runtime"
    "akamud.vscode-theme-onedark"
    "BeardedBear.beardedicons"
    "rafapaulin.trys-icon-pack"
)

# Function to enable extensions
enable_extensions() {
    echo "📦 Enabling recommended extensions..."
    echo ""
    for ext in "${TO_ENABLE[@]}"; do
        echo "Enabling: $ext"
        cursor --install-extension "$ext" 2>/dev/null || code --install-extension "$ext"
    done
    echo ""
    echo "✅ Extensions enabled!"
}

# Function to uninstall extensions
uninstall_extensions() {
    echo "🗑️  Uninstalling unnecessary extensions..."
    echo ""
    for ext in "${TO_UNINSTALL[@]}"; do
        echo "Uninstalling: $ext"
        cursor --uninstall-extension "$ext" 2>/dev/null || code --uninstall-extension "$ext"
    done
    echo ""
    echo "✅ Extensions uninstalled!"
}

# Function to list all extensions
list_extensions() {
    echo "📋 Currently installed extensions:"
    echo ""
    cursor --list-extensions 2>/dev/null || code --list-extensions
}

# Function to list disabled extensions
list_disabled() {
    echo "🔒 Disabled extensions:"
    echo ""
    cursor --list-extensions --show-versions 2>/dev/null || code --list-extensions --show-versions
    echo ""
    echo "Note: Cursor doesn't have a direct way to list only disabled extensions via CLI"
    echo "Check your settings.json or use the GUI (@disabled filter)"
}

# Main menu
echo "What would you like to do?"
echo ""
echo "1) Enable recommended extensions"
echo "2) Uninstall unnecessary extensions"
echo "3) Do both (recommended)"
echo "4) List all installed extensions"
echo "5) Exit"
echo ""
read -p "Enter your choice (1-5): " choice

case $choice in
    1)
        enable_extensions
        ;;
    2)
        uninstall_extensions
        ;;
    3)
        enable_extensions
        echo ""
        uninstall_extensions
        ;;
    4)
        list_extensions
        ;;
    5)
        echo "👋 Goodbye!"
        exit 0
        ;;
    *)
        echo "❌ Invalid choice"
        exit 1
        ;;
esac

echo ""
echo "🎉 Done! You may need to reload Cursor for changes to take effect."
echo "💡 To reload: Cmd+Shift+P → 'Developer: Reload Window'"
