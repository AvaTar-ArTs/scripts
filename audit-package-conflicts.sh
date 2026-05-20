#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail

# Fix package manager conflicts

echo "🔧 Fixing Package Manager Conflicts..."
echo ""

# 1. Fix Python/pip PATH conflicts
echo "=== Fixing Python/pip PATH Conflicts ==="
echo ""

# Check which Python is being used
PRIMARY_PYTHON=$(which python3)
echo "Primary Python: $PRIMARY_PYTHON"

# Check for multiple Python installations
PYTHON_PATHS=$(which -a python3 | grep -v "$PRIMARY_PYTHON")
if [ -n "$PYTHON_PATHS" ]; then
    echo -e "⚠️  Multiple python3 versions found:"
    which -a python3 | sed 's/^/  /'
    echo ""
    echo "💡 Recommendation: Use pyenv or ensure only one Python is in PATH"
    echo "   Current PATH order determines which version is used"
else
    echo "✅ Only one python3 in PATH"
fi

# Check pip
PRIMARY_PIP=$(which pip3)
echo "Primary pip3: $PRIMARY_PIP"
echo ""

# 2. Check Homebrew outdated packages
echo "=== Homebrew Outdated Packages ==="
OUTDATED=$(brew outdated 2>/dev/null)
if [ -n "$OUTDATED" ]; then
    echo "⚠️  Outdated packages found:"
    echo "$OUTDATED" | sed 's/^/  /'
    echo ""
    echo "💡 To update: brew upgrade"
    echo "   Or update specific: brew upgrade <package>"
else
    echo "✅ All packages up to date"
fi
echo ""

# 3. Check for conflicting Quick Look plugins (verify they're still symlinks)
echo "=== Verifying Quick Look Plugins ==="
PLUGINS=("QLColorCode" "QLStephen" "QuickLookCSV" "QuickLookJSON" "WebpQuickLook")
ALL_GOOD=true

for plugin in "${PLUGINS[@]}"; do
    PLUGIN_PATH="$HOME/Library/QuickLook/${plugin}.qlgenerator"
    if [ -e "$PLUGIN_PATH" ]; then
        if [ -L "$PLUGIN_PATH" ]; then
            echo "✅ $plugin: Symlink (OK)"
        else
            echo "⚠️  $plugin: Regular file (should be symlink)"
            ALL_GOOD=false
        fi
    fi
done

if [ "$ALL_GOOD" = true ]; then
    echo "✅ All plugins are properly symlinked"
else
    echo ""
    echo "💡 Run: /Users/steven/fix_quicklook_conflicts.sh"
fi
echo ""

# 4. Check pip for conflicts
echo "=== Python pip Conflicts ==="
PIP_CHECK=$(pip3 check 2>&1)
if echo "$PIP_CHECK" | grep -q "has requirement"; then
    echo "⚠️  Dependency conflicts:"
    echo "$PIP_CHECK" | sed 's/^/  /'
    echo ""
    echo "💡 To fix: pip3 install --upgrade <package>"
else
    echo "✅ No pip dependency conflicts"
fi
echo ""

# 5. Summary and recommendations
echo "=========================================="
echo "📋 Summary & Recommendations:"
echo ""
echo "1. Python PATH:"
echo "   - Multiple versions detected (normal if using pyenv)"
echo "   - Current active: $PRIMARY_PYTHON"
echo ""
echo "2. Homebrew:"
if [ -n "$OUTDATED" ]; then
    echo "   - Update with: brew upgrade"
else
    echo "   - All up to date"
fi
echo ""
echo "3. Quick Look:"
if [ "$ALL_GOOD" = true ]; then
    echo "   - All plugins properly configured"
else
    echo "   - Some plugins need fixing"
fi
echo ""
echo "4. General Maintenance:"
echo "   - Run 'brew doctor' to check Homebrew health"
echo "   - Run 'pip3 check' to verify Python packages"
echo "   - Run 'npm audit' to check Node.js packages"
echo ""
echo "=========================================="
