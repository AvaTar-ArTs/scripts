#!/bin/bash
# 🎯 **FINISH BUSINESS ECOSYSTEM INTEGRATION**
# Complete the MasterxEo and business materials integration

set -e

echo "🎯 FINISHING BUSINESS ECOSYSTEM INTEGRATION"
echo "=========================================="

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
info "Completing business ecosystem integration..."
echo "Target: $TARGET_DIR"
echo ""

# Create missing subdirectories
info "Ensuring all subdirectories exist..."
mkdir -p "$TARGET_DIR/products/assets"
mkdir -p "$TARGET_DIR/products/revenue"
mkdir -p "$TARGET_DIR/products/branding"
mkdir -p "$TARGET_DIR/products/deployment"
mkdir -p "$TARGET_DIR/products/avatararts"
mkdir -p "$TARGET_DIR/products/masterxeo"
mkdir -p "$TARGET_DIR/gumroad/listings"
mkdir -p "$TARGET_DIR/docs/business-docs"
mkdir -p "$TARGET_DIR/docs/marketplace"
mkdir -p "$TARGET_DIR/docs/analysis"
mkdir -p "$TARGET_DIR/tools/organization"
mkdir -p "$TARGET_DIR/archive/business-backups"

echo ""
progress "INTEGRATING MASTERS EO BUSINESS PROJECT"
echo "==========================================="

# MasterxEo numbered directories
masterxeo_dirs=(
    "01_ASSETS_LIBRARY:products/assets"
    "02_MARKETPLACE_LISTINGS:gumroad/listings"
    "03_REVENUE_TRACKING:products/revenue"
    "04_BRANDING_KITS:products/branding"
    "05_DEPLOYMENT_TOOLS:products/deployment"
    "06_BACKUP_ARCHIVE:archive/business-backups"
    "07_DOCUMENTATION:docs/business-docs"
    "08_MARKETPLACE_ASSETS:gumroad/assets"
)

integrated_count=0

for entry in "${masterxeo_dirs[@]}"; do
    IFS=':' read -r source_dir target_subdir <<< "$entry"
    source_path="$HOME/MasterxEo/$source_dir"
    target_path="$TARGET_DIR/$target_subdir"

    if [ -d "$source_path" ]; then
        file_count=$(find "$source_path" -type f 2>/dev/null | wc -l)
        if [ "$file_count" -gt 0 ]; then
            cp -r "$source_path"/* "$target_path/" 2>/dev/null && {
                count "✓ Integrated $source_dir ($file_count files) → $target_subdir/"
                integrated_count=$((integrated_count + file_count))
            } || {
                warning "Failed to integrate $source_dir"
            }
        fi
    fi
done

# MasterxEo scripts
masterxeo_scripts=(
    "consolidate_marketplace_listings.py"
    "consolidate_ai_products.py"
    "consolidate_python_scripts_simple.py"
    "consolidate_python_scripts.py"
    "index.html"
)

for script in "${masterxeo_scripts[@]}"; do
    if [ -f "$HOME/MasterxEo/$script" ]; then
        cp "$HOME/MasterxEo/$script" "$TARGET_DIR/automation/" && {
            count "✓ Integrated script: $script → automation/"
            integrated_count=$((integrated_count + 1))
        }
    fi
done

echo ""
progress "INTEGRATING MARKETPLACE CONSOLIDATION"
echo "======================================="

# Marketplace consolidation files
marketplace_files=(
    "SUMMARY.txt:docs/"
    "README.md:docs/"
    "EXECUTABLE_SCRIPTS_RANKED.csv:automation/"
    "GUMROAD_PHASE_3_EXECUTION_CHECKLIST.md:gumroad/marketing/"
    "GUMROAD_EMAIL_LIST_STRATEGY.md:gumroad/marketing/"
    "GUMROAD_PHASE_3_SUMMARY.md:gumroad/marketing/"
    "MARKETPLACE_PLATFORM_QUICK_REFERENCE.md:docs/"
    "TOP_20_MARKETPLACE_DESCRIPTIONS.txt:gumroad/marketing/"
    "GUMROAD_BUNDLE_STRATEGY.md:gumroad/strategy/"
    "GUMROAD_BUNDLE_1_PRODUCT_PAGE.md:gumroad/bundles/"
    "GUMROAD_QUICK_START.txt:gumroad/marketing/"
    "CODESTER_vs_GUMROAD_STRATEGY.md:strategy/"
)

for entry in "${marketplace_files[@]}"; do
    IFS=':' read -r filename target_subdir <<< "$entry"
    source_file="$HOME/marketplace_consolidation/$filename"
    target_path="$TARGET_DIR/$target_subdir"

    if [ -f "$source_file" ]; then
        cp "$source_file" "$target_path/" && {
            count "✓ Integrated marketplace file: $filename → $target_subdir"
            integrated_count=$((integrated_count + 1))
        }
    fi
done

echo ""
progress "INTEGRATING BUSINESS SCRIPTS & TOOLS"
echo "======================================"

# Organization and business scripts
business_scripts=(
    "preview_intuitive_organization.sh:tools/organization/"
    "implement_intuitive_organization.sh:tools/organization/"
    "consolidation_setup.sh:tools/organization/"
    "consolidation_ai_setup.sh:tools/organization/"
    "consolidation_preview.sh:tools/organization/"
    "simple_consolidation.sh:tools/organization/"
    "create_comprehensive_index.sh:tools/organization/"
    "ultra_simple_demo.sh:tools/organization/"
    "intuitive_organization_demo.sh:tools/organization/"
)

for entry in "${business_scripts[@]}"; do
    IFS=':' read -r scriptname target_subdir <<< "$entry"
    source_file="$HOME/$scriptname"
    target_path="$TARGET_DIR/$target_subdir"

    if [ -f "$source_file" ]; then
        cp "$source_file" "$target_path/" && {
            count "✓ Integrated business script: $scriptname → $target_subdir"
            integrated_count=$((integrated_count + 1))
        }
    fi
done

# Additional business tools
additional_tools=(
    "avatararts-packaged-scripts:automation/"
    "avatararts-packaging-script.sh:automation/"
    "check_grok_setup_full.sh:automation/"
    "avatararts_content_aware_consolidation_script.sh:automation/"
)

for entry in "${additional_tools[@]}"; do
    IFS=':' read -r toolname target_subdir <<< "$entry"
    source_path="$HOME/$toolname"
    target_path="$TARGET_DIR/$target_subdir"

    if [ -e "$source_path" ]; then
        cp -r "$source_path" "$target_path/" 2>/dev/null && {
            count "✓ Integrated business tool: $toolname → $target_subdir"
            integrated_count=$((integrated_count + 1))
        }
    fi
done

echo ""
progress "INTEGRATING ANALYSIS & DOCUMENTATION"
echo "======================================"

# Analysis files
analysis_files=(
    "filesystem_user_guide.md:docs/analysis/"
    "filesystem_master_index_20260205_182527.txt:docs/analysis/"
    "filesystem_master_index_20260205_182454.txt:docs/analysis/"
    "ecosystem_consolidation_master_plan.md:docs/analysis/"
)

for entry in "${analysis_files[@]}"; do
    IFS=':' read -r filename target_subdir <<< "$entry"
    source_file="$HOME/$filename"
    target_path="$TARGET_DIR/$target_subdir"

    if [ -f "$source_file" ]; then
        cp "$source_file" "$target_path/" && {
            count "✓ Integrated analysis: $filename → $target_subdir"
            integrated_count=$((integrated_count + 1))
        }
    fi
done

echo ""
progress "FINAL VERIFICATION"
echo "==================="

# Count final results
final_total=$(find "$TARGET_DIR" -type f 2>/dev/null | wc -l)
products_count=$(find "$TARGET_DIR/products" -type f 2>/dev/null | wc -l)
automation_count=$(find "$TARGET_DIR/automation" -type f 2>/dev/null | wc -l)

echo ""
echo "🎯 BUSINESS ECOSYSTEM INTEGRATION COMPLETE!"
echo "==========================================="

count "Files newly integrated: $integrated_count"
count "Total MarketMaster files: $final_total"
count "Business products: $products_count"
count "Automation scripts: $automation_count"

echo ""
echo "🏗️  ENHANCED MARKETMASTER STRUCTURE:"
echo "===================================="

echo "🏪 MarketMaster/"
echo "├── 🛍️  gumroad/ ← GumRoad ecosystem"
echo "│   ├── 📊 ecosystem-analysis/"
echo "│   ├── 🧠 rag-systems/"
echo "│   ├── 💡 product-concepts/"
echo "│   ├── 🎯 strategy/"
echo "│   ├── 🚀 deployment/"
echo "│   ├── 📢 marketing/"
echo "│   ├── 📦 bundles/"
echo "│   ├── 🔧 templates/"
echo "│   ├── 💾 data/"
echo "│   ├── 🏷️  listings/ ← NEW: Marketplace listings"
echo "│   └── 🌐 assets/ ← ENHANCED: GumRoad + MasterxEo assets"
echo "│"
echo "├── 🏭 products/ ← ENHANCED: Business products"
echo "│   ├── 📚 assets/ ← NEW: MasterxEo assets library"
echo "│   ├── 💰 revenue/ ← NEW: Revenue tracking systems"
echo "│   ├── 🎨 branding/ ← NEW: Branding kits"
echo "│   ├── 🚀 deployment/ ← NEW: Deployment tools"
echo "│   ├── 🤖 avatararts/ ← ENHANCED: AvatarArts materials"
echo "│   └── 🏆 masterxeo/ ← NEW: MasterxEo project files"
echo "│"
echo "├── 📚 docs/ ← ENHANCED: Documentation"
echo "│   ├── 📋 business-docs/ ← NEW: MasterxEo documentation"
echo "│   ├── 🏪 marketplace/ ← ENHANCED: Marketplace analysis"
echo "│   └── 📊 analysis/ ← NEW: System analysis reports"
echo "│"
echo "├── ⚙️  automation/ ← ENHANCED: Business automation"
echo "│   ├── 🔧 MasterxEo consolidation scripts"
echo "│   ├── 🤖 AI product management tools"
echo "│   ├── 📦 AvatarArts packaging scripts"
echo "│   └── 🚀 Business process automation"
echo "│"
echo "└── 🔧 tools/organization/ ← NEW: Organization scripts"

echo ""
echo "🚀 BUSINESS CAPABILITIES NOW AVAILABLE:"
echo "======================================"
echo "• Complete MasterxEo business project (8 organized modules)"
echo "• Marketplace consolidation and analysis tools"
echo "• Revenue tracking and business intelligence"
echo "• Branding kits and deployment tools"
echo "• Comprehensive business documentation"
echo "• Automated business process scripts"
echo "• System analysis and organization tools"
echo ""

echo "💼 BUSINESS OPERATIONS READY:"
echo "============================="
echo "• Product development and management (MasterxEo framework)"
echo "• Marketplace optimization and deployment"
echo "• Revenue tracking and financial management"
echo "• Branding and marketing asset management"
echo "• Business process automation and scaling"
echo "• Professional documentation and reporting"
echo ""

warning "NOTE: Original files preserved. Test the enhanced organization,"
warning "then optionally clean up original directories when confident."

status "Complete business ecosystem integration finished! 🎯💼🚀"