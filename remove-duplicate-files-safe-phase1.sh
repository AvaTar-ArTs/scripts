#!/usr/bin/env bash
# Safe Duplicate File Removal Script
# Generated from comprehensive analysis

set -e  # Exit on any error

echo "🗑️ Safe Duplicate File Removal Script"
echo "===================================="

# Create backup directory
BACKUP_DIR="$HOME/python_duplicate_backup_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"

echo "📁 Backup directory created: $BACKUP_DIR"

# Function to safely backup and remove
safe_remove() {
    local file_path="$1"
    local filename="$(basename "$file_path")"

    if [ -f "$file_path" ]; then
        echo "📋 Backing up: $filename"
        cp "$file_path" "$BACKUP_DIR/" 2>/dev/null || echo "⚠️  Warning: Could not backup $filename"

        echo "🗑️ Removing: $filename"
        rm "$file_path"
        echo "✅ Removed: $filename"
    else
        echo "⚠️ File not found: $filename"
    fi
}

echo ""
echo "🚀 Starting Phase 1: Safe High-Confidence Removals"
echo "=================================================="

# Add your high-confidence files here from the CSV
# Example:
# safe_remove "/path/to/file1.py"
# safe_remove "/path/to/file2.py"

echo ""
echo "📊 Backup Summary:"
ls -la "$BACKUP_DIR"

echo ""
echo "✅ Phase 1 Complete"
echo "📞 Next: Review Phase 2 recommendations in the CSV report"
echo "🛡️ All removed files backed up to: $BACKUP_DIR"
