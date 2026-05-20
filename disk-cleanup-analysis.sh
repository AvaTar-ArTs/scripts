#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail


# Comprehensive Disk Cleanup Analysis and Recommendations
# Based on analysis of ~/ directory (148GB total)

echo "🎯 DISK CLEANUP ANALYSIS & RECOMMENDATIONS"
echo "=========================================="
echo "📊 Total home directory size: 148GB"
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

echo "📁 LARGEST DIRECTORIES BY SIZE:"
echo "==============================="
echo "1. Pictures: 36GB (24% of total)"
echo "2. Library: 28GB (19% of total)"
echo "3. Movies: 27GB (18% of total)"
echo "4. Music: 12GB (8% of total)"
echo "5. Documents: 10GB (7% of total)"
echo "6. tehSiTes: 7.4GB (5% of total)"
echo "7. AvaTarArTs: 2.8GB (2% of total)"
echo ""

echo "🔍 MAJOR CLEANUP OPPORTUNITIES:"
echo "==============================="

echo ""
echo "1. 🗂️  LOG FILES (2.4GB+ potential savings):"
echo "   - /Users/steven/.cursor/projects/Users-steven/worker.log (1.5GB)"
echo "   - /Users/steven/Library/Mobile Documents/com~apple~CloudDocs/cursor-agent/projects/Users-steven/worker.log (936MB)"
echo "   - Various CleanMyMac logs (10MB+)"
echo ""

echo "2. 🐍 PYTHON CACHE (200MB+ potential savings):"
echo "   - 58,856 __pycache__ directories found"
echo "   - Largest: /Users/steven/.pyenv/versions/3.11.9/lib/python3.11/test/__pycache__ (76MB)"
echo "   - Multiple Python versions with duplicate test caches"
echo ""

echo "3. 📦 NODE_MODULES (1.5GB+ potential savings):"
echo "   - 10+ node_modules directories found"
echo "   - Largest: /Users/steven/tehSiTes/steven-chaplinski-website/node_modules (363MB)"
echo "   - Multiple versions of same packages across projects"
echo ""

echo "4. 🗃️  DUPLICATE ZIP FILES (500MB+ potential savings):"
echo "   - Hundreds of duplicate zip files found"
echo "   - Many npm package zips in multiple locations"
echo "   - Archive.zip appears in multiple locations"
echo "   - backup.zip files scattered throughout"
echo ""

echo "5. 🎬 LARGE MEDIA FILES (5GB+ potential savings):"
echo "   - Pictures/etsy: 23GB (largest single directory)"
echo "   - Movies/Ai-Art-Mp4: 9.0GB"
echo "   - Movies/invideo: 6.2GB"
echo "   - Multiple large video files (715MB+ each)"
echo ""

echo "6. 🗂️  APPLICATION SUPPORT (3GB+ potential savings):"
echo "   - Google: 3.4GB"
echo "   - com.wiheads.paste-setapp: 2.1GB"
echo "   - Cursor: 1.3GB"
echo "   - Alfred: 1.3GB"
echo ""

echo "7. 🎵 MUSIC PROJECT FILES (2GB+ potential savings):"
echo "   - Large PDF files (206MB, 301MB)"
echo "   - Duplicate zip files (142MB each)"
echo "   - Large markdown files (249MB, 120MB)"
echo ""

echo "8. 🔧 DEVELOPMENT TOOLS (1GB+ potential savings):"
echo "   - .git directories: 155MB (llama.cpp)"
echo "   - Miniforge3: 1.7GB"
echo "   - Multiple Python environments"
echo ""

echo "💡 SPECIFIC CLEANUP RECOMMENDATIONS:"
echo "===================================="

echo ""
echo "🚨 IMMEDIATE HIGH-IMPACT CLEANUPS:"
echo "----------------------------------"
echo "1. Delete large log files:"
echo "   rm /Users/steven/.cursor/projects/Users-steven/worker.log"
echo "   rm /Users/steven/Library/Mobile\ Documents/com~apple~CloudDocs/cursor-agent/projects/Users-steven/worker.log"
echo "   # Potential savings: 2.4GB"
echo ""

echo "2. Clean Python caches:"
echo "   find ~/ -name '__pycache__' -type d -exec rm -rf {} + 2>/dev/null"
echo "   find ~/ -name '*.pyc' -delete"
echo "   # Potential savings: 200MB+"
echo ""

echo "3. Remove duplicate zip files:"
echo "   find ~/ -name 'backup.zip' -not -path '*/node_modules/*' -delete"
echo "   find ~/ -name 'Archive.zip' -not -path '*/node_modules/*' -delete"
echo "   # Potential savings: 500MB+"
echo ""

echo "4. Clean node_modules in unused projects:"
echo "   # Review and remove unused project node_modules"
echo "   # Potential savings: 1.5GB+"
echo ""

echo "🎯 MEDIUM-IMPACT CLEANUPS:"
echo "-------------------------"
echo "5. Optimize Pictures directory:"
echo "   # Compress or move large image collections"
echo "   # Pictures/etsy: 23GB - consider archiving or compressing"
echo "   # Potential savings: 5-10GB"
echo ""

echo "6. Clean application caches:"
echo "   # Clear browser caches, application logs"
echo "   # Potential savings: 1-2GB"
echo ""

echo "7. Archive old projects:"
echo "   # Compress or move old development projects"
echo "   # tehSiTes: 7.4GB - archive completed projects"
echo "   # Potential savings: 3-5GB"
echo ""

echo "🔧 AUTOMATED CLEANUP SCRIPT:"
echo "============================"
echo ""

cat << 'EOF'
#!/bin/bash
# Automated cleanup script

echo "🧹 Starting automated cleanup..."

# 1. Remove log files
echo "Removing large log files..."
rm -f /Users/steven/.cursor/projects/Users-steven/worker.log
rm -f "/Users/steven/Library/Mobile Documents/com~apple~CloudDocs/cursor-agent/projects/Users-steven/worker.log"

# 2. Clean Python caches
echo "Cleaning Python caches..."
find ~/ -name '__pycache__' -type d -exec rm -rf {} + 2>/dev/null
find ~/ -name '*.pyc' -delete 2>/dev/null

# 3. Remove duplicate zip files
echo "Removing duplicate zip files..."
find ~/ -name 'backup.zip' -not -path '*/node_modules/*' -delete 2>/dev/null
find ~/ -name 'Archive.zip' -not -path '*/node_modules/*' -delete 2>/dev/null

# 4. Clean temporary files
echo "Cleaning temporary files..."
find ~/ -name '*.tmp' -delete 2>/dev/null
find ~/ -name '*.temp' -delete 2>/dev/null
find ~/ -name '*~' -delete 2>/dev/null

# 5. Clean application caches
echo "Cleaning application caches..."
rm -rf ~/Library/Caches/* 2>/dev/null

echo "✅ Cleanup completed!"
echo "Run 'du -sh ~/' to check new size"
EOF

echo ""
echo "📊 ESTIMATED TOTAL SAVINGS:"
echo "==========================="
echo "Immediate cleanups: 4-5GB"
echo "Medium cleanups: 8-15GB"
echo "Total potential savings: 12-20GB (8-14% reduction)"
echo ""

echo "⚠️  SAFETY RECOMMENDATIONS:"
echo "=========================="
echo "1. Always backup important data before cleanup"
echo "2. Test cleanup commands on small directories first"
echo "3. Review each file before deletion"
echo "4. Keep recent backups of critical projects"
echo ""

echo "🎯 NEXT STEPS:"
echo "=============="
echo "1. Run the automated cleanup script"
echo "2. Manually review large directories (Pictures, Movies)"
echo "3. Archive old projects instead of deleting"
echo "4. Set up regular cleanup schedule"
echo "5. Monitor disk usage with: du -sh ~/* | sort -hr"
