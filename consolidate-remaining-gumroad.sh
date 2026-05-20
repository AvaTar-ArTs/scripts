#!/bin/bash
# 🎯 **CONSOLIDATE REMAINING GUMROAD ASSETS**
# Move all remaining GumRoad files into MarketMaster

set -e

echo "🎯 CONSOLIDATING REMAINING GUMROAD ASSETS"
echo "========================================="

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

TARGET_DIR="$HOME/MarketMaster"

echo ""
info "Target directory: $TARGET_DIR"
echo ""

# Create additional subdirectories for GumRoad organization
info "Creating GumRoad sub-organization structure..."
mkdir -p "$TARGET_DIR/gumroad/ecosystem-analysis"
mkdir -p "$TARGET_DIR/gumroad/rag-systems"
mkdir -p "$TARGET_DIR/gumroad/product-concepts"
mkdir -p "$TARGET_DIR/gumroad/strategy"
mkdir -p "$TARGET_DIR/gumroad/deployment"
mkdir -p "$TARGET_DIR/gumroad/marketing"
mkdir -p "$TARGET_DIR/gumroad/assets"
mkdir -p "$TARGET_DIR/gumroad/templates"
status "GumRoad organization structure created"

# Function to safely move files
safe_move() {
    local source="$1"
    local target="$2"
    local description="$3"

    if [ -e "$source" ]; then
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
progress "PHASE 1: Ecosystem Analysis & Intelligence"
echo "============================================="

# Move ecosystem analysis files
safe_move "$HOME/GumRoad/00_COMPREHENSIVE_ECOSYSTEM_REVIEW.md" "$TARGET_DIR/gumroad/ecosystem-analysis/" "Comprehensive ecosystem review"
safe_move "$HOME/GumRoad/00_MASTER_ECOSYSTEM_INTELLIGENCE_REPORT.md" "$TARGET_DIR/gumroad/ecosystem-analysis/" "Master ecosystem intelligence report"
safe_move "$HOME/GumRoad/01_HOME_DIRECTORY_RESOURCE_INDEX.md" "$TARGET_DIR/gumroad/ecosystem-analysis/" "Home directory resource index"
safe_move "$HOME/GumRoad/02_FULL_ECOSYSTEM_ANALYSIS_SYNTHESIS.md" "$TARGET_DIR/gumroad/ecosystem-analysis/" "Full ecosystem analysis synthesis"

echo ""
progress "PHASE 2: Private RAG Systems"
echo "============================="

# Move RAG system files
safe_move "$HOME/GumRoad/01_PRIVATE_RAG_SYSTEMS/MASTER_STRATEGY.md" "$TARGET_DIR/gumroad/rag-systems/" "Private RAG master strategy"
safe_move "$HOME/GumRoad/01_PRIVATE_RAG_SYSTEMS/PROJECT_COMPLETE_TEMPLATE.md" "$TARGET_DIR/gumroad/rag-systems/" "RAG project complete template"

echo ""
progress "PHASE 3: Product Concepts & Series"
echo "==================================="

# Move product concept files
safe_move "$HOME/GumRoad/03_ORIGINAL_PRODUCT_SERIES_CONCEPTS.md" "$TARGET_DIR/gumroad/product-concepts/" "Original product series concepts"
safe_move "$HOME/GumRoad/04_ORIGINAL_PRODUCTS_V2_INDIVIDUAL_FOCUSED.md" "$TARGET_DIR/gumroad/product-concepts/" "Original products v2 individual focused"
safe_move "$HOME/GumRoad/05_ORIGINAL_PRODUCTS_V3_COMPLETELY_NEW_CONCEPTS.md" "$TARGET_DIR/gumroad/product-concepts/" "Original products v3 completely new concepts"

echo ""
progress "PHASE 4: Strategy & Business Development"
echo "==========================================="

# Move strategy files
safe_move "$HOME/GumRoad/COLOR_PSYCHOLOGY_STRATEGY.md" "$TARGET_DIR/gumroad/strategy/" "Color psychology strategy"
safe_move "$HOME/GumRoad/COMPLETE_ECOSYSTEM_INTEGRATION.md" "$TARGET_DIR/gumroad/strategy/" "Complete ecosystem integration"
safe_move "$HOME/GumRoad/COMPLETE_VARIATIONS_READY.md" "$TARGET_DIR/gumroad/strategy/" "Complete variations ready"
safe_move "$HOME/GumRoad/CREATIVE-ADDITIONS.md" "$TARGET_DIR/gumroad/strategy/" "Creative additions"
safe_move "$HOME/GumRoad/PLATFORM_ARCHITECTURE.md" "$TARGET_DIR/gumroad/strategy/" "Platform architecture"

echo ""
progress "PHASE 5: Deployment & Operations"
echo "=================================="

# Move deployment files
safe_move "$HOME/GumRoad/DEPLOYMENT_WEEK_1.md" "$TARGET_DIR/gumroad/deployment/" "Deployment week 1 plan"
safe_move "$HOME/GumRoad/MASTER_TEMPLATE_SYSTEM.md" "$TARGET_DIR/gumroad/templates/" "Master template system"
safe_move "$HOME/GumRoad/PROJECT_STATUS_COMPLETE.md" "$TARGET_DIR/gumroad/deployment/" "Project status complete"
safe_move "$HOME/GumRoad/REORGANIZATION_STATUS.md" "$TARGET_DIR/gumroad/deployment/" "Reorganization status"
safe_move "$HOME/GumRoad/REVIEW.md" "$TARGET_DIR/gumroad/deployment/" "Review document"

echo ""
progress "PHASE 6: Marketing & Sales Assets"
echo "==================================="

# Move marketing files (these were already consolidated in first pass, but let's verify)
safe_move "$HOME/GUMROAD_BUNDLE_1_PRODUCT_PAGE.md" "$TARGET_DIR/gumroad/bundles/" "Bundle 1 product page (verify)"
safe_move "$HOME/GUMROAD_BUNDLE_4_PRODUCT_PAGE.md" "$TARGET_DIR/gumroad/bundles/" "Bundle 4 product page (verify)"
safe_move "$HOME/GUMROAD_BUNDLE_STRATEGY.md" "$TARGET_DIR/gumroad/marketing/" "Bundle strategy (verify)"
safe_move "$HOME/GUMROAD_EMAIL_LIST_STRATEGY.md" "$TARGET_DIR/gumroad/marketing/" "Email list strategy (verify)"
safe_move "$HOME/GUMROAD_MASTER_INDEX.md" "$TARGET_DIR/gumroad/marketing/" "Master index (verify)"
safe_move "$HOME/GUMROAD_PHASE_3_EXECUTION_CHECKLIST.md" "$TARGET_DIR/gumroad/marketing/" "Phase 3 execution checklist (verify)"
safe_move "$HOME/GUMROAD_PHASE_3_SUMMARY.md" "$TARGET_DIR/gumroad/marketing/" "Phase 3 summary (verify)"
safe_move "$HOME/GUMROAD_QUICK_START.txt" "$TARGET_DIR/gumroad/marketing/" "Quick start guide (verify)"

echo ""
progress "PHASE 7: Data & Technical Assets"
echo "==================================="

# Move data and technical files
safe_move "$HOME/gumroad-massive.txt" "$TARGET_DIR/gumroad/data/" "GumRoad massive data file (verify)"
safe_move "$HOME/GumRoad/HTML-STRUCTURE.md" "$TARGET_DIR/gumroad/assets/" "HTML structure documentation"
safe_move "$HOME/GumRoad/index-ai.html" "$TARGET_DIR/gumroad/assets/" "AI index HTML file"
safe_move "$HOME/GumRoad/PACKAGE_COMPLETE.txt" "$TARGET_DIR/gumroad/deployment/" "Package complete confirmation"

echo ""
progress "PHASE 8: Final Organization & Verification"
echo "==============================================="

# Count files in each new subdirectory
echo ""
info "FINAL GUMROAD ORGANIZATION:"
echo "==========================="

gumroad_subdirs=(
    "ecosystem-analysis:Ecosystem Analysis"
    "rag-systems:RAG Systems"
    "product-concepts:Product Concepts"
    "strategy:Strategy & Business"
    "deployment:Deployment & Operations"
    "marketing:Marketing & Sales"
    "assets:Technical Assets"
    "templates:Templates"
    "bundles:Bundles"
    "data:Data Files"
)

total_gumroad_files=0

for entry in "${gumroad_subdirs[@]}"; do
    IFS=':' read -r dirname description <<< "$entry"
    if [ -d "$TARGET_DIR/gumroad/$dirname" ]; then
        file_count=$(find "$TARGET_DIR/gumroad/$dirname" -type f 2>/dev/null | wc -l)
        if [ "$file_count" -gt 0 ]; then
            echo "📁 $description ($dirname/): $file_count files"
            total_gumroad_files=$((total_gumroad_files + file_count))
        fi
    fi
done

# Update the main directory count
total_marketmaster_files=$(find "$TARGET_DIR" -type f 2>/dev/null | wc -l)

echo ""
echo "🎯 GUMROAD CONSOLIDATION COMPLETE!"
echo "=================================="

count "GumRoad files consolidated: $total_gumroad_files"
count "Total MarketMaster files: $total_marketmaster_files"

echo ""
echo "🏗️  UPDATED MARKETMASTER STRUCTURE:"
echo "=================================="
echo ""
echo "📂 ~/MarketMaster/"
echo "├── 📂 gumroad/          ($total_gumroad_files files)"
echo "│   ├── 📂 ecosystem-analysis/  - Ecosystem intelligence & reviews"
echo "│   ├── 📂 rag-systems/         - Private RAG systems strategy"
echo "│   ├── 📂 product-concepts/    - Product series & concepts"
echo "│   ├── 📂 strategy/           - Business strategy & architecture"
echo "│   ├── 📂 deployment/         - Deployment plans & status"
echo "│   ├── 📂 marketing/          - Marketing materials & bundles"
echo "│   ├── 📂 assets/             - HTML, technical assets"
echo "│   ├── 📂 templates/          - Template systems"
echo "│   ├── 📂 bundles/            - Product bundle pages"
echo "│   └── 📂 data/               - Data files & analytics"
echo "├── 📂 products/         - Business products & tools"
echo "├── 📂 docs/             - Documentation & strategies"
echo "├── 📂 automation/       - Business automation"
echo "└── 📂 tools/            - Development & utility tools"

echo ""
echo "🎉 SUCCESS!"
echo "=========="
echo ""
echo "Your complete GumRoad ecosystem is now perfectly organized!"
echo ""
echo "Quick access to GumRoad sections:"
echo "• cd ~/MarketMaster/gumroad/ecosystem-analysis  # Intelligence & reviews"
echo "• cd ~/MarketMaster/gumroad/product-concepts    # Product development"
echo "• cd ~/MarketMaster/gumroad/strategy           # Business strategy"
echo "• cd ~/MarketMaster/gumroad/marketing          # Sales & marketing"
echo "• cd ~/MarketMaster/gumroad/deployment         # Operations & deployment"
echo ""

warning "NOTE: Original files are preserved. Test the new organization,"
warning "then optionally clean up ~/GumRoad/ when confident."

status "Complete GumRoad ecosystem consolidation finished! 🎯"