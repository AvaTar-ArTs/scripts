#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail

# AutoTagger Quick Launcher
# Created on January 21, 2026
# Quick access to AutoTagger functionality

echo "AutoTagger Quick Launcher"
echo "========================"

if [ $# -eq 0 ]; then
    echo "Usage: $0 <directory_to_analyze> [output_prefix]"
    echo "Example: $0 ~/Documents my_analysis"
    exit 1
fi

DIRECTORY_TO_ANALYZE="$1"
OUTPUT_PREFIX="${2:-analysis}"

if [ ! -d "$DIRECTORY_TO_ANALYZE" ]; then
    echo "Error: Directory $DIRECTORY_TO_ANALYZE does not exist"
    exit 1
fi

echo "Analyzing directory: $DIRECTORY_TO_ANALYZE"
echo "Output prefix: $OUTPUT_PREFIX"

cd ~/AutoTagger/current || { echo "Error: Cannot access AutoTagger directory"; exit 1; }

python3 autotagger.py "$DIRECTORY_TO_ANALYZE" --prefix "$OUTPUT_PREFIX" --formats csv,md

echo ""
echo "Analysis complete! Check ~/AutoTagger/output/ for results."
