#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail

# Quick helper script to run multi-folder analysis

# Default to /Volumes/2t-xx if no argument provided
TARGET_DIR="${1:-/Volumes/2t-xx}"
MAX_DEPTH="${2:-3}"

echo "🔍 Analyzing: $TARGET_DIR"
echo "📊 Max Depth: $MAX_DEPTH"
echo ""

# Run analysis with CSV generation
python3 ~/analyze_multi_folders.py "$TARGET_DIR" \
    --max-depth "$MAX_DEPTH" \
    --generate-csvs \
    --output-dir ~/csv_outputs

echo ""
echo "✅ Done! Check ~/csv_outputs for generated CSV files"
