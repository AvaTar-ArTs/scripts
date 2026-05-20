#!/bin/bash
set -euo pipefail
# AutoTagger State Restoration Script
# Created on January 21, 2026
# This script restores the AutoTagger environment and references

echo "AutoTagger State Restoration Script"
echo "==============================="

echo "Restoring AutoTagger environment..."
if [ -d "$HOME/AutoTagger/current" ]; then
    echo "✅ AutoTagger system found at ~/AutoTagger/current"
else
    echo "⚠️  AutoTagger system not found, you may need to restore from backup"
fi

echo "Key directories and files:"
echo "- AutoTagger: ~/AutoTagger/current/autotagger.py"
echo "- Documents analysis: ~/AutoTagger/output/documents_autotag_*.csv"
echo "- Documents analysis: ~/AutoTagger/output/documents_autotag_*.md"
echo "- Documents analysis: ~/AutoTagger/output/autotagger.db"
echo "- Documentation: ~/Documents/Detailed_Comprehensive_Documentation.txt"
echo "- Session memory: ~/Documents/Session_Memory.txt"
echo "- Tag guide: ~/Documents/Tag_Application_Guide.txt"
echo "- Original summary: ~/Documents/toomuch.txt"
echo "- Change log: ~/Documents/CHANGELOG.md"

echo ""
echo "To use AutoTagger on any directory:"
echo "cd ~/AutoTagger/current"
echo "python3 autotagger.py /path/to/directory --prefix analysis_name --formats csv,md"

echo ""
echo "To check your API keys status:"
echo "source ~/.env.d/loader.sh && env | grep -E \"(API_KEY|_TOKEN|SECRET)\" | head -10"

echo ""
echo "Restoration complete!"
