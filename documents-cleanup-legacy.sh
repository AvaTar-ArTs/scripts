#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail


# Documents Cleanup and Deduplication Script
# This script will help clean up and organize ~/Documents

echo "🧹 Documents Cleanup and Deduplication Script"
echo "=============================================="
echo ""

# Create backup directory first
BACKUP_DIR="$HOME/Documents/CLEANUP_BACKUP_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"
echo "📦 Created backup directory: $BACKUP_DIR"
echo ""

# Function to safely move files
safe_move() {
    local source="$1"
    local dest="$2"
    local description="$3"
    
    if [[ -e "$source" ]]; then
        echo "📁 Moving $description: $(basename "$source")"
        mkdir -p "$(dirname "$dest")"
        mv "$source" "$dest" 2>/dev/null || {
            echo "⚠️  Failed to move: $source"
            return 1
        }
        return 0
    fi
    return 1
}

# Function to get file size
get_size() {
    du -sh "$1" 2>/dev/null | cut -f1
}

echo "🔍 Phase 1: Analyzing current state..."
echo "======================================"

# Count current files
TOTAL_FILES=$(find ~/Documents -type f | wc -l)
BACKUP_FILES=$(find ~/Documents -name "*.backup" | wc -l)
COPY_FILES=$(find ~/Documents -name "*copy*" -o -name "*Copy*" -o -name "*COPY*" | wc -l)
ZIP_FILES=$(find ~/Documents -name "*.zip" | wc -l)
TOTAL_SIZE=$(du -sh ~/Documents | cut -f1)

echo "📊 Current Statistics:"
echo "   Total files: $TOTAL_FILES"
echo "   Backup files: $BACKUP_FILES"
echo "   Copy files: $COPY_FILES"
echo "   Zip files: $ZIP_FILES"
echo "   Total size: $TOTAL_SIZE"
echo ""

echo "🗑️  Phase 2: Removing obvious duplicates..."
echo "=========================================="

# Remove .backup files (after backing up a few samples)
echo "📁 Backing up sample .backup files..."
find ~/Documents -name "*.backup" | head -10 | while read file; do
    safe_move "$file" "$BACKUP_DIR/backup_samples/$(basename "$file")" "backup sample"
done

echo "🗑️  Removing .backup files..."
BACKUP_COUNT=0
find ~/Documents -name "*.backup" | while read file; do
    if [[ -f "$file" ]]; then
        rm "$file" 2>/dev/null && ((BACKUP_COUNT++))
        if ((BACKUP_COUNT % 1000 == 0)); then
            echo "   Removed $BACKUP_COUNT backup files..."
        fi
    fi
done
echo "✅ Removed backup files"

# Remove obvious copy files
echo "🗑️  Removing obvious copy files..."
COPY_COUNT=0
find ~/Documents -name "*copy*" -o -name "*Copy*" -o -name "*COPY*" | while read file; do
    if [[ -f "$file" ]]; then
        # Check if there's an original version
        original=$(echo "$file" | sed 's/[Cc]opy[^/]*$//' | sed 's/[Cc]opy$//')
        if [[ ! -f "$original" ]]; then
            # Keep the copy if no original exists
            safe_move "$file" "$BACKUP_DIR/copy_files/$(basename "$file")" "copy file"
        else
            rm "$file" 2>/dev/null && ((COPY_COUNT++))
        fi
    fi
done
echo "✅ Processed copy files"

# Remove numbered duplicates
echo "🗑️  Removing numbered duplicates..."
find ~/Documents -name "*([0-9]*)" | while read file; do
    original=$(echo "$file" | sed 's/ ([0-9]*)//')
    if [[ -f "$original" ]]; then
        safe_move "$file" "$BACKUP_DIR/numbered_duplicates/$(basename "$file")" "numbered duplicate"
    fi
done
echo "✅ Removed numbered duplicates"

echo ""
echo "📁 Phase 3: Consolidating similar directories..."
echo "=============================================="

# Consolidate backup directories
echo "📁 Consolidating backup directories..."
BACKUP_DIRS=(
    "AvaTarArTs_Backup_20251014_143236"
    "AvaTarArTs_Work_Backup_20251014_143424" 
    "AvaTarArTs-BaCkUp"
    "BACKUP_DOCUMENTS"
    "BACKUP_ORIGINAL_STRUCTURE"
)

for dir in "${BACKUP_DIRS[@]}"; do
    if [[ -d "$HOME/Documents/$dir" ]]; then
        echo "   Moving $dir to consolidated backup..."
        safe_move "$HOME/Documents/$dir" "$BACKUP_DIR/consolidated_backups/$dir" "backup directory"
    fi
done

# Consolidate ChatGPT conversations
echo "📁 Consolidating ChatGPT conversations..."
mkdir -p "$BACKUP_DIR/chatgpt_conversations"
find ~/Documents -name "ChatGPT_Conversation*.txt" | while read file; do
    safe_move "$file" "$BACKUP_DIR/chatgpt_conversations/$(basename "$file")" "ChatGPT conversation"
done

# Consolidate zip files
echo "📁 Consolidating zip files..."
mkdir -p "$BACKUP_DIR/zip_files"
find ~/Documents -name "*.zip" | while read file; do
    safe_move "$file" "$BACKUP_DIR/zip_files/$(basename "$file")" "zip file"
done

echo ""
echo "🧹 Phase 4: Cleaning up empty directories..."
echo "=========================================="

# Remove empty directories
echo "🗑️  Removing empty directories..."
find ~/Documents -type d -empty -delete 2>/dev/null
echo "✅ Cleaned empty directories"

# Remove .DS_Store files
echo "🗑️  Removing .DS_Store files..."
find ~/Documents -name ".DS_Store" -delete 2>/dev/null
echo "✅ Removed .DS_Store files"

echo ""
echo "📊 Phase 5: Final statistics..."
echo "=============================="

NEW_TOTAL_FILES=$(find ~/Documents -type f | wc -l)
NEW_TOTAL_SIZE=$(du -sh ~/Documents | cut -f1)
BACKUP_SIZE=$(du -sh "$BACKUP_DIR" | cut -f1)

echo "📈 Results:"
echo "   Files before: $TOTAL_FILES"
echo "   Files after: $NEW_TOTAL_FILES"
echo "   Files removed: $((TOTAL_FILES - NEW_TOTAL_FILES))"
echo "   Size before: $TOTAL_SIZE"
echo "   Size after: $NEW_TOTAL_SIZE"
echo "   Backup size: $BACKUP_SIZE"
echo ""

echo "✅ Cleanup complete!"
echo "📦 Backup created at: $BACKUP_DIR"
echo ""
echo "🔍 Next steps:"
echo "   1. Review the backup directory to ensure nothing important was moved"
echo "   2. Check the remaining Documents structure"
echo "   3. Consider further organization if needed"
echo ""
echo "⚠️  Important: Review the backup before deleting it!"
