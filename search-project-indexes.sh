#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail

# Search projects by name or keyword

if [ $# -eq 0 ]; then
    echo "Usage: $0 <search_term>"
    echo "Example: $0 'cleanconnect'"
    echo "Example: $0 'python'"
    exit 1
fi

SEARCH_TERM="$1"
echo "🔍 Searching for: '$SEARCH_TERM'"
echo "=================================="

# Search in directory index
echo "📁 Directories:"
grep -i "$SEARCH_TERM" directory_index.txt | head -20

echo ""
echo "📄 Files:"
grep -i "$SEARCH_TERM" file_index.txt | head -20

echo ""
echo "📊 Summary:"
DIR_COUNT=$(grep -i "$SEARCH_TERM" directory_index.txt | wc -l)
FILE_COUNT=$(grep -i "$SEARCH_TERM" file_index.txt | wc -l)
echo "Found $DIR_COUNT directories and $FILE_COUNT files matching '$SEARCH_TERM'"
