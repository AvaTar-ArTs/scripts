#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail

# Fix Quick Look plugin conflicts from Homebrew

echo "🔧 Fixing Quick Look Plugin Conflicts..."
echo ""

# Homebrew Quick Look casks found
PLUGINS=("qlcolorcode" "qlstephen" "quicklook-csv" "quicklook-json" "webpquicklook")

echo "=== Current Status ==="
for plugin in "${PLUGINS[@]}"; do
    echo ""
    echo "Plugin: $plugin"
    
    # Check if installed via Homebrew
    if brew list --cask "$plugin" &>/dev/null; then
        echo "  ✅ Installed via Homebrew"
        
        # Find the actual plugin location
        PLUGIN_PATH=$(find /usr/local/Caskroom -name "*.qlgenerator" -path "*$plugin*" 2>/dev/null | head -1)
        if [ -z "$PLUGIN_PATH" ]; then
            PLUGIN_PATH=$(find /opt/homebrew/Caskroom -name "*.qlgenerator" -path "*$plugin*" 2>/dev/null | head -1)
        fi
        
        if [ -n "$PLUGIN_PATH" ]; then
            echo "  📍 Location: $PLUGIN_PATH"
            
            # Check for duplicate in ~/Library/QuickLook/
            PLUGIN_NAME=$(basename "$PLUGIN_PATH")
            USER_PLUGIN="$HOME/Library/QuickLook/$PLUGIN_NAME"
            
            if [ -e "$USER_PLUGIN" ]; then
                echo "  ⚠️  Duplicate found in ~/Library/QuickLook/"
                
                # Check if it's a symlink
                if [ -L "$USER_PLUGIN" ]; then
                    echo "  ℹ️  It's a symlink (OK)"
                else
                    echo "  ⚠️  It's a copy (should be symlink)"
                    echo "  🔄 Removing duplicate and creating symlink..."
                    rm -rf "$USER_PLUGIN"
                    ln -s "$PLUGIN_PATH" "$USER_PLUGIN"
                    echo "  ✅ Fixed!"
                fi
            else
                echo "  ✅ No duplicate found"
                # Create symlink if it doesn't exist
                if [ ! -e "$USER_PLUGIN" ]; then
                    echo "  🔗 Creating symlink..."
                    ln -s "$PLUGIN_PATH" "$USER_PLUGIN"
                    echo "  ✅ Symlink created"
                fi
            fi
        fi
    else
        echo "  ℹ️  Not installed via Homebrew"
    fi
done

echo ""
echo "=== Ensuring System Package Plugin Works ==="
# The system Package.qlgenerator should handle ZIP files
if [ -d "/System/Library/QuickLook/Package.qlgenerator" ]; then
    echo "✅ System Package.qlgenerator found (handles ZIP files)"
    echo "   This should work for ZIP previews"
else
    echo "⚠️  System Package.qlgenerator not found"
fi

echo ""
echo "=== Resetting Quick Look ==="
qlmanage -r
killall qlmanage 2>/dev/null
killall Finder

echo ""
echo "✅ Done!"
echo ""
echo "📋 Summary:"
echo "  - Fixed duplicate plugins"
echo "  - Created proper symlinks"
echo "  - Reset Quick Look"
echo ""
echo "🧪 Test: Select a ZIP file and press Spacebar"
echo ""
echo "💡 If ZIP preview still doesn't work:"
echo "   1. Check: System Preferences > Extensions > Quick Look"
echo "   2. Try temporarily disabling third-party plugins:"
echo "      mv ~/Library/QuickLook/*.qlgenerator ~/Library/QuickLook_backup/"
echo "      killall Finder"
echo "   3. Test ZIP preview"
echo "   4. If it works, move plugins back one by one"
