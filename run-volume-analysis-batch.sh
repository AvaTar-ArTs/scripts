#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail

# Batch Volume Analyzer - Process one volume at a time

VOLUMES=(
    "/Volumes/2T-Xx"
    "/Volumes/DeVonDaTa"
)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ANALYZER="$SCRIPT_DIR/advanced_batch_volume_analyzer.py"

echo "🚀 Starting Advanced Volume Analysis (Batch Mode)"
echo "=================================================="
echo ""

for i in "${!VOLUMES[@]}"; do
    VOLUME="${VOLUMES[$i]}"
    VOLUME_NAME=$(basename "$VOLUME")
    BATCH_NUM=$((i + 1))
    TOTAL=${#VOLUMES[@]}
    
    echo ""
    echo "############################################################"
    echo "# BATCH $BATCH_NUM/$TOTAL: $VOLUME_NAME"
    echo "############################################################"
    echo ""
    
    if [ ! -d "$VOLUME" ]; then
        echo "⚠️  Volume not found: $VOLUME"
        echo "   Skipping..."
        continue
    fi
    
    echo "📦 Analyzing: $VOLUME"
    echo "   Started: $(date '+%Y-%m-%d %H:%M:%S')"
    echo ""
    
    # Run analyzer for this volume
    python3 "$ANALYZER" \
        --volume "$VOLUME" \
        --max-scripts 100 \
        --max-depth 4 \
        --files-per-dir 50
    
    EXIT_CODE=$?
    
    if [ $EXIT_CODE -eq 0 ]; then
        echo ""
        echo "✅ Batch $BATCH_NUM/$TOTAL complete!"
        echo "   Finished: $(date '+%Y-%m-%d %H:%M:%S')"
    else
        echo ""
        echo "❌ Batch $BATCH_NUM/$TOTAL failed with exit code $EXIT_CODE"
    fi
    
    echo ""
    echo "---"
    echo ""
    
    # Ask if user wants to continue (optional)
    # read -p "Press Enter to continue to next volume, or Ctrl+C to stop..."
done

echo ""
echo "🎉 All volumes analyzed!"
echo ""
