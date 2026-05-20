#!/bin/bash
# 🎯 **MOVE MARKETPLACE BUSINESS DOCUMENTS**
# Organize marketplace docs into MasterxEo framework

set -e

echo "🎯 MOVING MARKETPLACE BUSINESS DOCUMENTS"
echo "========================================"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

status() { echo -e "${GREEN}✅ $1${NC}"; }
warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
info() { echo -e "${BLUE}ℹ️  $1${NC}"; }
progress() { echo -e "${PURPLE}🚀 $1${NC}"; }
count() { echo -e "${CYAN}📊 $1${NC}"; }

TARGET_DIR="$HOME/MasterxEo"

echo ""
info "Target MasterxEo directory: $TARGET_DIR"
echo ""

# Ensure MasterxEo structure exists
info "Ensuring MasterxEo framework structure..."
mkdir -p "$TARGET_DIR/01_ASSETS_LIBRARY"
mkdir -p "$TARGET_DIR/02_MARKETPLACE_LISTINGS"
mkdir -p "$TARGET_DIR/03_REVENUE_TRACKING"
mkdir -p "$TARGET_DIR/04_BRANDING_KITS"
mkdir -p "$TARGET_DIR/05_DEPLOYMENT_TOOLS"
mkdir -p "$TARGET_DIR/06_BACKUP_ARCHIVE"
mkdir -p "$TARGET_DIR/07_DOCUMENTATION"
mkdir -p "$TARGET_DIR/08_MARKETPLACE_ASSETS"
status "MasterxEo framework structure ready"

# Function to safely move file
safe_move() {
    local source="$1"
    local target="$2"
    local description="$3"

    if [ -f "$source" ]; then
        cp "$source" "$target" 2>/dev/null || {
            warning "Copy failed for $source, skipping..."
            return 1
        }
        count "✓ $description → $target"
        return 0
    else
        warning "$description not found, skipping..."
        return 1
    fi
}

echo ""
progress "MOVING GUMROAD BUSINESS DOCUMENTS"
echo "==================================="

# GumRoad strategy documents
safe_move "$HOME/GUMROAD_MASTER_INDEX.md" "$TARGET_DIR/02_MARKETPLACE_LISTINGS/" "GumRoad Master Index"
safe_move "$HOME/GUMROAD_PHASE_3_EXECUTION_CHECKLIST.md" "$TARGET_DIR/02_MARKETPLACE_LISTINGS/" "GumRoad Phase 3 Checklist"
safe_move "$HOME/GUMROAD_PHASE_3_SUMMARY.md" "$TARGET_DIR/07_DOCUMENTATION/" "GumRoad Phase 3 Summary"
safe_move "$HOME/GUMROAD_EMAIL_LIST_STRATEGY.md" "$TARGET_DIR/02_MARKETPLACE_LISTINGS/" "GumRoad Email Strategy"
safe_move "$HOME/GUMROAD_BUNDLE_STRATEGY.md" "$TARGET_DIR/02_MARKETPLACE_LISTINGS/" "GumRoad Bundle Strategy"
safe_move "$HOME/GUMROAD_BUNDLE_1_PRODUCT_PAGE.md" "$TARGET_DIR/02_MARKETPLACE_LISTINGS/" "GumRoad Bundle 1 Page"
safe_move "$HOME/GUMROAD_QUICK_START.txt" "$TARGET_DIR/02_MARKETPLACE_LISTINGS/" "GumRoad Quick Start"

echo ""
progress "MOVING MARKETPLACE PLATFORM DOCUMENTS"
echo "========================================="

# Marketplace platform documents
safe_move "$HOME/MARKETPLACE_PLATFORM_QUICK_REFERENCE.md" "$TARGET_DIR/02_MARKETPLACE_LISTINGS/" "Marketplace Platform Reference"
safe_move "$HOME/CODESTER_vs_GUMROAD_STRATEGY.md" "$TARGET_DIR/02_MARKETPLACE_LISTINGS/" "Codester vs GumRoad Strategy"
safe_move "$HOME/EXECUTABLE_SCRIPTS_RANKED.csv" "$TARGET_DIR/02_MARKETPLACE_LISTINGS/" "Executable Scripts Ranking"
safe_move "$HOME/TOP_20_MARKETPLACE_DESCRIPTIONS.txt" "$TARGET_DIR/02_MARKETPLACE_LISTINGS/" "Top 20 Marketplace Descriptions"

echo ""
progress "MOVING BUSINESS SUMMARY DOCUMENTS"
echo "==================================="

# Business summary and documentation
safe_move "$HOME/SUMMARY.txt" "$TARGET_DIR/07_DOCUMENTATION/" "Business Summary"
safe_move "$HOME/README.md" "$TARGET_DIR/07_DOCUMENTATION/" "Business README"

echo ""
progress "MOVING ADDITIONAL BUSINESS FILES"
echo "=================================="

# Additional files that might exist
safe_move "$HOME/GUMROAD_BUNDLE_4_PRODUCT_PAGE.md" "$TARGET_DIR/02_MARKETPLACE_LISTINGS/" "GumRoad Bundle 4 Page"
safe_move "$HOME/PHASE_3_UPDATED_CODESTER_FIRST.md" "$TARGET_DIR/02_MARKETPLACE_LISTINGS/" "Phase 3 Updated Codester"

echo ""
progress "FINAL VERIFICATION"
echo "==================="

# Count files moved to each section
gumroad_listings=$(find "$TARGET_DIR/02_MARKETPLACE_LISTINGS" -type f 2>/dev/null | wc -l)
documentation=$(find "$TARGET_DIR/07_DOCUMENTATION" -type f 2>/dev/null | wc -l)
total_moved=$((gumroad_listings + documentation))

echo ""
echo "🎯 MARKETPLACE DOCUMENTS ORGANIZATION COMPLETE!"
echo "==============================================="

count "Files moved to GumRoad listings: $gumroad_listings"
count "Files moved to documentation: $documentation"
count "Total marketplace documents organized: $total_moved"

echo ""
echo "🏗️  MASTERS EO MARKETPLACE MODULES:"
echo "==================================="

echo ""
echo "🛒 02_MARKETPLACE_LISTINGS/ ($gumroad_listings files)"
echo "   ├── GumRoad product catalog and listings"
echo "   ├── Bundle strategies and pricing"
echo "   ├── Email marketing campaigns"
echo "   ├── Platform quick reference guides"
echo "   ├── Product ranking and descriptions"
echo "   └── Marketplace execution checklists"
echo ""

echo "📚 07_DOCUMENTATION/ ($documentation files)"
echo "   ├── Business summaries and overviews"
echo "   ├── Project documentation and guides"
echo "   ├── Phase execution summaries"
echo "   └── Business strategy documentation"
echo ""

echo "🎯 BUSINESS OPERATIONS READY:"
echo "============================="

echo ""
echo "📋 Marketplace Launch Resources:"
echo "• GumRoad product catalog and bundles"
echo "• Multi-platform strategy (Codester + Gumroad)"
echo "• Email list building campaigns"
echo "• Revenue optimization guides"
echo "• Launch checklists and timelines"
echo ""

echo "💼 Business Strategy Resources:"
echo "• Platform comparison analysis"
echo "• Competitive positioning"
echo "• Product ranking intelligence"
echo "• Execution roadmaps"
echo ""

echo "🚀 IMMEDIATE BUSINESS CAPABILITIES:"
echo "==================================="

echo ""
echo "• Launch GumRoad marketplace products"
echo "• Execute multi-platform sales strategy"
echo "• Build email marketing campaigns"
echo "• Optimize product pricing and bundling"
echo "• Track marketplace performance"
echo "• Scale business operations systematically"
echo ""

warning "NOTE: Original files preserved. Test the MasterxEo organization,"
warning "then optionally clean up original locations when confident."

status "Marketplace business documents successfully organized in MasterxEo! 🎯🛒"