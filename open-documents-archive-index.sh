#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail

# Steven's Digital Archive - Quick Launcher

echo "🚀 Opening Steven's Digital Archive..."
echo "📁 Location: /Users/steven/Documents"
echo ""

# Open the main archive page
open /Users/steven/Documents/index.html

echo "✅ Archive opened in your default browser!"
echo ""
echo "📋 Available pages:"
echo "  • Main Archive: index.html"
echo "  • Search: search.html"
echo "  • Categories: categories/"
echo ""
echo "🔧 To regenerate the index:"
echo "  python3 generate_index.py"
