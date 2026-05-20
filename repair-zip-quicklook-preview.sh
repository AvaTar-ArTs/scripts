#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail

# Fix Finder ZIP file previews in Quick Look

echo "🔧 Fixing Finder ZIP Preview..."
echo ""

# 1. Clear Quick Look cache
echo "1. Clearing Quick Look cache..."
qlmanage -r
qlmanage -r cache
rm -rf ~/Library/Caches/com.apple.QuickLook.thumbnailcache
killall Finder 2>/dev/null

# 2. Reset Quick Look database
echo "2. Resetting Quick Look database..."
rm -rf ~/Library/QuickLook/*.qlcache 2>/dev/null
rm -rf ~/Library/QuickLook/*.db 2>/dev/null

# 3. Enable Quick Look for archives
echo "3. Enabling Quick Look settings..."
defaults write com.apple.finder QLEnableTextSelection -bool true
defaults write com.apple.finder QLInlinePreviewMinimumSupportedSize -int 0

# 4. Ensure Quick Look is enabled
defaults write com.apple.finder QLInlinePreviewEnabled -bool true

# 5. Restart Quick Look daemon
echo "4. Restarting Quick Look daemon..."
killall qlmanage 2>/dev/null
qlmanage -r

# 6. Restart Finder
echo "5. Restarting Finder..."
killall Finder

echo ""
echo "✅ Done! Try previewing a ZIP file now (select it and press Spacebar)"
echo ""
echo "If it still doesn't work, try:"
echo "  - Restart your Mac"
echo "  - Check System Preferences > Extensions > Quick Look"
echo "  - Make sure no third-party plugins are interfering"
