#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail


# 🚀 RUN ALL 5 STATIC PROJECTS
# Starts a simple server for each project on different ports

WORKSPACE="/Users/steven/tehSiTes"

echo "╔════════════════════════════════════════════════════════════╗"
echo "║  🚀 STARTING ALL 5 STATIC PROJECTS                         ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""
echo "📝 Quick Start Commands:"
echo ""
echo "To run projects individually, use:"
echo ""
echo "  Gallery (port 8000):"
echo "  cd $WORKSPACE/avatararts-gallery/public && python3 -m http.server 8000"
echo ""
echo "  Hub (port 8001):"
echo "  cd $WORKSPACE/avatararts-hub/public && python3 -m http.server 8001"
echo ""
echo "  Portfolio (port 8002):"
echo "  cd $WORKSPACE/avatararts-portfolio/public && python3 -m http.server 8002"
echo ""
echo "  Tools (port 8003):"
echo "  cd $WORKSPACE/avatararts-tools/public && python3 -m http.server 8003"
echo ""
echo "  Main Site (port 8004):"
echo "  cd $WORKSPACE/avatararts.org/public && python3 -m http.server 8004"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Then access them at:"
echo ""
echo "  🖼️  Gallery:   http://localhost:8000"
echo "  🌐 Hub:       http://localhost:8001"
echo "  💼 Portfolio: http://localhost:8002"
echo "  🛠️  Tools:     http://localhost:8003"
echo "  🌍 Main Site: http://localhost:8004"
echo ""
echo "Or use VS Code Live Server:"
echo "  1. Open each index.html in VS Code"
echo "  2. Right-click → Open with Live Server"
echo ""
