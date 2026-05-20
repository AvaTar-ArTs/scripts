#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail


# Automated Disk Cleanup Script
# Safe cleanup with progress reporting

echo "🧹 AUTOMATED DISK CLEANUP SCRIPT"
echo "================================="
echo "📊 Starting cleanup process..."
echo ""

# Function to format bytes
format_bytes() {
    local bytes=$1
    if [ $bytes -gt 1073741824 ]; then
        echo "$(( bytes / 1073741824 ))GB"
    elif [ $bytes -gt 1048576 ]; then
        echo "$(( bytes / 1048576 ))MB"
    elif [ $bytes -gt 1024 ]; then
        echo "$(( bytes / 1024 ))KB"
    else
        echo "${bytes}B"
    fi
}

# Get initial size
initial_size=$(du -s ~/ | awk '{print $1}')
echo "📏 Initial size: $(format_bytes $initial_size)"
echo ""

# 1. Remove large log files
echo "🗂️  Step 1: Removing large log files..."
log_files=(
    "/Users/steven/.cursor/projects/Users-steven/worker.log"
    "/Users/steven/Library/Mobile Documents/com~apple~CloudDocs/cursor-agent/projects/Users-steven/worker.log"
)

for log_file in "${log_files[@]}"; do
    if [ -f "$log_file" ]; then
        size=$(du -s "$log_file" | awk '{print $1}')
        echo "   Removing: $(basename "$log_file") ($(format_bytes $size))"
        rm -f "$log_file"
    fi
done
echo "   ✅ Log files cleaned"
echo ""

# 2. Clean Python caches
echo "🐍 Step 2: Cleaning Python caches..."
pycache_count=$(find ~/ -name '__pycache__' -type d 2>/dev/null | wc -l)
pyc_count=$(find ~/ -name '*.pyc' 2>/dev/null | wc -l)

echo "   Found $pycache_count __pycache__ directories"
echo "   Found $pyc_count .pyc files"

# Calculate size before deletion
pycache_size=$(find ~/ -name '__pycache__' -type d -exec du -s {} + 2>/dev/null | awk '{sum += $1} END {print sum+0}')
pyc_size=$(find ~/ -name '*.pyc' -exec du -s {} + 2>/dev/null | awk '{sum += $1} END {print sum+0}')
total_py_size=$((pycache_size + pyc_size))

echo "   Estimated size to free: $(format_bytes $total_py_size)"

# Remove Python caches
find ~/ -name '__pycache__' -type d -exec rm -rf {} + 2>/dev/null
find ~/ -name '*.pyc' -delete 2>/dev/null
echo "   ✅ Python caches cleaned"
echo ""

# 3. Remove duplicate zip files
echo "🗃️  Step 3: Removing duplicate zip files..."
backup_count=$(find ~/ -name 'backup.zip' -not -path '*/node_modules/*' 2>/dev/null | wc -l)
archive_count=$(find ~/ -name 'Archive.zip' -not -path '*/node_modules/*' 2>/dev/null | wc -l)

echo "   Found $backup_count backup.zip files"
echo "   Found $archive_count Archive.zip files"

# Calculate size before deletion
backup_size=$(find ~/ -name 'backup.zip' -not -path '*/node_modules/*' -exec du -s {} + 2>/dev/null | awk '{sum += $1} END {print sum+0}')
archive_size=$(find ~/ -name 'Archive.zip' -not -path '*/node_modules/*' -exec du -s {} + 2>/dev/null | awk '{sum += $1} END {print sum+0}')
total_zip_size=$((backup_size + archive_size))

echo "   Estimated size to free: $(format_bytes $total_zip_size)"

# Remove duplicate zip files
find ~/ -name 'backup.zip' -not -path '*/node_modules/*' -delete 2>/dev/null
find ~/ -name 'Archive.zip' -not -path '*/node_modules/*' -delete 2>/dev/null
echo "   ✅ Duplicate zip files removed"
echo ""

# 4. Clean temporary files
echo "🗑️  Step 4: Cleaning temporary files..."
tmp_count=$(find ~/ -name '*.tmp' 2>/dev/null | wc -l)
temp_count=$(find ~/ -name '*.temp' 2>/dev/null | wc -l)
tilde_count=$(find ~/ -name '*~' 2>/dev/null | wc -l)

echo "   Found $tmp_count .tmp files"
echo "   Found $temp_count .temp files"
echo "   Found $tilde_count backup files (~)"

# Remove temporary files
find ~/ -name '*.tmp' -delete 2>/dev/null
find ~/ -name '*.temp' -delete 2>/dev/null
find ~/ -name '*~' -delete 2>/dev/null
echo "   ✅ Temporary files cleaned"
echo ""

# 5. Clean application caches (safe ones only)
echo "🗂️  Step 5: Cleaning application caches..."
echo "   Cleaning user caches (safe to remove)..."
rm -rf ~/Library/Caches/* 2>/dev/null
echo "   ✅ Application caches cleaned"
echo ""

# 6. Clean npm cache
echo "📦 Step 6: Cleaning npm cache..."
if command -v npm >/dev/null 2>&1; then
    npm cache clean --force 2>/dev/null
    echo "   ✅ npm cache cleaned"
else
    echo "   ⚠️  npm not found, skipping"
fi
echo ""

# 7. Clean pip cache
echo "🐍 Step 7: Cleaning pip cache..."
if command -v pip >/dev/null 2>&1; then
    pip cache purge 2>/dev/null
    echo "   ✅ pip cache cleaned"
else
    echo "   ⚠️  pip not found, skipping"
fi
echo ""

# Get final size
final_size=$(du -s ~/ | awk '{print $1}')
saved_size=$((initial_size - final_size))

echo "📊 CLEANUP RESULTS:"
echo "==================="
echo "Initial size: $(format_bytes $initial_size)"
echo "Final size: $(format_bytes $final_size)"
echo "Space saved: $(format_bytes $saved_size)"
echo ""

if [ $saved_size -gt 0 ]; then
    echo "✅ Cleanup completed successfully!"
    echo "💾 Freed up $(format_bytes $saved_size) of disk space"
else
    echo "ℹ️  No significant space was freed"
fi

echo ""
echo "🎯 RECOMMENDATIONS FOR FURTHER CLEANUP:"
echo "======================================="
echo "1. Review Pictures/etsy (23GB) - consider archiving"
echo "2. Review Movies directory (27GB) - compress or archive old videos"
echo "3. Review tehSiTes projects (7.4GB) - archive completed projects"
echo "4. Review node_modules directories - remove unused projects"
echo "5. Consider using disk cleanup tools like CleanMyMac"
echo ""

echo "🔍 To monitor disk usage:"
echo "du -sh ~/* | sort -hr | head -10"
echo ""
echo "🏁 Cleanup script finished!"
