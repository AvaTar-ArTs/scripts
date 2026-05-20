#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail


# Enhanced Disk Cleanup System
# Based on comprehensive analysis of ~/ directory (148GB)
# Integrates with existing cleanup applications

echo "🚀 ENHANCED DISK CLEANUP SYSTEM"
echo "================================"
echo "📊 Based on analysis of 148GB home directory"
echo "🎯 Target: 4.5GB+ safe space recovery"
echo ""

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

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

# Function to check if application exists
check_app() {
    local app_name=$1
    local app_path=$2
    if [ -d "$app_path" ]; then
        print_status $GREEN "✅ Found: $app_name"
        return 0
    else
        print_status $YELLOW "⚠️  Not found: $app_name"
        return 1
    fi
}

# Function to run cleanup with progress
run_cleanup() {
    local name=$1
    local command=$2
    local description=$3
    
    print_status $BLUE "🧹 $name: $description"

    # Get initial size (in KB, du -sk reports in kilobytes)
    initial_size=$(du -sk ~/ 2>/dev/null | awk '{print $1}')

    # Run the command
    eval $command
    
    # Get final size (in KB)
    final_size=$(du -sk ~/ 2>/dev/null | awk '{print $1}')
    saved_size=$((initial_size - final_size))

    if [ $saved_size -gt 0 ]; then
        # Convert KB to bytes for format_bytes function
        print_status $GREEN "   ✅ Freed: $(format_bytes $((saved_size * 1024)))"
    else
        print_status $YELLOW "   ℹ️  No space freed"
    fi
    echo ""
}

# Get initial size (in KB, convert to bytes for display)
initial_total_size=$(du -sk ~/ 2>/dev/null | awk '{print $1}')
print_status $CYAN "📏 Initial disk usage: $(format_bytes $((initial_total_size * 1024)))"
echo ""

# Check for existing cleanup applications
print_status $PURPLE "🔍 CHECKING FOR CLEANUP APPLICATIONS"
echo "================================================"

cleanup_apps_found=0

# Check for common cleanup applications
if check_app "CleanMyMac" "/Applications/CleanMyMac X.app"; then
    cleanup_apps_found=$((cleanup_apps_found + 1))
fi

if check_app "MacBooster" "/Applications/MacBooster 8.app"; then
    cleanup_apps_found=$((cleanup_apps_found + 1))
fi

if check_app "MacCleaner Pro" "/Applications/MacCleaner Pro 3.app"; then
    cleanup_apps_found=$((cleanup_apps_found + 1))
fi

if check_app "MacCleanse" "/Applications/MacCleanse.app"; then
    cleanup_apps_found=$((cleanup_apps_found + 1))
fi

if check_app "DaisyDisk" "/Applications/DaisyDisk.app"; then
    cleanup_apps_found=$((cleanup_apps_found + 1))
fi

if check_app "Disk Expert" "/Applications/Disk Expert 4.app"; then
    cleanup_apps_found=$((cleanup_apps_found + 1))
fi

if check_app "Duplicate File Finder" "/Applications/Duplicate File Finder 8.app"; then
    cleanup_apps_found=$((cleanup_apps_found + 1))
fi

if check_app "App Cleaner" "/Applications/App Cleaner 8.app"; then
    cleanup_apps_found=$((cleanup_apps_found + 1))
fi

if check_app "OnyX" "/Applications/OnyX.app"; then
    cleanup_apps_found=$((cleanup_apps_found + 1))
fi

if check_app "Maintenance" "/Applications/Maintenance.app"; then
    cleanup_apps_found=$((cleanup_apps_found + 1))
fi

echo ""
print_status $CYAN "📊 Found $cleanup_apps_found cleanup applications"
echo ""

# Phase 1: Critical Cleanup (2.5GB+)
print_status $RED "🔥 PHASE 1: CRITICAL CLEANUP (2.5GB+)"
echo "============================================="

# Remove large log files
run_cleanup "Log Files" "rm -f /Users/steven/.cursor/projects/Users-steven/worker.log '/Users/steven/Library/Mobile Documents/com~apple~CloudDocs/cursor-agent/projects/Users-steven/worker.log' 2>/dev/null" "Removing large log files"

# Clean Python caches
run_cleanup "Python Caches" "find ~/ -name '__pycache__' -type d -exec rm -rf {} + 2>/dev/null; find ~/ -name '*.pyc' -delete 2>/dev/null" "Cleaning Python cache directories"

# Clean temporary files (fixed: proper grouping for -delete to apply to all conditions)
run_cleanup "Temp Files" "find ~/ \( -name '*.tmp' -o -name '*.temp' -o -name '*~' \) -delete 2>/dev/null" "Removing temporary files"

# Phase 2: Duplicate Cleanup (1GB+)
print_status $YELLOW "⚠️  PHASE 2: DUPLICATE CLEANUP (1GB+)"
echo "============================================="

# Remove duplicate zip files
run_cleanup "Duplicate Zips" "find ~/ -name 'backup.zip' -not -path '*/node_modules/*' -delete 2>/dev/null; find ~/ -name 'Archive.zip' -not -path '*/node_modules/*' -delete 2>/dev/null" "Removing duplicate zip files"

# Clean application caches
run_cleanup "App Caches" "rm -rf ~/Library/Caches/* 2>/dev/null" "Cleaning application caches"

# Clean npm cache
if command -v npm >/dev/null 2>&1; then
    run_cleanup "NPM Cache" "npm cache clean --force 2>/dev/null" "Cleaning npm cache"
fi

# Clean pip cache
if command -v pip >/dev/null 2>&1; then
    run_cleanup "Pip Cache" "pip cache purge 2>/dev/null" "Cleaning pip cache"
fi

# Phase 3: Advanced Cleanup (500MB+)
print_status $BLUE "🔧 PHASE 3: ADVANCED CLEANUP (500MB+)"
echo "============================================="

# Clean browser caches
run_cleanup "Browser Caches" "rm -rf ~/Library/Caches/Google/Chrome/Default/Cache/* 2>/dev/null; rm -rf ~/Library/Caches/com.apple.Safari/* 2>/dev/null; rm -rf ~/Library/Caches/org.mozilla.firefox/* 2>/dev/null" "Cleaning browser caches"

# Clean system logs
run_cleanup "System Logs" "sudo rm -rf /var/log/*.log 2>/dev/null; sudo rm -rf /var/log/*.out 2>/dev/null" "Cleaning system logs (requires sudo)"

# Clean old downloads
run_cleanup "Old Downloads" "find ~/Downloads -name '*.dmg' -mtime +30 -delete 2>/dev/null; find ~/Downloads -name '*.zip' -mtime +30 -delete 2>/dev/null" "Removing old download files"

# Phase 4: Application-Specific Cleanup
print_status $PURPLE "🎯 PHASE 4: APPLICATION-SPECIFIC CLEANUP"
echo "==============================================="

# Clean Cursor caches
run_cleanup "Cursor Caches" "rm -rf ~/.cursor/logs/* 2>/dev/null; rm -rf ~/.cursor/CachedData/* 2>/dev/null" "Cleaning Cursor application caches"

# Clean Adobe caches
run_cleanup "Adobe Caches" "rm -rf ~/Library/Caches/Adobe/* 2>/dev/null; rm -rf ~/Library/Application Support/Adobe/Common/Media Cache Files/* 2>/dev/null" "Cleaning Adobe application caches"

# Clean Xcode caches (if exists)
if [ -d ~/Library/Developer/Xcode ]; then
    run_cleanup "Xcode Caches" "rm -rf ~/Library/Developer/Xcode/DerivedData/* 2>/dev/null; rm -rf ~/Library/Developer/Xcode/Archives/* 2>/dev/null" "Cleaning Xcode caches"
fi

# Clean Docker caches (if exists)
if command -v docker >/dev/null 2>&1; then
    run_cleanup "Docker Cleanup" "docker system prune -f 2>/dev/null" "Cleaning Docker system"
fi

# Phase 5: Smart Cleanup (Conditional)
print_status $GREEN "🧠 PHASE 5: SMART CLEANUP (CONDITIONAL)"
echo "============================================="

# Check for duplicate CoverAlbums.zip
if [ -f "/Users/steven/Music/nocTurneMeLoDieS/img/CoverAlbums/CoverAlbums.zip" ] && [ -f "/Users/steven/Music/nocTurneMeLoDieS/zip/CoverAlbums.zip" ]; then
    print_status $YELLOW "🔍 Found duplicate CoverAlbums.zip files"
    size1=$(du -s "/Users/steven/Music/nocTurneMeLoDieS/img/CoverAlbums/CoverAlbums.zip" | awk '{print $1}')
    size2=$(du -s "/Users/steven/Music/nocTurneMeLoDieS/zip/CoverAlbums.zip" | awk '{print $1}')
    
    if [ $size1 -eq $size2 ]; then
        print_status $GREEN "   ✅ Files are identical, removing duplicate"
        rm "/Users/steven/Music/nocTurneMeLoDieS/zip/CoverAlbums.zip" 2>/dev/null
        print_status $GREEN "   ✅ Freed: $(format_bytes $size2)"
    else
        print_status $YELLOW "   ⚠️  Files differ, keeping both"
    fi
fi

# Check for old project versions
if [ -d "/Users/steven/tehSiTes/cleanconnect-pro" ] && [ -d "/Users/steven/tehSiTes/cleanconnect-pro-2.0" ]; then
    print_status $YELLOW "🔍 Found old project version (cleanconnect-pro)"
    print_status $YELLOW "   Consider archiving old version if cleanconnect-pro-2.0 is active"
fi

# Final Results (in KB, convert to bytes for display)
final_total_size=$(du -sk ~/ 2>/dev/null | awk '{print $1}')
total_saved=$((initial_total_size - final_total_size))

echo ""
print_status $GREEN "🎉 CLEANUP COMPLETED!"
echo "===================="
print_status $CYAN "📊 Initial size: $(format_bytes $((initial_total_size * 1024)))"
print_status $CYAN "📊 Final size: $(format_bytes $((final_total_size * 1024)))"
print_status $GREEN "💾 Total space freed: $(format_bytes $((total_saved * 1024)))"

if [ $total_saved -gt 0 ]; then
    percentage=$((total_saved * 100 / initial_total_size))
    print_status $GREEN "📈 Space reduction: $percentage%"
else
    print_status $YELLOW "ℹ️  No significant space was freed"
fi

echo ""
print_status $PURPLE "🔧 RECOMMENDATIONS FOR FURTHER CLEANUP:"
echo "============================================="
echo "1. Review Pictures/etsy (23GB) - consider archiving old images"
echo "2. Review Movies directory (27GB) - compress or archive old videos"
echo "3. Review tehSiTes projects (7.4GB) - archive completed projects"
echo "4. Use DaisyDisk or Disk Expert to visualize disk usage"
echo "5. Run Duplicate File Finder to find more duplicates"
echo "6. Use App Cleaner to remove unused applications"
echo ""

print_status $BLUE "📈 MONITORING COMMANDS:"
echo "========================="
echo "du -sh ~/                    # Check total disk usage"
echo "du -sh ~/* | sort -hr | head -10  # Check largest directories"
echo "find ~/ -type f -size +100M -exec ls -lh {} \;  # Find large files"
echo ""

print_status $GREEN "✅ Enhanced cleanup system completed!"
echo "Run this script regularly for optimal disk maintenance."
