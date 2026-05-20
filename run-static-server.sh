#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail


# 🌐 Simple Static Server Launcher
# Runs the static HTML projects without any build tools

WORKSPACE="/Users/steven/tehSiTes/static-projects"

echo "╔════════════════════════════════════════════════════════════╗"
echo "║  🌐 Starting Static HTML Server                            ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""
echo "📁 Server root: $WORKSPACE"
echo ""
echo "🚀 Serving on: http://localhost:8000"
echo ""
echo "Press Ctrl+C to stop"
echo ""

cd "$WORKSPACE" && python3 -m http.server 8000
