#!/bin/bash
set -euo pipefail
# 🚀 **MARKETMASTER NAVIGATION HELPER**

echo "🏪 MarketMaster Business Hub"
echo "============================"
echo ""
echo "Your consolidated business assets:"
echo ""

# Check if MarketMaster exists
if [ ! -d "$HOME/MarketMaster" ]; then
    echo "❌ MarketMaster directory not found!"
    echo "Run: ~/consolidate_marketmaster.sh"
    exit 1
fi

# Show structure
echo "📂 ~/MarketMaster/"
echo "├── 📂 gumroad/     ($(find "$HOME/MarketMaster/gumroad" -type f 2>/dev/null | wc -l) files)"
echo "│   ├── 📂 bundles/    - Product bundle pages"
echo "│   ├── 📂 data/       - GumRoad data & analytics"
echo "│   └── 📂 docs/       - GumRoad documentation"
echo "├── 📂 products/    ($(find "$HOME/MarketMaster/products" -type f 2>/dev/null | wc -l) files)"
echo "│   ├── 📂 tools/      - Memory optimization, business tools"
echo "│   └── 📂 projects/   - MasterxEo, business projects"
echo "├── 📂 docs/        ($(find "$HOME/MarketMaster/docs" -type f 2>/dev/null | wc -l) files)"
echo "│   ├── Strategies, checklists, guides"
echo "│   └── Marketplace analysis & planning"
echo "├── 📂 automation/  ($(find "$HOME/MarketMaster/automation" -type f 2>/dev/null | wc -l) files)"
echo "│   └── N8N workflows & business automation"
echo "└── 📂 tools/       ($(find "$HOME/MarketMaster/tools" -type f 2>/dev/null | wc -l) files)"
echo "    └── Development & utility tools"
echo ""

echo "🎯 Quick Commands:"
echo "=================="
echo "cd ~/MarketMaster           # Enter business hub"
echo "cd ~/MarketMaster/gumroad   # GumRoad operations"
echo "cd ~/MarketMaster/products  # Business products"
echo "cd ~/MarketMaster/docs      # Documentation & strategy"
echo "ls ~/MarketMaster/*/*      # See all subdirectories"
echo ""

echo "📊 Key Files:"
echo "============="
echo "GumRoad Master Index: ~/MarketMaster/docs/GUMROAD_MASTER_INDEX.md"
echo "Phase 3 Checklist:    ~/MarketMaster/docs/GUMROAD_PHASE_3_EXECUTION_CHECKLIST.md"
echo "Bundle Strategy:      ~/MarketMaster/docs/GUMROAD_BUNDLE_STRATEGY.md"
echo ""

echo "🚀 Ready for business operations! 💼"
