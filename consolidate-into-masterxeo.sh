#!/bin/bash
# 🚀 **MASTER XEO BUSINESS CONSOLIDATION**
# Consolidate all business assets into MasterxEo framework

set -e

echo "🚀 MASTER XEO BUSINESS CONSOLIDATION"
echo "===================================="

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

# Create any missing MasterxEo subdirectories
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

# Function to integrate directory contents
integrate_directory() {
    local source="$1"
    local target="$2"
    local description="$3"

    if [ -d "$source" ]; then
        # Create a subdirectory to avoid conflicts
        local dirname=$(basename "$source")
        local target_subdir="$target/$dirname"

        if [ ! -d "$target_subdir" ]; then
            cp -r "$source" "$target/" 2>/dev/null && {
                count "✓ $description → $target/"
                return 0
            } || {
                warning "Failed to integrate $source"
                return 1
            }
        else
            warning "$target_subdir already exists, merging contents..."
            cp -r "$source"/* "$target_subdir/" 2>/dev/null && {
                count "✓ Merged $description → $target_subdir/"
                return 0
            } || {
                warning "Failed to merge $source"
                return 1
            }
        fi
    else
        warning "$source directory not found"
        return 1
    fi
}

echo ""
progress "PHASE 1: 01_ASSETS_LIBRARY - Digital Assets & Resources"
echo "=========================================================="

# Core product assets
integrate_directory "$HOME/AVATARARTS" "$TARGET_DIR/01_ASSETS_LIBRARY" "AVATARARTS project (4,104 files)"
integrate_directory "$HOME/avatararts-packaged-scripts" "$TARGET_DIR/01_ASSETS_LIBRARY" "AvatarArts scripts (26 files)"
integrate_directory "$HOME/DiGiTaLDiVe" "$TARGET_DIR/01_ASSETS_LIBRARY" "Digital Dive project (8 files)"
integrate_directory "$HOME/XEO" "$TARGET_DIR/01_ASSETS_LIBRARY" "XEO project (45,116 files)"
integrate_directory "$HOME/Memory-Optimization-Tools" "$TARGET_DIR/01_ASSETS_LIBRARY" "Memory optimization tools (3 files)"

# Additional asset sources
integrate_directory "$HOME/active" "$TARGET_DIR/01_ASSETS_LIBRARY" "Active workspace (11,900 files)"
integrate_directory "$HOME/products" "$TARGET_DIR/01_ASSETS_LIBRARY" "Products directory (1 file)"
integrate_directory "$HOME/projects" "$TARGET_DIR/01_ASSETS_LIBRARY" "Projects directory (1 file)"

echo ""
progress "PHASE 2: 02_MARKETPLACE_LISTINGS - Product Listings & Data"
echo "============================================================="

# Marketplace listings and data
integrate_directory "$HOME/GumRoad" "$TARGET_DIR/02_MARKETPLACE_LISTINGS" "GumRoad business (608 files)"
integrate_directory "$HOME/marketplace_consolidation" "$TARGET_DIR/02_MARKETPLACE_LISTINGS" "Marketplace consolidation (12 files)"
integrate_directory "$HOME/MarketMaster/gumroad/listings" "$TARGET_DIR/02_MARKETPLACE_LISTINGS" "MarketMaster listings (1,846 files)"

echo ""
progress "PHASE 3: 03_REVENUE_TRACKING - Financial Tracking & Analytics"
echo "==============================================================="

# Revenue and financial tracking
integrate_directory "$HOME/MarketMaster/products/revenue" "$TARGET_DIR/03_REVENUE_TRACKING" "MarketMaster revenue systems (2 files)"
integrate_directory "$HOME/reports" "$TARGET_DIR/03_REVENUE_TRACKING" "Reports (8 files)"
integrate_directory "$HOME/reports_2026" "$TARGET_DIR/03_REVENUE_TRACKING" "2026 reports (9 files)"

echo ""
progress "PHASE 4: 04_BRANDING_KITS - Branding Materials & Assets"
echo "=========================================================="

# Branding and marketing materials
integrate_directory "$HOME/MarketMaster/products/branding" "$TARGET_DIR/04_BRANDING_KITS" "MarketMaster branding (2 files)"
integrate_directory "$HOME/my-gitbook" "$TARGET_DIR/04_BRANDING_KITS" "GitBook documentation (6 files)"

echo ""
progress "PHASE 5: 05_DEPLOYMENT_TOOLS - Launch Tools & Deployment Scripts"
echo "=================================================================="

# Deployment and automation tools
integrate_directory "$HOME/n8n" "$TARGET_DIR/05_DEPLOYMENT_TOOLS" "N8N automation (25 files)"
integrate_directory "$HOME/notebooklm-mcp" "$TARGET_DIR/05_DEPLOYMENT_TOOLS" "NotebookLM MCP (3,381 files)"
integrate_directory "$HOME/MarketMaster/products/deployment" "$TARGET_DIR/05_DEPLOYMENT_TOOLS" "MarketMaster deployment tools (2 files)"

echo ""
progress "PHASE 6: 06_BACKUP_ARCHIVE - Archives, Backups & Historical Data"
echo "==================================================================="

# Archives and historical data
integrate_directory "$HOME/PROJECT_PREVIEW" "$TARGET_DIR/06_BACKUP_ARCHIVE" "Project previews (5 files)"
integrate_directory "$HOME/PHASE_3_ANALYSIS" "$TARGET_DIR/06_BACKUP_ARCHIVE" "Phase 3 analysis (16 files)"

echo ""
progress "PHASE 7: 07_DOCUMENTATION - Documentation, Guides & Reports"
echo "============================================================="

# Documentation and guides
integrate_directory "$HOME/advanced_analysis_report" "$TARGET_DIR/07_DOCUMENTATION" "Advanced analysis report (5 files)"
integrate_directory "$HOME/MarketMaster/docs" "$TARGET_DIR/07_DOCUMENTATION" "MarketMaster documentation (36 files)"
integrate_directory "$HOME/workspace" "$TARGET_DIR/07_DOCUMENTATION" "Workspace documentation (5,035 files)"

echo ""
progress "PHASE 8: 08_MARKETPLACE_ASSETS - Marketplace-Specific Assets"
echo "==============================================================="

# AI and marketplace-specific assets
integrate_directory "$HOME/AI-Ecosystem" "$TARGET_DIR/08_MARKETPLACE_ASSETS" "AI ecosystem (7 files)"
integrate_directory "$HOME/AI-Workspace" "$TARGET_DIR/08_MARKETPLACE_ASSETS" "AI workspace (8,655 files)"
integrate_directory "$HOME/MarketMaster/gumroad/assets" "$TARGET_DIR/08_MARKETPLACE_ASSETS" "MarketMaster GumRoad assets (3 files)"

echo ""
progress "PHASE 9: Final Integration & Verification"
echo "==========================================="

# Count final results
final_total=$(find "$TARGET_DIR" -type f 2>/dev/null | wc -l)

echo ""
echo "🎯 MASTER XEO CONSOLIDATION COMPLETE!"
echo "===================================="

count "Total files consolidated into MasterxEo: $final_total"

echo ""
echo "🏗️  MASTER XEO BUSINESS FRAMEWORK:"
echo "=================================="

# Show the final structure
for module in {01..08}_*; do
    if [ -d "$TARGET_DIR/$module" ]; then
        module_name=$(basename "$module")
        file_count=$(find "$TARGET_DIR/$module" -type f 2>/dev/null | wc -l)
        echo "📁 $module_name/ ($file_count files)"
    fi
done

echo ""
echo "🎯 BUSINESS MODULES NOW AVAILABLE:"
echo "=================================="

echo ""
echo "🏆 01_ASSETS_LIBRARY/ ($(( $(find "$TARGET_DIR/01_ASSETS_LIBRARY" -type f 2>/dev/null | wc -l) )) files)"
echo "   • AVATARARTS project assets"
echo "   • Digital content and resources"
echo "   • XEO project materials"
echo "   • Memory optimization tools"
echo "   • Active workspace materials"
echo ""

echo "🛒 02_MARKETPLACE_LISTINGS/ ($(( $(find "$TARGET_DIR/02_MARKETPLACE_LISTINGS" -type f 2>/dev/null | wc -l) )) files)"
echo "   • GumRoad marketplace data"
echo "   • Marketplace consolidation analysis"
echo "   • Product listings and catalogs"
echo ""

echo "💰 03_REVENUE_TRACKING/ ($(( $(find "$TARGET_DIR/03_REVENUE_TRACKING" -type f 2>/dev/null | wc -l) )) files)"
echo "   • Financial reports and analytics"
echo "   • Revenue tracking systems"
echo "   • Business performance data"
echo ""

echo "🎨 04_BRANDING_KITS/ ($(( $(find "$TARGET_DIR/04_BRANDING_KITS" -type f 2>/dev/null | wc -l) )) files)"
echo "   • Branding materials and assets"
echo "   • Marketing collateral"
echo "   • Brand guidelines and resources"
echo ""

echo "🚀 05_DEPLOYMENT_TOOLS/ ($(( $(find "$TARGET_DIR/05_DEPLOYMENT_TOOLS" -type f 2>/dev/null | wc -l) )) files)"
echo "   • N8N automation workflows"
echo "   • AI deployment tools (NotebookLM MCP)"
echo "   • Launch and deployment scripts"
echo ""

echo "📦 06_BACKUP_ARCHIVE/ ($(( $(find "$TARGET_DIR/06_BACKUP_ARCHIVE" -type f 2>/dev/null | wc -l) )) files)"
echo "   • Project previews and archives"
echo "   • Analysis backups"
echo "   • Historical business data"
echo ""

echo "📚 07_DOCUMENTATION/ ($(( $(find "$TARGET_DIR/07_DOCUMENTATION" -type f 2>/dev/null | wc -l) )) files)"
echo "   • Business documentation and guides"
echo "   • Analysis reports"
echo "   • Workspace documentation"
echo ""

echo "🤖 08_MARKETPLACE_ASSETS/ ($(( $(find "$TARGET_DIR/08_MARKETPLACE_ASSETS" -type f 2>/dev/null | wc -l) )) files)"
echo "   • AI ecosystem assets"
echo "   • AI workspace materials"
echo "   • Marketplace-specific resources"
echo ""

echo ""
echo "🎉 TRANSFORMATION COMPLETE!"
echo "==========================="

echo ""
echo "Your scattered business assets have been consolidated into:"
echo "🏢 A unified MasterxEo business framework"
echo "📋 8 specialized business modules"
echo "🎯 Clear operational boundaries"
echo "🚀 Systematic business operations"
echo ""

echo "💼 BUSINESS OPERATIONS READY:"
echo "============================="

echo ""
echo "• Navigate by business function, not by where files came from"
echo "• Access all assets for any business module instantly"
echo "• Maintain clear separation between different business areas"
echo "• Scale operations systematically across all modules"
echo ""

warning "NOTE: Original directories preserved. Test the MasterxEo framework,"
warning "then optionally clean up original directories when confident."

status "MasterxEo business consolidation complete! 🎯🏆"