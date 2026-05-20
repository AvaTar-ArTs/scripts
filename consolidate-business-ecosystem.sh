#!/bin/bash
# 🚀 **CONSOLIDATE COMPLETE BUSINESS ECOSYSTEM**
# MasterxEo + Marketplace + Business Assets Integration

set -e

echo "🚀 CONSOLIDATING COMPLETE BUSINESS ECOSYSTEM"
echo "==========================================="
echo ""

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
info "Integrating MasterxEo business ecosystem into MarketMaster..."
echo "Target: $TARGET_DIR"
echo ""

# Function to safely move files
safe_move() {
    local source="$1"
    local target="$2"
    local description="$3"

    if [ -e "$source" ]; then
        cp -r "$source" "$target" 2>/dev/null || {
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
progress "PHASE 1: MasterxEo Business Core"
echo "=================================="

# Move MasterxEo project structure
if [ -d ~/MasterxEo ]; then
    info "Moving MasterxEo business project (complete structure)..."

    # Move the numbered business organization folders
    safe_move ~/MasterxEo/01_ASSETS_LIBRARY "$TARGET_DIR/products/assets/" "Assets library"
    safe_move ~/MasterxEo/02_MARKETPLACE_LISTINGS "$TARGET_DIR/gumroad/listings/" "Marketplace listings"
    safe_move ~/MasterxEo/03_REVENUE_TRACKING "$TARGET_DIR/products/revenue/" "Revenue tracking"
    safe_move ~/MasterxEo/04_BRANDING_KITS "$TARGET_DIR/products/branding/" "Branding kits"
    safe_move ~/MasterxEo/05_DEPLOYMENT_TOOLS "$TARGET_DIR/products/deployment/" "Deployment tools"
    safe_move ~/MasterxEo/06_BACKUP_ARCHIVE "$TARGET_DIR/archive/business-backups/" "Business backups"
    safe_move ~/MasterxEo/07_DOCUMENTATION "$TARGET_DIR/docs/business-docs/" "Business documentation"
    safe_move ~/MasterxEo/08_MARKETPLACE_ASSETS "$TARGET_DIR/gumroad/assets/" "Marketplace assets"

    # Move MasterxEo scripts
    safe_move ~/MasterxEo/consolidate_marketplace_listings.py "$TARGET_DIR/automation/" "Marketplace listings consolidator"
    safe_move ~/MasterxEo/consolidate_ai_products.py "$TARGET_DIR/automation/" "AI products consolidator"
    safe_move ~/MasterxEo/consolidate_python_scripts_simple.py "$TARGET_DIR/automation/" "Python scripts consolidator (simple)"
    safe_move ~/MasterxEo/consolidate_python_scripts.py "$TARGET_DIR/automation/" "Python scripts consolidator"
    safe_move ~/MasterxEo/index.html "$TARGET_DIR/gumroad/assets/" "MasterxEo index page"

    # Move any remaining MasterxEo files
    for file in ~/MasterxEo/*; do
        if [ -f "$file" ]; then
            filename=$(basename "$file")
            cp "$file" "$TARGET_DIR/products/masterxeo/" 2>/dev/null || true
        fi
    done
fi

echo ""
progress "PHASE 2: Marketplace Consolidation"
echo "==================================="

# Move marketplace consolidation materials
if [ -d ~/marketplace_consolidation ]; then
    info "Moving marketplace consolidation analysis..."

    safe_move ~/marketplace_consolidation/SUMMARY.txt "$TARGET_DIR/docs/" "Marketplace summary"
    safe_move ~/marketplace_consolidation/README.md "$TARGET_DIR/docs/" "Marketplace README"
    safe_move ~/marketplace_consolidation/EXECUTABLE_SCRIPTS_RANKED.csv "$TARGET_DIR/automation/" "Script rankings"
    safe_move ~/marketplace_consolidation/GUMROAD_PHASE_3_EXECUTION_CHECKLIST.md "$TARGET_DIR/gumroad/marketing/" "Phase 3 checklist (verify)"
    safe_move ~/marketplace_consolidation/GUMROAD_EMAIL_LIST_STRATEGY.md "$TARGET_DIR/gumroad/marketing/" "Email strategy (verify)"
    safe_move ~/marketplace_consolidation/GUMROAD_PHASE_3_SUMMARY.md "$TARGET_DIR/gumroad/marketing/" "Phase 3 summary (verify)"
    safe_move ~/marketplace_consolidation/MARKETPLACE_PLATFORM_QUICK_REFERENCE.md "$TARGET_DIR/docs/" "Platform reference"
    safe_move ~/marketplace_consolidation/TOP_20_MARKETPLACE_DESCRIPTIONS.txt "$TARGET_DIR/gumroad/marketing/" "Top marketplace descriptions"
    safe_move ~/marketplace_consolidation/GUMROAD_BUNDLE_STRATEGY.md "$TARGET_DIR/gumroad/strategy/" "Bundle strategy (verify)"
    safe_move ~/marketplace_consolidation/GUMROAD_BUNDLE_1_PRODUCT_PAGE.md "$TARGET_DIR/gumroad/bundles/" "Bundle 1 page (verify)"
    safe_move ~/marketplace_consolidation/GUMROAD_QUICK_START.txt "$TARGET_DIR/gumroad/marketing/" "Quick start (verify)"
    safe_move ~/marketplace_consolidation/CODESTER_vs_GUMROAD_STRATEGY.md "$TARGET_DIR/strategy/" "Codester vs GumRoad strategy"

    # Move any remaining files
    for file in ~/marketplace_consolidation/*; do
        if [ -f "$file" ]; then
            filename=$(basename "$file")
            cp "$file" "$TARGET_DIR/docs/marketplace/" 2>/dev/null || true
        fi
    done
fi

echo ""
progress "PHASE 3: Organization Scripts Integration"
echo "==========================================="

# Move organization and consolidation scripts to tools
scripts_to_move=(
    "preview_intuitive_organization.sh"
    "implement_intuitive_organization.sh"
    "consolidation_setup.sh"
    "consolidation_ai_setup.sh"
    "consolidation_preview.sh"
    "simple_consolidation.sh"
    "create_comprehensive_index.sh"
    "ultra_simple_demo.sh"
    "intuitive_organization_demo.sh"
)

for script in "${scripts_to_move[@]}"; do
    if [ -f ~/"$script" ]; then
        safe_move ~/"$script" "$TARGET_DIR/tools/organization/" "Organization script: $script"
    fi
done

echo ""
progress "PHASE 4: AvatarArts Business Materials"
echo "========================================"

# Move AvatarArts business files (already in MarketMaster, but ensure organization)
avatararts_files=(
    "AVATARARTS_EMPIRE_NOTION_DATABASE.md"
    "COMPREHENSIVE_APPENDED_ANALYSIS.html"
    "AVATARARTS_PLATFORM_COMPLETION_CERTIFICATE.md"
    "AVATARARTS_STATUS_CORRECTION_GUIDE.md"
    "AVATARARTS_CURRENT_STATUS.md"
    "AVATARARTS_CORRECTED_PLATFORM_SUMMARY.md"
    "AVATARARTS_PROJECT_COMPLETION_SUMMARY.md"
    "AVATARARTS_QUICK_START_REFERENCE.md"
    "AVATARARTS_CONSOLIDATION_CHANGELOG.md"
    "AVATARARTS_COMPLETE_PROJECT_SUMMARY_AND_CELEBRATION.md"
    "AVATARARTS_ECOSYSTEM_COMPLETE_TRANSFORMATION_CERTIFICATE.md"
    "AVATARARTS_REVENUE_ASSET_IDENTIFICATION_COMPLETE_SUMMARY.md"
    "AVATARARTS_ECOSYSTEM_ANALYSIS_REPORT.md"
    "PYTHONS_ANALYSIS_AND_IMPROVEMENTS.md"
    "AVATARARTS_PRODUCTS_AND_SERVICES.md"
    "AVATARARTS_FOUNDATION.md"
    "AVATARARTS_ACTIVATION_ROADMAP.md"
    "IMPLEMENTATION_PLAN.md"
    "AVATARARTS_IMPLEMENTATION_PLAN.md"
    "AVATARARTS_Ecosystem_Comprehensive_Documentation.md"
    "BATCH2_PYTHONS_ACTIVATION_ANALYSIS.md"
    "ECOSYSTEM_ACTIVATION_DASHBOARD.md"
    "COMPREHENSIVE_ECOSYSTEM_ANALYSIS.md"
    "AVATARARTS_STRATEGIC_IMPLEMENTATION_PLAN.md"
    "AVATARARTS_ACTIVATION_PLAN.md"
    "ACTIVATION_MASTER_PLAN.md"
)

for file in "${avatararts_files[@]}"; do
    if [ -f ~/"$file" ]; then
        safe_move ~/"$file" "$TARGET_DIR/products/avatararts/" "AvatarArts material: $file"
    fi
done

echo ""
progress "PHASE 5: Additional Business Assets"
echo "====================================="

# Move remaining business files
additional_files=(
    "avatararts-packaged-scripts"
    "avatararts-packaging-script.sh"
    "check_grok_setup_full.sh"
    "avatararts_content_aware_consolidation_script.sh"
    "grow.md"
)

for file in "${additional_files[@]}"; do
    if [ -e ~/"$file" ]; then
        safe_move ~/"$file" "$TARGET_DIR/automation/" "Business automation: $file"
    fi
done

# Move analysis files
analysis_files=(
    "filesystem_user_guide.md"
    "filesystem_master_index_20260205_182527.txt"
    "filesystem_master_index_20260205_182454.txt"
    "ecosystem_consolidation_master_plan.md"
)

for file in "${analysis_files[@]}"; do
    if [ -f ~/"$file" ]; then
        safe_move ~/"$file" "$TARGET_DIR/docs/analysis/" "Analysis document: $file"
    fi
done

# Move remaining GumRoad files that might have been missed
remaining_gumroad=(
    "GUMROAD_MASTER_INDEX.md"
    "PHASE_3_UPDATED_CODESTER_FIRST.md"
    "TOP_20_MARKETPLACE_DESCRIPTIONS.txt"
    "EXECUTABLE_SCRIPTS_RANKED.csv"
)

for file in "${remaining_gumroad[@]}"; do
    if [ -f ~/"$file" ]; then
        safe_move ~/"$file" "$TARGET_DIR/gumroad/docs/" "GumRoad document: $file"
    fi
done

echo ""
progress "PHASE 6: Final Organization & Verification"
echo "=============================================="

# Create final directory structure verification
info "Creating final business ecosystem structure..."

# Ensure all subdirectories exist
mkdir -p "$TARGET_DIR/products/assets"
mkdir -p "$TARGET_DIR/products/revenue"
mkdir -p "$TARGET_DIR/products/branding"
mkdir -p "$TARGET_DIR/products/deployment"
mkdir -p "$TARGET_DIR/products/avatararts"
mkdir -p "$TARGET_DIR/products/masterxeo"
mkdir -p "$TARGET_DIR/gumroad/listings"
mkdir -p "$TARGET_DIR/gumroad/assets"
mkdir -p "$TARGET_DIR/docs/business-docs"
mkdir -p "$TARGET_DIR/docs/marketplace"
mkdir -p "$TARGET_DIR/docs/analysis"
mkdir -p "$TARGET_DIR/tools/organization"
mkdir -p "$TARGET_DIR/archive/business-backups"

# Count final totals
final_total=$(find "$TARGET_DIR" -type f 2>/dev/null | wc -l)
gumroad_final=$(find "$TARGET_DIR/gumroad" -type f 2>/dev/null | wc -l)
products_final=$(find "$TARGET_DIR/products" -type f 2>/dev/null | wc -l)
automation_final=$(find "$TARGET_DIR/automation" -type f 2>/dev/null | wc -l)
docs_final=$(find "$TARGET_DIR/docs" -type f 2>/dev/null | wc -l)

echo ""
echo "🎯 COMPLETE BUSINESS ECOSYSTEM INTEGRATION"
echo "=========================================="

count "Total business assets: $final_total files"
echo ""
echo "📂 FINAL MARKETMASTER STRUCTURE:"
echo "==============================="
echo ""
echo "🏪 MarketMaster/ ($final_total files)"
echo "├── 🛍️ gumroad/ ($gumroad_final files) ← GUMROAD ECOSYSTEM"
echo "│   ├── 📊 ecosystem-analysis/ - Intelligence & reviews"
echo "│   ├── 🧠 rag-systems/        - Private RAG systems"
echo "│   ├── 💡 product-concepts/   - Product development"
echo "│   ├── 🎯 strategy/           - Business strategy"
echo "│   ├── 🚀 deployment/         - Operations & deployment"
echo "│   ├── 📢 marketing/          - Sales & marketing"
echo "│   ├── 📦 bundles/            - Product bundles"
echo "│   ├── 🔧 templates/          - Template systems"
echo "│   ├── 💾 data/               - Data & analytics"
echo "│   ├── 🏷️  listings/          - Marketplace listings"
echo "│   └── 🌐 assets/             - Technical assets"
echo "│"
echo "├── 🏭 products/ ($products_final files) ← BUSINESS PRODUCTS"
echo "│   ├── 📚 assets/             - Digital assets library"
echo "│   ├── 💰 revenue/            - Revenue tracking"
echo "│   ├── 🎨 branding/           - Branding kits"
echo "│   ├── 🚀 deployment/         - Deployment tools"
echo "│   ├── 🤖 avatararts/         - AvatarArts materials"
echo "│   └── 🏆 masterxeo/          - MasterxEo project"
echo "│"
echo "├── 📚 docs/ ($docs_final files) ← DOCUMENTATION"
echo "│   ├── 📋 business-docs/      - Business documentation"
echo "│   ├── 🏪 marketplace/        - Marketplace materials"
echo "│   └── 📊 analysis/           - Analysis & intelligence"
echo "│"
echo "├── ⚙️ automation/ ($automation_final files) ← BUSINESS AUTOMATION"
echo "│   ├── 🔧 Scripts for marketplace consolidation"
echo "│   ├── 🤖 AI product management"
echo "│   ├── 📦 Packaging & deployment"
echo "│   └── 🚀 Business process automation"
echo "│"
echo "└── 🔧 tools/ ← DEVELOPMENT TOOLS"
echo "    └── 📋 organization/       - Organization scripts"
echo ""

echo "🎯 BUSINESS CAPABILITIES NOW AVAILABLE:"
echo "======================================"
echo "• Complete GumRoad marketplace ecosystem"
echo "• MasterxEo business project infrastructure"
echo "• AvatarArts product materials"
echo "• Marketplace consolidation tools"
echo "• Business automation scripts"
echo "• Revenue tracking systems"
echo "• Branding and deployment kits"
echo "• Comprehensive documentation"
echo ""

echo "🚀 BUSINESS OPERATIONS READY:"
echo "============================="
echo "• Product development and launch"
echo "• Marketplace management and optimization"
echo "• Revenue tracking and analysis"
echo "• Customer acquisition and marketing"
echo "• Business scaling and automation"
echo "• Professional documentation and reporting"
echo ""

warning "NOTE: Original files are preserved. Test the new organization,"
warning "then optionally clean up original directories when confident."

status "Complete business ecosystem integration finished! 🎯💼"