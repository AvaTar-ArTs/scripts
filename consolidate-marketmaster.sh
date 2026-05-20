#!/bin/bash
# 🎯 **CONSOLIDATE MARKETMASTER BUSINESS ASSETS**
# Move all GumRoad and business-related files into /Users/steven/MarketMaster/

set -e

echo "🎯 CONSOLIDATING MARKETMASTER BUSINESS ASSETS"
echo "============================================"

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

# Define target directory
TARGET_DIR="$HOME/MarketMaster"

echo ""
info "Target directory: $TARGET_DIR"
echo ""

# Create target directory structure
info "Creating MarketMaster directory structure..."
mkdir -p "$TARGET_DIR"
mkdir -p "$TARGET_DIR/gumroad"
mkdir -p "$TARGET_DIR/products"
mkdir -p "$TARGET_DIR/tools"
mkdir -p "$TARGET_DIR/docs"
mkdir -p "$TARGET_DIR/automation"
status "Directory structure created"

# Function to safely move files
safe_move() {
    local source="$1"
    local target="$2"
    local description="$3"

    if [ -e "$source" ]; then
        info "Moving $description..."
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
progress "PHASE 1: Consolidating GumRoad Assets"
echo "========================================"

# GumRoad directory
safe_move "$HOME/GumRoad" "$TARGET_DIR/gumroad/" "GumRoad directory"

# GumRoad bundle files
safe_move "$HOME/GUMROAD_BUNDLE_1_PRODUCT_PAGE.md" "$TARGET_DIR/gumroad/" "GumRoad Bundle 1 product page"
safe_move "$HOME/GUMROAD_BUNDLE_4_PRODUCT_PAGE.md" "$TARGET_DIR/gumroad/" "GumRoad Bundle 4 product page"

# GumRoad strategy files
safe_move "$HOME/GUMROAD_BUNDLE_STRATEGY.md" "$TARGET_DIR/docs/" "GumRoad bundle strategy"
safe_move "$HOME/GUMROAD_EMAIL_LIST_STRATEGY.md" "$TARGET_DIR/docs/" "GumRoad email strategy"

# GumRoad index and documentation
safe_move "$HOME/GUMROAD_MASTER_INDEX.md" "$TARGET_DIR/docs/" "GumRoad master index"
safe_move "$HOME/GUMROAD_PHASE_3_EXECUTION_CHECKLIST.md" "$TARGET_DIR/docs/" "GumRoad phase 3 checklist"
safe_move "$HOME/GUMROAD_PHASE_3_SUMMARY.md" "$TARGET_DIR/docs/" "GumRoad phase 3 summary"
safe_move "$HOME/GUMROAD_QUICK_START.txt" "$TARGET_DIR/docs/" "GumRoad quick start guide"

# GumRoad data files
safe_move "$HOME/gumroad-massive.txt" "$TARGET_DIR/gumroad/" "GumRoad massive data file"

echo ""
progress "PHASE 2: Consolidating Business Projects"
echo "=========================================="

# Business project directories
safe_move "$HOME/marketplace_consolidation" "$TARGET_DIR/docs/" "Marketplace consolidation analysis"
safe_move "$HOME/MasterxEo" "$TARGET_DIR/products/" "MasterxEo project"
safe_move "$HOME/Memory-Optimization-Tools" "$TARGET_DIR/products/" "Memory optimization tools"

echo ""
progress "PHASE 3: Consolidating Development Tools"
echo "==========================================="

# Development and automation tools
safe_move "$HOME/my-gitbook" "$TARGET_DIR/docs/" "GitBook documentation"
safe_move "$HOME/n8n" "$TARGET_DIR/automation/" "N8N automation platform"

echo ""
progress "PHASE 4: Checking for Additional GumRoad Files"
echo "=================================================="

# Look for any other GUMROAD files in home directory
info "Scanning for additional GumRoad files..."
found_additional=0

for file in "$HOME"/GUMROAD*.md "$HOME"/GUMROAD*.txt "$HOME"/gumroad*.txt "$HOME"/gumroad*.md; do
    if [ -f "$file" ] && [[ "$file" != "$TARGET_DIR"* ]]; then
        filename=$(basename "$file")
        cp "$file" "$TARGET_DIR/docs/"
        count "✓ Additional file: $filename → docs/"
        found_additional=$((found_additional + 1))
    fi
done

if [ $found_additional -gt 0 ]; then
    info "Found and moved $found_additional additional GumRoad files"
else
    info "No additional GumRoad files found"
fi

echo ""
progress "PHASE 5: Organizing Within MarketMaster"
echo "========================================="

# Create sub-organization within MarketMaster
info "Creating internal organization..."

# GumRoad organization
mkdir -p "$TARGET_DIR/gumroad/bundles"
mkdir -p "$TARGET_DIR/gumroad/data"
mkdir -p "$TARGET_DIR/gumroad/docs"

# Move GumRoad files to appropriate subfolders
if [ -f "$TARGET_DIR/gumroad/GUMROAD_BUNDLE_1_PRODUCT_PAGE.md" ]; then
    mv "$TARGET_DIR/gumroad/GUMROAD_BUNDLE_1_PRODUCT_PAGE.md" "$TARGET_DIR/gumroad/bundles/"
    count "✓ Organized bundle files into bundles/ subfolder"
fi

if [ -f "$TARGET_DIR/gumroad/GUMROAD_BUNDLE_4_PRODUCT_PAGE.md" ]; then
    mv "$TARGET_DIR/gumroad/GUMROAD_BUNDLE_4_PRODUCT_PAGE.md" "$TARGET_DIR/gumroad/bundles/"
    count "✓ Organized bundle files into bundles/ subfolder"
fi

if [ -f "$TARGET_DIR/gumroad/gumroad-massive.txt" ]; then
    mv "$TARGET_DIR/gumroad/gumroad-massive.txt" "$TARGET_DIR/gumroad/data/"
    count "✓ Moved data file to data/ subfolder"
fi

# Products organization
mkdir -p "$TARGET_DIR/products/tools"
mkdir -p "$TARGET_DIR/products/projects"

if [ -d "$TARGET_DIR/products/Memory-Optimization-Tools" ]; then
    mv "$TARGET_DIR/products/Memory-Optimization-Tools" "$TARGET_DIR/products/tools/"
    count "✓ Organized memory tools into tools/ subfolder"
fi

echo ""
progress "PHASE 6: Final Verification"
echo "============================"

# Count files in each section
gumroad_count=$(find "$TARGET_DIR/gumroad" -type f 2>/dev/null | wc -l)
products_count=$(find "$TARGET_DIR/products" -type f 2>/dev/null | wc -l)
tools_count=$(find "$TARGET_DIR/tools" -type f 2>/dev/null | wc -l)
docs_count=$(find "$TARGET_DIR/docs" -type f 2>/dev/null | wc -l)
automation_count=$(find "$TARGET_DIR/automation" -type f 2>/dev/null | wc -l)

total_files=$((gumroad_count + products_count + tools_count + docs_count + automation_count))

echo ""
echo "🎯 MARKETMASTER CONSOLIDATION COMPLETE!"
echo "======================================"

count "Total files consolidated: $total_files"
echo ""
echo "📁 MARKETMASTER STRUCTURE:"
echo "========================="
echo "📂 $TARGET_DIR/"
echo "├── 📂 gumroad/          ($gumroad_count files)"
echo "│   ├── 📂 bundles/       - Product bundle pages"
echo "│   ├── 📂 data/          - GumRoad data files"
echo "│   └── 📂 docs/          - GumRoad documentation"
echo "├── 📂 products/         ($products_count files)"
echo "│   ├── 📂 tools/         - Business tools"
echo "│   └── 📂 projects/      - Business projects"
echo "├── 📂 docs/             ($docs_count files)"
echo "│   ├── GumRoad strategies, checklists, guides"
echo "│   └── Marketplace analysis"
echo "├── 📂 automation/       ($automation_count files)"
echo "│   └── N8N workflows and automation"
echo "└── 📂 tools/            ($tools_count files)"
echo "    └── Development and utility tools"
echo ""

echo "🎉 SUCCESS!"
echo "=========="
echo ""
echo "Your business assets are now consolidated in:"
echo "📁 $TARGET_DIR/"
echo ""
echo "Quick access:"
echo "• cd ~/MarketMaster           # Go to business hub"
echo "• cd ~/MarketMaster/gumroad   # Access GumRoad assets"
echo "• cd ~/MarketMaster/products  # Access business products"
echo "• cd ~/MarketMaster/docs      # Access documentation"
echo ""

warning "NOTE: Original files are still in place. Test the new organization,"
warning "then optionally remove originals when confident everything works."

status "MarketMaster consolidation complete! 🎯"