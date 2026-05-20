#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail


# MasterxEo Consolidation Script
# This script creates a proper organizational structure for the MasterxEo directory
# and moves files to appropriate functional categories

# Text Color Variables
GREEN='\033[32m'
BLUE='\033[34m'
YELLOW='\033[33m'
RED='\033[31m'
PURPLE='\033[35m'
CYAN='\033[36m'
BOLD='\033[1m'
CLEAR='\033[0m'

# Function to print status
print_status() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${CLEAR}"
}

print_status $BOLD $PURPLE "🏢 CREATING MASTERXEO ORGANIZATIONAL STRUCTURE"
print_status $CYAN "============================================="

# Define the MasterxEo root
MASTERXEO_ROOT="/Users/steven/MasterxEo"

# Create the new organizational structure
mkdir -p "$MASTERXEO_ROOT"/{AUTOMATION,REVENUE,BUSINESS_INTELLIGENCE,AI_ML,DATA_PROCESSING,API_INTEGRATION,DEVELOPMENT_TOOLS,DOCUMENTATION,MEDIA_PROCESSING,PORTFOLIO_MANAGEMENT,CONTENT_CREATION,SEO_MARKETING,ARCHIVES,UTILITIES,CONFIGURATIONS,MISCELLANEOUS}

print_status $GREEN "✅ Created functional directory structure in MasterxEo"

# Move existing directories to appropriate functional categories
print_status $CYAN "📁 Moving existing directories to functional categories..."

# Move marketplace-related directories to REVENUE
if [ -d "$MASTERXEO_ROOT/Codester" ]; then
    mv "$MASTERXEO_ROOT/Codester" "$MASTERXEO_ROOT/REVENUE/" 2>/dev/null || true
    print_status $GREEN "✅ Moved Codester to REVENUE"
fi

if [ -d "$MASTERXEO_ROOT/Gumroad" ]; then
    mv "$MASTERXEO_ROOT/Gumroad" "$MASTERXEO_ROOT/REVENUE/" 2>/dev/null || true
    print_status $GREEN "✅ Moved Gumroad to REVENUE"
fi

if [ -d "$MASTERXEO_ROOT/Etsy" ]; then
    mv "$MASTERXEO_ROOT/Etsy" "$MASTERXEO_ROOT/REVENUE/" 2>/dev/null || true
    print_status $GREEN "✅ Moved Etsy to REVENUE"
fi

if [ -d "$MASTERXEO_ROOT/Sellfy" ]; then
    mv "$MASTERXEO_ROOT/Sellfy" "$MASTERXEO_ROOT/REVENUE/" 2>/dev/null || true
    print_status $GREEN "✅ Moved Sellfy to REVENUE"
fi

if [ -d "$MASTERXEO_ROOT/Payhip" ]; then
    mv "$MASTERXEO_ROOT/Payhip" "$MASTERXEO_ROOT/REVENUE/" 2>/dev/null || true
    print_status $GREEN "✅ Moved Payhip to REVENUE"
fi

if [ -d "$MASTERXEO_ROOT/LemonSqueezy" ]; then
    mv "$MASTERXEO_ROOT/LemonSqueezy" "$MASTERXEO_ROOT/REVENUE/" 2>/dev/null || true
    print_status $GREEN "✅ Moved LemonSqueezy to REVENUE"
fi

# Move products and related directories to appropriate categories
if [ -d "$MASTERXEO_ROOT/Products" ]; then
    mv "$MASTERXEO_ROOT/Products" "$MASTERXEO_ROOT/BUSINESS_INTELLIGENCE/" 2>/dev/null || true
    print_status $GREEN "✅ Moved Products to BUSINESS_INTELLIGENCE"
fi

if [ -d "$MASTERXEO_ROOT/02_MARKETPLACE_LISTINGS" ]; then
    mv "$MASTERXEO_ROOT/02_MARKETPLACE_LISTINGS" "$MASTERXEO_ROOT/REVENUE/" 2>/dev/null || true
    print_status $GREEN "✅ Moved Marketplace Listings to REVENUE"
fi

if [ -d "$MASTERXEO_ROOT/03_REVENUE_TRACKING" ]; then
    mv "$MASTERXEO_ROOT/03_REVENUE_TRACKING" "$MASTERXEO_ROOT/REVENUE/" 2>/dev/null || true
    print_status $GREEN "✅ Moved Revenue Tracking to REVENUE"
fi

if [ -d "$MASTERXEO_ROOT/01_ASSETS_LIBRARY" ]; then
    mv "$MASTERXEO_ROOT/01_ASSETS_LIBRARY" "$MASTERXEO_ROOT/PORTFOLIO_MANAGEMENT/" 2>/dev/null || true
    print_status $GREEN "✅ Moved Assets Library to PORTFOLIO_MANAGEMENT"
fi

if [ -d "$MASTERXEO_ROOT/04_BRANDING_KITS" ]; then
    mv "$MASTERXEO_ROOT/04_BRANDING_KITS" "$MASTERXEO_ROOT/PORTFOLIO_MANAGEMENT/" 2>/dev/null || true
    print_status $GREEN "✅ Moved Branding Kits to PORTFOLIO_MANAGEMENT"
fi

if [ -d "$MASTERXEO_ROOT/05_DEPLOYMENT_TOOLS" ]; then
    mv "$MASTERXEO_ROOT/05_DEPLOYMENT_TOOLS" "$MASTERXEO_ROOT/DEVELOPMENT_TOOLS/" 2>/dev/null || true
    print_status $GREEN "✅ Moved Deployment Tools to DEVELOPMENT_TOOLS"
fi

if [ -d "$MASTERXEO_ROOT/07_DOCUMENTATION" ]; then
    mv "$MASTERXEO_ROOT/07_DOCUMENTATION" "$MASTERXEO_ROOT/DOCUMENTATION/" 2>/dev/null || true
    print_status $GREEN "✅ Moved Documentation to DOCUMENTATION"
fi

if [ -d "$MASTERXEO_ROOT/AI-Tools" ]; then
    mv "$MASTERXEO_ROOT/AI-Tools" "$MASTERXEO_ROOT/AI_ML/" 2>/dev/null || true
    print_status $GREEN "✅ Moved AI-Tools to AI_ML"
fi

if [ -d "$MASTERXEO_ROOT/AI-Research" ]; then
    mv "$MASTERXEO_ROOT/AI-Research" "$MASTERXEO_ROOT/AI_ML/" 2>/dev/null || true
    print_status $GREEN "✅ Moved AI-Research to AI_ML"
fi

if [ -d "$MASTERXEO_ROOT/Marketing" ]; then
    mv "$MASTERXEO_ROOT/Marketing" "$MASTERXEO_ROOT/SEO_MARKETING/" 2>/dev/null || true
    print_status $GREEN "✅ Moved Marketing to SEO_MARKETING"
fi

# Move tools and automation directories
if [ -d "$MASTERXEO_ROOT/TOOLS" ]; then
    mv "$MASTERXEO_ROOT/TOOLS" "$MASTERXEO_ROOT/AUTOMATION/" 2>/dev/null || true
    print_status $GREEN "✅ Moved TOOLS to AUTOMATION"
fi

# Move scripts and automation files
find "$MASTERXEO_ROOT" -name "*.sh" -type f -exec mv {} "$MASTERXEO_ROOT/AUTOMATION/" \; 2>/dev/null || true
find "$MASTERXEO_ROOT" -name "*.py" -type f -exec mv {} "$MASTERXEO_ROOT/DEVELOPMENT_TOOLS/" \; 2>/dev/null || true

# Move documentation files
find "$MASTERXEO_ROOT" -name "*.md" -type f -exec mv {} "$MASTERXEO_ROOT/DOCUMENTATION/" \; 2>/dev/null || true
find "$MASTERXEO_ROOT" -name "*.txt" -type f -exec mv {} "$MASTERXEO_ROOT/DOCUMENTATION/" \; 2>/dev/null || true

# Move media files
find "$MASTERXEO_ROOT" -name "*.png" -type f -exec mv {} "$MASTERXEO_ROOT/MEDIA_PROCESSING/" \; 2>/dev/null || true
find "$MASTERXEO_ROOT" -name "*.jpg" -type f -exec mv {} "$MASTERXEO_ROOT/MEDIA_PROCESSING/" \; 2>/dev/null || true
find "$MASTERXEO_ROOT" -name "*.jpeg" -type f -exec mv {} "$MASTERXEO_ROOT/MEDIA_PROCESSING/" \; 2>/dev/null || true
find "$MASTERXEO_ROOT" -name "*.gif" -type f -exec mv {} "$MASTERXEO_ROOT/MEDIA_PROCESSING/" \; 2>/dev/null || true
find "$MASTERXEO_ROOT" -name "*.mp3" -type f -exec mv {} "$MASTERXEO_ROOT/MEDIA_PROCESSING/" \; 2>/dev/null || true
find "$MASTERXEO_ROOT" -name "*.mp4" -type f -exec mv {} "$MASTERXEO_ROOT/MEDIA_PROCESSING/" \; 2>/dev/null || true

print_status $CYAN "🔄 Organizing remaining files..."

# Create a report of the new structure
echo "" >> "$MASTERXEO_ROOT/ORGANIZATION_REPORT.md"
echo "# MasterxEo Organizational Report" >> "$MASTERXEO_ROOT/ORGANIZATION_REPORT.md"
echo "" >> "$MASTERXEO_ROOT/ORGANIZATION_REPORT.md"
echo "This report details the reorganization of the MasterxEo directory structure." >> "$MASTERXEO_ROOT/ORGANIZATION_REPORT.md"
echo "" >> "$MASTERXEO_ROOT/ORGANIZATION_REPORT.md"
echo "## Functional Categories" >> "$MASTERXEO_ROOT/ORGANIZATION_REPORT.md"
echo "" >> "$MASTERXEO_ROOT/ORGANIZATION_REPORT.md"

for dir in AUTOMATION REVENUE BUSINESS_INTELLIGENCE AI_ML DATA_PROCESSING API_INTEGRATION DEVELOPMENT_TOOLS DOCUMENTATION MEDIA_PROCESSING PORTFOLIO_MANAGEMENT CONTENT_CREATION SEO_MARKETING ARCHIVES UTILITIES CONFIGURATIONS MISCELLANEOUS; do
    count=$(find "$MASTERXEO_ROOT/$dir" -type f 2>/dev/null | wc -l)
    echo "- $dir: $count files" >> "$MASTERXEO_ROOT/ORGANIZATION_REPORT.md"
done

print_status $GREEN "✅ Organization completed! New structure created:"
echo "   • AUTOMATION: For automation scripts and tools"
echo "   • REVENUE: For marketplace listings and revenue tracking"
echo "   • BUSINESS_INTELLIGENCE: For business operations and products"
echo "   • AI_ML: For AI tools and research"
echo "   • DATA_PROCESSING: For data processing tools"
echo "   • DEVELOPMENT_TOOLS: For development utilities"
echo "   • DOCUMENTATION: For documentation files"
echo "   • MEDIA_PROCESSING: For media assets"
echo "   • PORTFOLIO_MANAGEMENT: For branding and assets"
echo "   • SEO_MARKETING: For marketing materials"
echo "   • ARCHIVES: For archived materials"
echo "   • UTILITIES: For utility scripts"
echo "   • CONFIGURATIONS: For configuration files"
echo "   • MISCELLANEOUS: For uncategorized files"

print_status $YELLOW "💡 Next steps:"
echo "   1. Review the new organizational structure"
echo "   2. Update any hardcoded paths in your scripts"
echo "   3. Test all functionality with the new structure"
echo "   4. Update the too-many-lost.txt file to reflect new organization"

print_status $BOLD $PURPLE "🎯 MASTERXEO ORGANIZATIONAL TRANSFORMATION COMPLETE"
