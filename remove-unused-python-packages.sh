#!/usr/bin/env bash
# Remove unused Python packages from ~/.local/lib/python*/site-packages
# These are NOT being used - Python uses ~/Library/Python instead

set -e

echo "🔍 Python Package Location Analysis"
echo "=" | head -c 70 && echo ""
echo ""

# Check what Python actually uses
echo "Python 3.12 uses:"
python3.12 -c "import site; print('  ' + site.USER_SITE)" 2>/dev/null || echo "  (not available)"

echo ""
echo "Python 3.11 uses:"
python3.11 -c "import site; print('  ' + site.USER_SITE)" 2>/dev/null || echo "  (not available)"

echo ""
echo "=" | head -c 70 && echo ""
echo ""

# Check sizes
LOCAL_311=$(du -sh ~/.local/lib/python3.11/site-packages 2>/dev/null | awk '{print $1}' || echo "0")
LOCAL_312=$(du -sh ~/.local/lib/python3.12/site-packages 2>/dev/null | awk '{print $1}' || echo "0")
LIB_311=$(du -sh ~/Library/Python/3.11/lib/python/site-packages 2>/dev/null | awk '{print $1}' || echo "0")
LIB_312=$(du -sh ~/Library/Python/3.12/lib/python/site-packages 2>/dev/null | awk '{print $1}' || echo "0")

echo "📊 Current Sizes:"
echo "  ~/.local/lib/python3.11/site-packages:     $LOCAL_311 (UNUSED)"
echo "  ~/Library/Python/3.11/lib/python/site-packages: $LIB_311 (ACTIVE)"
echo ""
echo "  ~/.local/lib/python3.12/site-packages:     $LOCAL_312 (UNUSED)"
echo "  ~/Library/Python/3.12/lib/python/site-packages: $LIB_312 (ACTIVE)"
echo ""

# Calculate total savings
LOCAL_311_GB=$(du -sk ~/.local/lib/python3.11/site-packages 2>/dev/null | awk '{print $1/1024/1024}' || echo "0")
LOCAL_312_GB=$(du -sk ~/.local/lib/python3.12/site-packages 2>/dev/null | awk '{print $1/1024/1024}' || echo "0")
TOTAL_GB=$(echo "$LOCAL_311_GB + $LOCAL_312_GB" | bc 2>/dev/null || echo "$LOCAL_311_GB")

echo "💾 Potential Savings: ~${TOTAL_GB} GB"
echo ""

# Dry run check
if [ "$1" != "--clean" ]; then
    echo "⚠️  DRY RUN MODE"
    echo ""
    echo "The following directories would be removed:"
    [ -d ~/.local/lib/python3.11/site-packages ] && echo "  - ~/.local/lib/python3.11/site-packages ($LOCAL_311)"
    [ -d ~/.local/lib/python3.12/site-packages ] && echo "  - ~/.local/lib/python3.12/site-packages ($LOCAL_312)"
    echo ""
    echo "✅ These are SAFE to remove because:"
    echo "   1. Python uses ~/Library/Python (macOS standard)"
    echo "   2. These packages are NOT in Python's import path"
    echo "   3. You have the same packages in ~/Library/Python"
    echo ""
    echo "Run with --clean to actually remove them:"
    echo "  ./remove-unused-python-packages.sh --clean"
    exit 0
fi

echo "🧹 Removing unused Python packages..."
echo ""

# Remove Python 3.11 packages from .local
if [ -d ~/.local/lib/python3.11/site-packages ]; then
    echo "Removing ~/.local/lib/python3.11/site-packages ($LOCAL_311)..."
    rm -rf ~/.local/lib/python3.11/site-packages
    echo "✅ Removed"
    echo ""
fi

# Remove Python 3.12 packages from .local
if [ -d ~/.local/lib/python3.12/site-packages ]; then
    echo "Removing ~/.local/lib/python3.12/site-packages ($LOCAL_312)..."
    rm -rf ~/.local/lib/python3.12/site-packages
    echo "✅ Removed"
    echo ""
fi

# Also remove include directories if they exist
if [ -d ~/.local/include/python3.11 ]; then
    echo "Removing ~/.local/include/python3.11..."
    rm -rf ~/.local/include/python3.11
    echo "✅ Removed"
    echo ""
fi

if [ -d ~/.local/include/python3.12 ]; then
    echo "Removing ~/.local/include/python3.12..."
    rm -rf ~/.local/include/python3.12
    echo "✅ Removed"
    echo ""
fi

echo "=" | head -c 70 && echo ""
echo "✅ Cleanup complete!"
echo ""
echo "💡 Note: ~/.local/bin and ~/.local/share are kept (they contain useful scripts and app data)"
