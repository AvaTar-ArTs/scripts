#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail

# Check for Quick Look plugin conflicts, especially from Homebrew

echo "🔍 Checking Quick Look Plugins for Conflicts..."
echo ""

# 1. List all Quick Look plugins
echo "=== Installed Quick Look Plugins ==="
echo ""
echo "System Plugins:"
ls -la /System/Library/QuickLook/ 2>/dev/null | grep -v "^total" | awk '{print $9}' | grep -v "^$"

echo ""
echo "User Plugins (~/Library/QuickLook/):"
ls -la ~/Library/QuickLook/*.qlgenerator 2>/dev/null | awk '{print $9}' | xargs -I {} basename {}

echo ""
echo "Homebrew-installed Plugins:"
find /opt/homebrew -name "*.qlgenerator" 2>/dev/null
find /usr/local -name "*.qlgenerator" 2>/dev/null

# 2. Check Homebrew packages that might install Quick Look plugins
echo ""
echo "=== Homebrew Packages Related to Quick Look ==="
echo ""
echo "Formulas:"
brew list --formula | grep -iE "(ql|quick|preview|archive|zip)" || echo "None found"

echo ""
echo "Casks:"
brew list --cask | grep -iE "(ql|quick|preview|archive|zip)" || echo "None found"

# 3. Check for duplicate plugins
echo ""
echo "=== Checking for Duplicate Plugins ==="
echo ""
echo "Plugins by name:"
find ~/Library/QuickLook /System/Library/QuickLook /opt/homebrew /usr/local -name "*.qlgenerator" 2>/dev/null | \
    xargs -I {} basename {} | sort | uniq -d

# 4. Check plugin info and conflicts
echo ""
echo "=== Plugin Details ==="
echo ""
for plugin in ~/Library/QuickLook/*.qlgenerator; do
    if [ -d "$plugin" ]; then
        name=$(basename "$plugin")
        echo "Plugin: $name"
        
        # Check if it's from Homebrew
        if brew list --formula 2>/dev/null | grep -q "$name" || \
           brew list --cask 2>/dev/null | grep -q "$name"; then
            echo "  ⚠️  Installed via Homebrew"
        fi
        
        # Check Info.plist for supported types
        if [ -f "$plugin/Contents/Info.plist" ]; then
            echo "  Supported types:"
            /usr/libexec/PlistBuddy -c "Print :CFBundleDocumentTypes" "$plugin/Contents/Info.plist" 2>/dev/null | \
                grep -A 5 "CFBundleTypeName" | grep -v "^$" | head -3 || echo "    (checking...)"
        fi
        echo ""
    fi
done

# 5. Check for archive/zip specific plugins
echo "=== Archive/ZIP Related Plugins ==="
echo ""
find ~/Library/QuickLook /opt/homebrew /usr/local -name "*archive*.qlgenerator" -o -name "*zip*.qlgenerator" 2>/dev/null | \
    while read plugin; do
        echo "Found: $plugin"
        if [ -f "$plugin/Contents/Info.plist" ]; then
            echo "  Types:"
            /usr/libexec/PlistBuddy -c "Print :CFBundleDocumentTypes" "$plugin/Contents/Info.plist" 2>/dev/null | \
                grep -i "public.archive\|com.pkware.zip\|zip" || echo "    (no archive types found)"
        fi
    done

# 6. Check Quick Look generator status
echo ""
echo "=== Quick Look Generator Status ==="
echo ""
qlmanage -m | grep -i "generator\|plugin" | head -10

# 7. Check for known conflicting plugins
echo ""
echo "=== Potential Conflicts ==="
echo ""
conflicting_plugins=("QLColorCode" "QLStephen" "QuickLookCSV" "QuickLookJSON")
for plugin in "${conflicting_plugins[@]}"; do
    if [ -d ~/Library/QuickLook/"$plugin.qlgenerator" ]; then
        echo "⚠️  $plugin.qlgenerator is installed"
        echo "   This might interfere with archive previews"
    fi
done

echo ""
echo "✅ Check complete!"
echo ""
echo "💡 Tips:"
echo "  - If you see duplicate plugins, remove the older one"
echo "  - Homebrew plugins can sometimes conflict with system previews"
echo "  - Try disabling plugins one by one to find the culprit"
