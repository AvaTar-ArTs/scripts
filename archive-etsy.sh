#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail

# Etsy Design Archive Script
# Archives old Etsy design folders to external storage

ETSY_DIR="$HOME/Pictures/etsy"
ARCHIVE_BASE="$HOME/Pictures/_archive/etsy"

echo "=========================================="
echo "  Etsy Design Archive Tool"
echo "=========================================="
echo ""
echo "This will archive Etsy folders older than 180 days"
echo ""

# Check if archive location exists
if [ ! -d "$HOME/Pictures/_archive" ]; then
    mkdir -p "$HOME/Pictures/_archive/etsy"
fi

echo "📊 Folders to archive (based on age):"
echo ""

# Show what would be archived (based on CSV)
echo "Review ~/etsy_archive_plan_*.csv for details"
echo ""
echo "⚠️  DRY RUN MODE"
echo ""
echo "To execute, run:"
echo "   bash ~/archive_etsy.sh --execute"
echo ""

if [[ "$1" == "--execute" ]]; then
    echo "🚀 EXECUTING ARCHIVE..."
    echo "Please mount external drive first, then specify path:"
    read -p "External drive path (e.g., /Volumes/MyDrive): " EXTERNAL
    
    if [ ! -d "$EXTERNAL" ]; then
        echo "❌ Path not found: $EXTERNAL"
        exit 1
    fi
    
    EXTERNAL_ETSY="$EXTERNAL/Archived_Etsy_Designs"
    mkdir -p "$EXTERNAL_ETSY"
    
    echo "Archiving to: $EXTERNAL_ETSY"
    echo "(This is a placeholder - manual review of CSV required first)"
else
    echo "✅ Dry run complete. Review etsy_archive_plan CSV first."
fi
