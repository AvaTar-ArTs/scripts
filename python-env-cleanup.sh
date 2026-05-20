#!/usr/bin/env bash
# Python Environment Cleanup Script
# Safely cleans up Python installations without breaking functionality

set -e

echo "🧹 Python Environment Cleanup"
echo "=" | head -c 70 && echo ""
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Dry run mode
DRY_RUN="${1:-}"

if [ "$DRY_RUN" = "--dry-run" ] || [ "$DRY_RUN" = "-n" ]; then
    echo "⚠️  DRY RUN MODE - No files will be deleted"
    echo ""
    DRY_RUN_FLAG="echo [DRY RUN] Would remove:"
else
    DRY_RUN_FLAG=""
fi

# Function to get size before/after
get_size() {
    local path="$1"
    if [ -d "$path" ]; then
        du -sh "$path" 2>/dev/null | awk '{print $1}'
    else
        echo "0"
    fi
}

# 1. Clean Python cache files
echo "1️⃣  Cleaning Python cache files..."
echo "-----------------------------------"

CACHE_COUNT=0
BEFORE_SIZE=$(du -sh ~/.local ~/Library/Python 2>/dev/null | awk '{sum+=$1} END {print sum}')

# Remove __pycache__ directories
if [ "$DRY_RUN" = "--dry-run" ] || [ "$DRY_RUN" = "-n" ]; then
    find ~/.local ~/Library/Python -type d -name __pycache__ 2>/dev/null | wc -l | xargs -I {} echo "Would remove {} __pycache__ directories"
    find ~/.local ~/Library/Python -name '*.pyc' 2>/dev/null | wc -l | xargs -I {} echo "Would remove {} .pyc files"
    find ~/.local ~/Library/Python -name '*.pyo' 2>/dev/null | wc -l | xargs -I {} echo "Would remove {} .pyo files"
else
    CACHE_DIRS=$(find ~/.local ~/Library/Python -type d -name __pycache__ 2>/dev/null | wc -l | tr -d ' ')
    CACHE_FILES=$(find ~/.local ~/Library/Python -name '*.pyc' -o -name '*.pyo' 2>/dev/null | wc -l | tr -d ' ')
    
    if [ "$CACHE_DIRS" -gt 0 ] || [ "$CACHE_FILES" -gt 0 ]; then
        find ~/.local ~/Library/Python -type d -name __pycache__ -exec rm -rf {} + 2>/dev/null || true
        find ~/.local ~/Library/Python -name '*.pyc' -delete 2>/dev/null || true
        find ~/.local ~/Library/Python -name '*.pyo' -delete 2>/dev/null || true
        echo "✅ Removed $CACHE_DIRS cache directories and $CACHE_FILES cache files"
    else
        echo "✅ No cache files found"
    fi
fi

echo ""

# 2. Clean miniforge3 package cache
echo "2️⃣  Cleaning miniforge3 package cache..."
echo "-----------------------------------"

if [ -d "$HOME/miniforge3" ]; then
    PKGS_SIZE=$(du -sh "$HOME/miniforge3/pkgs" 2>/dev/null | awk '{print $1}')
    echo "Package cache size: $PKGS_SIZE"
    
    if [ "$DRY_RUN" = "--dry-run" ] || [ "$DRY_RUN" = "-n" ]; then
        echo "[DRY RUN] Would run: mamba clean --all --yes"
    else
        if command -v mamba &>/dev/null; then
            echo "Running: mamba clean --all --yes"
            mamba clean --all --yes 2>/dev/null || {
                echo "⚠️  mamba clean failed, trying conda..."
                if command -v conda &>/dev/null; then
                    conda clean --all --yes 2>/dev/null || echo "❌ Both mamba and conda clean failed"
                fi
            }
            echo "✅ Miniforge3 package cache cleaned"
        else
            echo "⚠️  mamba not found in PATH"
        fi
    fi
else
    echo "✅ Miniforge3 not found (already removed?)"
fi

echo ""

# 3. Clean pip cache
echo "3️⃣  Cleaning pip cache..."
echo "-----------------------------------"

if [ "$DRY_RUN" = "--dry-run" ] || [ "$DRY_RUN" = "-n" ]; then
    if [ -d "$HOME/Library/Caches/pip" ]; then
        PIP_SIZE=$(du -sh "$HOME/Library/Caches/pip" 2>/dev/null | awk '{print $1}')
        echo "[DRY RUN] Would remove pip cache: $PIP_SIZE"
    fi
else
    if [ -d "$HOME/Library/Caches/pip" ]; then
        PIP_SIZE=$(du -sh "$HOME/Library/Caches/pip" 2>/dev/null | awk '{print $1}')
        rm -rf "$HOME/Library/Caches/pip"/* 2>/dev/null || true
        echo "✅ Removed pip cache ($PIP_SIZE)"
    else
        echo "✅ No pip cache found"
    fi
fi

echo ""

# 4. Summary
echo "📊 SUMMARY"
echo "=" | head -c 70 && echo ""
echo ""

if [ "$DRY_RUN" != "--dry-run" ] && [ "$DRY_RUN" != "-n" ]; then
    AFTER_SIZE=$(du -sh ~/.local ~/Library/Python 2>/dev/null | awk '{sum+=$1} END {print sum}')
    echo "Before: ~$BEFORE_SIZE"
    echo "After:  ~$AFTER_SIZE"
    echo ""
    echo "✅ Cleanup complete!"
    echo ""
    echo "💡 To see current sizes, run:"
    echo "   python3 python-env-cleanup.py"
else
    echo "✅ Dry run complete. Run without --dry-run to actually clean."
fi
