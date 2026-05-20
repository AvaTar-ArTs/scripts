#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail


# Clipboard Master Navigation Launcher
# Opens the consolidated clipboard navigation in your default browser

echo "🗺️  Opening Clipboard Master Navigation..."
echo "📁 Location: /Users/steven/clipboard_master_navigation.html"
echo ""

# Check if file exists
if [ -f "/Users/steven/clipboard_master_navigation.html" ]; then
    # Open in default browser
    open "/Users/steven/clipboard_master_navigation.html"
    echo "✅ Navigation opened in your default browser!"
    echo ""
    echo "📋 Available navigation sections:"
    echo "   📅 Timeline Navigation - Browse by date and time"
    echo "   🔗 Source Navigation - Browse by application source"
    echo "   📄 Content Types - Browse by content type"
    echo "   ✨ Consolidated View - Deduplicated content"
    echo "   🔍 Search & Discovery - Search and analytics tools"
    echo ""
    echo "💡 Tip: Use the collapsible sections to explore your clipboard items!"
else
    echo "❌ Navigation file not found!"
    echo "   Please run the consolidation process first:"
    echo "   python3 execute_consolidation.py"
fi
