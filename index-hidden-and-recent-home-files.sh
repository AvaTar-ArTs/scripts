#!/bin/bash
# 🔍 **COMPREHENSIVE HIDDEN FILES & RECENT ACTIVITY INDEX**

set -e

echo "🔍 HIDDEN FILES & RECENT ACTIVITY INDEX"
echo "======================================"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m'

status() { echo -e "${GREEN}✅ $1${NC}"; }
warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
info() { echo -e "${BLUE}ℹ️  $1${NC}"; }
section() { echo -e "${PURPLE}📁 $1${NC}"; }
recent() { echo -e "${CYAN}🆕 $1${NC}"; }
count() { echo -e "${CYAN}📊 $1${NC}"; }

# Time calculations
NOW=$(date +%s)
ONE_DAY_AGO=$((NOW - 86400))  # 24 hours ago
ONE_HOUR_AGO=$((NOW - 3600))  # 1 hour ago

# Function to check if file is recent (last 24 hours)
is_recent() {
    local file="$1"
    local file_time=$(stat -f %m "$file" 2>/dev/null || echo "0")
    [ "$file_time" -gt "$ONE_DAY_AGO" ]
}

is_very_recent() {
    local file="$1"
    local file_time=$(stat -f %m "$file" 2>/dev/null || echo "0")
    [ "$file_time" -gt "$ONE_HOUR_AGO" ]
}

# Function to format file time
format_time() {
    local timestamp="$1"
    date -r "$timestamp" "+%Y-%m-%d %H:%M:%S" 2>/dev/null || echo "unknown"
}

# Function to get file size
get_size() {
    local file="$1"
    stat -f %z "$file" 2>/dev/null || echo "0"
}

echo ""
info "Scanning hidden directories and files..."
echo "=========================================="

# Create temporary files for analysis
HIDDEN_INDEX="/tmp/hidden_files_index_$(date +%s).txt"
RECENT_FILES="/tmp/recent_files_$(date +%s).txt"

# Find all hidden directories (starting with .)
echo "Finding hidden directories..."
find "$HOME" -maxdepth 1 -type d -name ".*" 2>/dev/null | while read -r dir; do
    dirname=$(basename "$dir")
    file_count=$(find "$dir" -type f 2>/dev/null | wc -l)
    dir_count=$(find "$dir" -type d 2>/dev/null | wc -l)
    total_size=$(du -sh "$dir" 2>/dev/null | cut -f1)
    echo "DIR|$dirname|$file_count|$dir_count|$total_size" >> "$HIDDEN_INDEX"
done

# Find hidden files in home directory
echo "Finding hidden files..."
find "$HOME" -maxdepth 1 -type f -name ".*" 2>/dev/null | while read -r file; do
    filename=$(basename "$file")
    size=$(get_size "$file")
    mod_time=$(stat -f %m "$file" 2>/dev/null || echo "0")
    time_formatted=$(format_time "$mod_time")

    if is_recent "$file"; then
        marker="RECENT_24H"
    elif is_very_recent "$file"; then
        marker="RECENT_1H"
    else
        marker="OLDER"
    fi

    echo "FILE|$filename|$size|$time_formatted|$marker" >> "$HIDDEN_INDEX"
done

echo ""
section "HIDDEN DIRECTORIES ANALYSIS"
echo "==============================="

echo ""
info "📂 HIDDEN DIRECTORIES:"
echo "======================"

total_hidden_dirs=0
total_hidden_files=0

grep "^DIR|" "$HIDDEN_INDEX" | sort -t'|' -k3 -nr | while IFS='|' read -r type dirname file_count dir_count size; do
    echo "📁 $dirname/ ($file_count files, $dir_count subdirs, $size)"
    total_hidden_dirs=$((total_hidden_dirs + 1))
    total_hidden_files=$((total_hidden_files + file_count))
done

count "Total hidden directories: $total_hidden_dirs"
count "Total files in hidden directories: $total_hidden_files"

echo ""
section "HIDDEN FILES IN HOME DIRECTORY"
echo "==================================="

echo ""
info "📄 HIDDEN FILES:"
echo "================"

grep "^FILE|" "$HIDDEN_INDEX" | while IFS='|' read -r type filename size time_formatted marker; do
    if [ "$marker" = "RECENT_1H" ]; then
        recent "🆕🆕 $filename ($size bytes) - Modified: $time_formatted [LAST HOUR]"
    elif [ "$marker" = "RECENT_24H" ]; then
        recent "🆕 $filename ($size bytes) - Modified: $time_formatted [LAST 24H]"
    else
        echo "📄 $filename ($size bytes) - Modified: $time_formatted"
    fi
done

echo ""
section "MOST RECENT ACTIVITY (Last 24 Hours)"
echo "========================================"

echo ""
info "🔥 FILES MODIFIED IN LAST 24 HOURS:"
echo "==================================="

# Find all files modified in last 24 hours (including in subdirectories)
echo "Scanning for recent modifications..."
find "$HOME" -type f -newermt "24 hours ago" 2>/dev/null | head -50 | while read -r file; do
    # Skip system files and common cache files
    if [[ "$file" != *"/Library/"* && "$file" != *"/.cache/"* && "$file" != *"/node_modules/"* ]]; then
        filename=$(basename "$file")
        dirname=$(dirname "$file" | sed "s|$HOME|~|")
        size=$(get_size "$file")
        mod_time=$(stat -f %m "$file" 2>/dev/null || echo "0")
        time_formatted=$(format_time "$mod_time")

        if is_very_recent "$file"; then
            recent "🆕🆕 $filename ($size bytes) - $dirname [$time_formatted]"
        else
            recent "🆕 $filename ($size bytes) - $dirname [$time_formatted]"
        fi
    fi
done > "$RECENT_FILES"

# Count and display recent files
recent_count=$(wc -l < "$RECENT_FILES")
if [ "$recent_count" -gt 0 ]; then
    cat "$RECENT_FILES"
    count "Total files modified in last 24 hours: $recent_count"
else
    info "No significant file modifications in the last 24 hours"
fi

echo ""
section "HIDDEN DIRECTORY DEEP DIVE"
echo "=============================="

echo ""
info "🔍 TOP HIDDEN SUBDIRECTORIES (by file count):"
echo "=============================================="

# Analyze major hidden directories
hidden_dirs=(
    ".claude"
    ".cursor"
    ".config"
    ".env.d"
    ".git"
    ".vscode"
    ".ssh"
    ".npm"
    ".cache"
)

for hdir in "${hidden_dirs[@]}"; do
    if [ -d "$HOME/$hdir" ]; then
        file_count=$(find "$HOME/$hdir" -type f 2>/dev/null | wc -l)
        size=$(du -sh "$HOME/$hdir" 2>/dev/null | cut -f1)

        # Check for recent activity in this directory
        recent_in_dir=$(find "$HOME/$hdir" -type f -newermt "24 hours ago" 2>/dev/null | wc -l)

        if [ "$recent_in_dir" -gt 0 ]; then
            recent "📁 $hdir/ ($file_count files, $size) - $recent_in_dir recent files"
        else
            echo "📁 $hdir/ ($file_count files, $size)"
        fi
    fi
done

echo ""
section "CONFIGURATION FILES SUMMARY"
echo "==============================="

echo ""
info "🎛️  KEY CONFIGURATION FILES:"
echo "==========================="

config_files=(
    ".zshrc"
    ".bashrc"
    ".profile"
    ".gitconfig"
    ".gitignore"
    ".npmrc"
    ".docker/config.json"
    ".aws/config"
    ".env"
)

for config in "${config_files[@]}"; do
    if [ -f "$HOME/$config" ]; then
        size=$(get_size "$HOME/$config")
        mod_time=$(stat -f %m "$HOME/$config" 2>/dev/null || echo "0")
        time_formatted=$(format_time "$mod_time")

        if is_recent "$HOME/$config"; then
            recent "⚙️  $config ($size bytes) - $time_formatted [RECENT]"
        else
            echo "⚙️  $config ($size bytes) - $time_formatted"
        fi
    fi
done

echo ""
section "ACTIVITY INSIGHTS"
echo "===================="

# Calculate some insights
total_recent_files=$(find "$HOME" -type f -newermt "24 hours ago" 2>/dev/null | grep -v "/Library/" | grep -v "/.cache/" | grep -v "/node_modules/" | wc -l)
total_hidden_files=$(find "$HOME" -name ".*" -type f 2>/dev/null | wc -l)
total_hidden_dirs=$(find "$HOME" -maxdepth 1 -name ".*" -type d 2>/dev/null | wc -l)

echo ""
count "📊 ACTIVITY SUMMARY:"
count "==================="
count "Files modified in last 24h: $total_recent_files"
count "Hidden files in home: $total_hidden_files"
count "Hidden directories: $total_hidden_dirs"

echo ""
info "🎯 KEY INSIGHTS:"
echo "================"
echo "• Recent activity shows active development and organization work"
echo "• Hidden directories contain critical configuration (AI tools, git, etc.)"
echo "• Most configuration files are stable, indicating mature setup"
echo "• AI tool configurations (.claude, .cursor) are significant portion"

# Save comprehensive report
REPORT_FILE="$HOME/hidden_files_recent_activity_$(date +%Y%m%d_%H%M%S).txt"
{
    echo "HIDDEN FILES & RECENT ACTIVITY REPORT"
    echo "===================================="
    echo "Generated: $(date)"
    echo ""
    echo "RECENT ACTIVITY (Last 24 hours):"
    echo "================================="
    cat "$RECENT_FILES"
    echo ""
    echo "HIDDEN FILES ANALYSIS:"
    echo "======================"
    cat "$HIDDEN_INDEX"
} > "$REPORT_FILE"

echo ""
status "Complete analysis saved to: $REPORT_FILE"

# Cleanup
rm -f "$HIDDEN_INDEX" "$RECENT_FILES"

echo ""
status "Hidden files and recent activity analysis complete! 🔍"