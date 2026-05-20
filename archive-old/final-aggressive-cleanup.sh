#!/usr/bin/env bash
# Final aggressive cleanup - removes old versions and caches

set -e

echo "🧹 Final Aggressive Cleanup"
echo "=" | head -c 70 && echo ""
echo ""

TOTAL_SAVED=0

# 1. Remove old Claude versions (keep only latest)
echo "1️⃣  Cleaning Claude versions..."
CLAUDE_VERSIONS_DIR="$HOME/.local/share/claude/versions"
if [ -d "$CLAUDE_VERSIONS_DIR" ]; then
    VERSIONS=($(ls -1 "$CLAUDE_VERSIONS_DIR" | sort))
    if [ ${#VERSIONS[@]} -gt 1 ]; then
        LATEST="${VERSIONS[-1]}"
        echo "  Keeping latest: $LATEST"
        for version in "${VERSIONS[@]}"; do
            if [ "$version" != "$LATEST" ]; then
                SIZE=$(du -sh "$CLAUDE_VERSIONS_DIR/$version" 2>/dev/null | awk '{print $1}')
                echo "  Removing: $version ($SIZE)"
                rm -rf "$CLAUDE_VERSIONS_DIR/$version"
                TOTAL_SAVED=$((TOTAL_SAVED + 1))
            fi
        done
        echo "  ✅ Done"
    else
        echo "  ✅ Only one version, nothing to clean"
    fi
else
    echo "  ✅ No Claude versions found"
fi
echo ""

# 2. Clean UV cache
echo "2️⃣  Cleaning UV cache..."
UV_CACHE="$HOME/.local/share/uv"
if [ -d "$UV_CACHE" ]; then
    SIZE=$(du -sh "$UV_CACHE" 2>/dev/null | awk '{print $1}')
    echo "  UV cache size: $SIZE"
    echo "  Removing UV cache..."
    rm -rf "$UV_CACHE"/*
    echo "  ✅ Done"
    TOTAL_SAVED=$((TOTAL_SAVED + 1))
else
    echo "  ✅ No UV cache found"
fi
echo ""

# 3. Clean Jupyter cache/extensions (if not using)
echo "3️⃣  Checking Jupyter..."
JUPYTER_DIR="$HOME/.local/share/jupyter"
if [ -d "$JUPYTER_DIR" ]; then
    SIZE=$(du -sh "$JUPYTER_DIR" 2>/dev/null | awk '{print $1}')
    echo "  Jupyter data: $SIZE"
    echo "  ⚠️  Keeping (you might use Jupyter)"
else
    echo "  ✅ No Jupyter data"
fi
echo ""

# 4. Summary
echo "=" | head -c 70 && echo ""
echo "✅ Cleanup complete!"
echo ""
echo "📊 Final sizes:"
du -sh ~/.local ~/Library/Python ~/miniforge3 2>/dev/null | sort -h
echo ""
echo "💡 Total Python environment size should now be ~5-6 GB"
