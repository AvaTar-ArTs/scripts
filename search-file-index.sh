#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail

# Search files by type or name

if [ $# -eq 0 ]; then
    echo "Usage: $0 <file_type_or_name>"
    echo "Examples:"
    echo "  $0 '.py'          # Find all Python files"
    echo "  $0 '.html'        # Find all HTML files"
    echo "  $0 'README'       # Find all README files"
    echo "  $0 'config'       # Find all config files"
    exit 1
fi

SEARCH_TERM="$1"
echo "🔍 Searching for files: '$SEARCH_TERM'"
echo "====================================="

# Search in file index
grep -i "$SEARCH_TERM" file_index.txt | head -30

echo ""
echo "📊 Summary:"
FILE_COUNT=$(grep -i "$SEARCH_TERM" file_index.txt | wc -l)
echo "Found $FILE_COUNT files matching '$SEARCH_TERM'"

if [ $FILE_COUNT -gt 30 ]; then
    echo "Showing first 30 results. Use 'grep -i \"$SEARCH_TERM\" file_index.txt' to see all."
fi
