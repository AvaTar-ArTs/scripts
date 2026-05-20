#!/bin/bash
# ⚡ **QUICK HIDDEN FILES & RECENT ACTIVITY SCAN**

set -e

echo "⚡ QUICK HIDDEN FILES & RECENT ACTIVITY SCAN"
echo "==========================================="

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
ONE_DAY_AGO=$((NOW - 86400))
ONE_HOUR_AGO=$((NOW - 3600))

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

format_time() {
    local timestamp="$1"
    date -r "$timestamp" "+%Y-%m-%d %H:%M:%S" 2>/dev/null || echo "unknown"
}

echo ""
section "LAST 24 HOURS ACTIVITY"
echo "=========================="

echo ""
info "🔥 RECENTLY MODIFIED FILES (last 24h):"
echo "======================================="

# Quick scan of recent files (excluding system/cache)
find "$HOME" -type f -newermt "24 hours ago" 2>/dev/null \
    -not -path "*/Library/*" \
    -not -path "*/.cache/*" \
    -not -path "*/node_modules/*" \
    -not -path "*/.git/*" \
    -not -path "*/__pycache__/*" | head -30 | while read -r file; do

    filename=$(basename "$file")
    dirname=$(dirname "$file" | sed "s|$HOME|~|")
    size=$(stat -f %z "$file" 2>/dev/null || echo "0")
    mod_time=$(stat -f %m "$file" 2>/dev/null || echo "0")
    time_formatted=$(format_time "$mod_time")

    if is_very_recent "$file"; then
        recent "🆕🆕 $filename (${size}b) - $dirname [$time_formatted]"
    else
        recent "🆕 $filename (${size}b) - $dirname [$time_formatted]"
    fi
done

echo ""
section "HIDDEN DIRECTORIES OVERVIEW"
echo "==============================="

echo ""
info "📂 MAJOR HIDDEN DIRECTORIES:"
echo "============================"

hidden_dirs=(
    ".claude:🤖 AI Assistant Config"
    ".cursor:🖥️  IDE & AI Tools"
    ".config:⚙️  System Configuration"
    ".env.d:🔐 API Keys & Secrets"
    ".git:📚 Git Repository"
    ".vscode:💻 Code Editor Config"
    ".ssh:🔑 SSH Keys"
    ".npm:📦 Node Package Manager"
    ".cache:🗄️  System Cache"
    ".zsh_history:📜 Shell History"
    ".DS_Store:🍎 macOS System File"
)

for entry in "${hidden_dirs[@]}"; do
    IFS=':' read -r dirname description <<< "$entry"

    if [ -e "$HOME/$dirname" ]; then
        if [ -d "$HOME/$dirname" ]; then
            # It's a directory
            file_count=$(find "$HOME/$dirname" -type f 2>/dev/null | wc -l)
            size=$(du -sh "$HOME/$dirname" 2>/dev/null | cut -f1)

            # Check for recent activity
            recent_count=$(find "$HOME/$dirname" -type f -newermt "24 hours ago" 2>/dev/null | wc -l)

            if [ "$recent_count" -gt 0 ]; then
                recent "$description ($dirname): $file_count files, $size - $recent_count recent"
            else
                echo "$description ($dirname): $file_count files, $size"
            fi
        else
            # It's a file
            size=$(stat -f %z "$HOME/$dirname" 2>/dev/null || echo "0")
            mod_time=$(stat -f %m "$HOME/$dirname" 2>/dev/null || echo "0")
            time_formatted=$(format_time "$mod_time")

            if is_recent "$HOME/$dirname"; then
                recent "$description ($dirname): ${size}b - $time_formatted [RECENT]"
            else
                echo "$description ($dirname): ${size}b - $time_formatted"
            fi
        fi
    fi
done

echo ""
section "HIDDEN FILES IN HOME DIRECTORY"
echo "==================================="

echo ""
info "📄 HIDDEN FILES (~/.*):"
echo "======================="

# Quick scan of hidden files in home (not directories)
hidden_files=$(find "$HOME" -maxdepth 1 -name ".*" -type f 2>/dev/null)

if [ -n "$hidden_files" ]; then
    echo "$hidden_files" | while read -r file; do
        filename=$(basename "$file")
        size=$(stat -f %z "$file" 2>/dev/null || echo "0")
        mod_time=$(stat -f %m "$file" 2>/dev/null || echo "0")
        time_formatted=$(format_time "$mod_time")

        if is_very_recent "$file"; then
            recent "🆕🆕 $filename (${size}b) - $time_formatted [VERY RECENT]"
        elif is_recent "$file"; then
            recent "🆕 $filename (${size}b) - $time_formatted [RECENT]"
        else
            echo "📄 $filename (${size}b) - $time_formatted"
        fi
    done
else
    info "No hidden files found in home directory"
fi

echo ""
section "ACTIVITY SUMMARY"
echo "=================="

# Quick activity counts
recent_24h=$(find "$HOME" -type f -newermt "24 hours ago" 2>/dev/null -not -path "*/Library/*" -not -path "*/.cache/*" -not -path "*/node_modules/*" -not -path "*/.git/*" | wc -l)
recent_1h=$(find "$HOME" -type f -newermt "1 hour ago" 2>/dev/null -not -path "*/Library/*" -not -path "*/.cache/*" -not -path "*/node_modules/*" -not -path "*/.git/*" | wc -l)

hidden_dirs_count=$(find "$HOME" -maxdepth 1 -name ".*" -type d 2>/dev/null | wc -l)
hidden_files_count=$(find "$HOME" -maxdepth 1 -name ".*" -type f 2>/dev/null | wc -l)

echo ""
count "📊 QUICK STATS:"
count "==============="
count "Files modified last 24h: $recent_24h"
count "Files modified last 1h:  $recent_1h"
count "Hidden directories:      $hidden_dirs_count"
count "Hidden files in home:    $hidden_files_count"

echo ""
info "🎯 KEY INSIGHTS FROM QUICK SCAN:"
echo "================================"
echo "• High recent activity indicates active development/organization"
echo "• Large AI tool configurations (.claude, .cursor) are significant"
echo "• System configuration is mature and stable"
echo "• Most hidden files are infrastructure, not user content"

echo ""
warning "NOTE: This is a quick surface scan. For deep analysis of specific"
warning "hidden directories (like .claude with 11K+ files), use targeted scans."

echo ""
status "Quick hidden files and recent activity scan complete! ⚡"