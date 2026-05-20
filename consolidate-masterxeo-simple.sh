#!/bin/bash
set -euo pipefail
# 🎯 **SIMPLE MASTERS EO CONSOLIDATION**
# Direct consolidation of key business directories

echo "🎯 SIMPLE MASTERS EO CONSOLIDATION"
echo "=================================="

# Create MasterxEo structure
echo "Creating MasterxEo framework..."
mkdir -p ~/MasterxEo/01_ASSETS_LIBRARY
mkdir -p ~/MasterxEo/02_MARKETPLACE_LISTINGS
mkdir -p ~/MasterxEo/03_REVENUE_TRACKING
mkdir -p ~/MasterxEo/04_BRANDING_KITS
mkdir -p ~/MasterxEo/05_DEPLOYMENT_TOOLS
mkdir -p ~/MasterxEo/06_BACKUP_ARCHIVE
mkdir -p ~/MasterxEo/07_DOCUMENTATION
mkdir -p ~/MasterxEo/08_MARKETPLACE_ASSETS

echo "✅ MasterxEo framework created"

# Phase 1: Assets Library
echo ""
echo "📚 Phase 1: Consolidating Assets Library..."
if [ -d ~/AVATARARTS ]; then
    cp -r ~/AVATARARTS ~/MasterxEo/01_ASSETS_LIBRARY/
    echo "✅ Added AVATARARTS to assets library"
fi

if [ -d ~/active ]; then
    cp -r ~/active ~/MasterxEo/01_ASSETS_LIBRARY/
    echo "✅ Added active workspace to assets library"
fi

# Phase 2: Marketplace Listings
echo ""
echo "🛒 Phase 2: Consolidating Marketplace Listings..."
if [ -d ~/GumRoad ]; then
    cp -r ~/GumRoad ~/MasterxEo/02_MARKETPLACE_LISTINGS/
    echo "✅ Added GumRoad to marketplace listings"
fi

if [ -d ~/marketplace_consolidation ]; then
    cp -r ~/marketplace_consolidation ~/MasterxEo/02_MARKETPLACE_LISTINGS/
    echo "✅ Added marketplace consolidation to listings"
fi

# Phase 3: Revenue Tracking
echo ""
echo "💰 Phase 3: Consolidating Revenue Tracking..."
if [ -d ~/reports ]; then
    cp -r ~/reports ~/MasterxEo/03_REVENUE_TRACKING/
    echo "✅ Added reports to revenue tracking"
fi

# Phase 4: Documentation
echo ""
echo "📖 Phase 4: Consolidating Documentation..."
if [ -d ~/workspace ]; then
    cp -r ~/workspace ~/MasterxEo/07_DOCUMENTATION/
    echo "✅ Added workspace to documentation"
fi

# Count files
echo ""
echo "📊 CONSOLIDATION SUMMARY:"
total_files=$(find ~/MasterxEo -type f 2>/dev/null | wc -l)
echo "Total files consolidated: $total_files"

echo ""
echo "🏗️  MASTERS EO STRUCTURE:"
ls -la ~/MasterxEo/ | grep "^d" | wc -l
echo "directories created"

echo ""
echo "🎯 MASTERS EO BUSINESS FRAMEWORK READY!"
echo "Navigate with: cd ~/MasterxEo"
echo ""
echo "Business modules:"
echo "01_ASSETS_LIBRARY     - Digital assets & resources"
echo "02_MARKETPLACE_LISTINGS - Product listings & marketplace data"
echo "03_REVENUE_TRACKING   - Financial tracking & analytics"
echo "04_BRANDING_KITS      - Branding materials & assets"
echo "05_DEPLOYMENT_TOOLS   - Launch tools & deployment scripts"
echo "06_BACKUP_ARCHIVE     - Archives, backups & historical data"
echo "07_DOCUMENTATION      - Documentation, guides & reports"
echo "08_MARKETPLACE_ASSETS - Marketplace-specific assets"
echo ""
echo "✅ Consolidation complete!"
