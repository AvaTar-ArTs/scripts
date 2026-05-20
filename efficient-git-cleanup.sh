#!/usr/bin/env bash
# Efficient Git Repository Cleanup Script
# Focuses on the most common temporary repository locations

set -e  # Exit on any error

echo "==========================================="
echo "EFFICIENT GIT REPOSITORY CLEANUP"
echo "Removing common temporary/cache git repositories"
echo "==========================================="
echo ""

SOURCE_DIR="/Users/steven"

# Count total repositories before cleanup
TOTAL_BEFORE=$(find "$SOURCE_DIR" -type d -name ".git" 2>/dev/null | wc -l)
echo "Total git repositories before cleanup: $TOTAL_BEFORE"

# Remove Cursor plugin cache repositories
echo "Removing Cursor plugin cache repositories..."
find "$SOURCE_DIR/.cursor/plugins/cache" -type d -name ".git" 2>/dev/null | while read -r repo; do
    repo_path="${repo%/.git}"
    echo "Removing: $repo_path"
    rm -rf "$repo_path" 2>/dev/null || true
done

# Remove Claude temporary repositories
echo "Removing Claude temporary repositories..."
find "$SOURCE_DIR/.claude" -type d -name ".git" -path "*/file-history/*" 2>/dev/null | while read -r repo; do
    repo_path="${repo%/.git}"
    echo "Removing: $repo_path"
    rm -rf "$repo_path" 2>/dev/null || true
done

find "$SOURCE_DIR/.claude" -type d -name ".git" -path "*/debug/*" 2>/dev/null | while read -r repo; do
    repo_path="${repo%/.git}"
    echo "Removing: $repo_path"
    rm -rf "$repo_path" 2>/dev/null || true
done

# Remove Qwen temporary repositories
echo "Removing Qwen temporary repositories..."
find "$SOURCE_DIR/.qwen" -type d -name ".git" -path "*/tmp/*" 2>/dev/null | while read -r repo; do
    repo_path="${repo%/.git}"
    echo "Removing: $repo_path"
    rm -rf "$repo_path" 2>/dev/null || true
done

# Remove Cursor workspace storage repositories
echo "Removing Cursor workspace storage repositories..."
find "$SOURCE_DIR/Library/Application Support/Cursor/User/workspaceStorage" -type d -name ".git" 2>/dev/null | while read -r repo; do
    repo_path="${repo%/.git}"
    echo "Removing: $repo_path"
    rm -rf "$repo_path" 2>/dev/null || true
done

# Remove node_modules repositories
echo "Removing node_modules git repositories..."
find "$SOURCE_DIR" -type d -name ".git" -path "*/node_modules/*" 2>/dev/null | while read -r repo; do
    repo_path="${repo%/.git}"
    echo "Removing: $repo_path"
    rm -rf "$repo_path" 2>/dev/null || true
done

# Count repositories after cleanup
TOTAL_AFTER=$(find "$SOURCE_DIR" -type d -name ".git" 2>/dev/null | wc -l)
REMOVED=$((TOTAL_BEFORE - TOTAL_AFTER))

echo ""
echo "==========================================="
echo "CLEANUP COMPLETE!"
echo "==========================================="
echo "Repositories before: $TOTAL_BEFORE"
echo "Repositories after: $TOTAL_AFTER"
echo "Repositories removed: $REMOVED"
echo ""
echo "Common temporary/cache git repositories have been removed."
echo "Only important project repositories remain."
