#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail

# Safe Library Cleanup Script
# Optimized for ~/Library directory
# Run with: bash ~/library_cleanup.sh

echo "🧹 Starting safe Library cleanup..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Track space before
echo "📊 Measuring current Library size..."
BEFORE=$(du -sh ~/Library 2>/dev/null | awk '{print $1}')
echo "   Current size: $BEFORE"
echo ""

# Safe cache cleanup
echo "1️⃣  Clearing browser caches..."
rm -rf ~/Library/Caches/Google/* 2>/dev/null
rm -rf ~/Library/Caches/Mozilla/* 2>/dev/null
rm -rf ~/Library/Caches/Firefox/* 2>/dev/null
echo "   ✅ Browser caches cleared"

# System caches
echo "2️⃣  Clearing system caches..."
rm -rf ~/Library/Caches/CloudKit/* 2>/dev/null
rm -rf ~/Library/Caches/com.apple.helpd/* 2>/dev/null
rm -rf ~/Library/Caches/com.apple.parsecd/* 2>/dev/null
echo "   ✅ System caches cleared"

# Messages cache (safe - keeps actual messages)
echo "3️⃣  Clearing Messages cache..."
rm -rf ~/Library/Messages/Caches/* 2>/dev/null
echo "   ✅ Messages cache cleared (messages preserved)"

# Cursor cleanup
echo "4️⃣  Clearing Cursor IDE logs..."
rm -rf ~/Library/Application\ Support/Cursor/logs/* 2>/dev/null
rm -rf ~/Library/Application\ Support/Cursor/Cache/* 2>/dev/null
rm -rf ~/Library/Application\ Support/Cursor/GPUCache/* 2>/dev/null
echo "   ✅ Cursor logs cleared"

# Chrome cache (only if Chrome not running)
if ! pgrep -x "Google Chrome" > /dev/null; then
    echo "5️⃣  Clearing Chrome cache..."
    rm -rf ~/Library/Application\ Support/Google/Chrome/Default/Cache/* 2>/dev/null
    rm -rf ~/Library/Application\ Support/Google/Chrome/Default/Service\ Worker/CacheStorage/* 2>/dev/null
    echo "   ✅ Chrome cache cleared"
else
    echo "5️⃣  ⚠️  Chrome is running - skipping cache cleanup"
    echo "   💡 Close Chrome and run again for additional savings"
fi

# Homebrew
echo "6️⃣  Running Homebrew cleanup..."
if command -v brew &> /dev/null; then
    brew cleanup 2>/dev/null
    echo "   ✅ Homebrew cleaned"
else
    echo "   ℹ️  Homebrew not found (skipping)"
fi

# Temp directories
echo "7️⃣  Clearing temporary files..."
rm -rf ~/Library/Application\ Support/Cursor/Service\ Worker/CacheStorage/* 2>/dev/null
rm -rf ~/Library/Application\ Support/Code/Cache/* 2>/dev/null
rm -rf ~/Library/Application\ Support/Code/CachedData/* 2>/dev/null
echo "   ✅ Temporary files cleared"

# Measure after
echo ""
echo "📊 Measuring final Library size..."
AFTER=$(du -sh ~/Library 2>/dev/null | awk '{print $1}')
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✨ Cleanup complete!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "   Before: $BEFORE"
echo "   After:  $AFTER"
echo ""
echo "💡 For additional savings, manually review:"
echo "   • ~/Library/Fonts (864MB - 758 fonts!)"
echo "   • Paste clipboard history (850MB)"
echo "   • Browser settings for deeper cache clearing"
echo ""
echo "📄 Full analysis available at:"
echo "   ~/LIBRARY_ANALYSIS_REPORT.md"
echo ""
echo "🎯 Run this script monthly for optimal performance!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
