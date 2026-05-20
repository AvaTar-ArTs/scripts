#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail

# START HERE - Quick introduction to the analysis toolkit

clear

cat << 'BANNER'
╔══════════════════════════════════════════════════════════════════╗
║                                                                  ║
║     🔍 FLUID ADAPTIVE ANALYSIS TOOLKIT - START HERE 🔍           ║
║                                                                  ║
╔══════════════════════════════════════════════════════════════════╝

Welcome! This toolkit provides intelligent code analysis for your projects.

BANNER

echo ""
echo "📚 QUICK START GUIDE"
echo "════════════════════════════════════════════════════════════════"
echo ""
echo "1️⃣  Read the documentation:"
echo "    cat ANALYSIS_TOOLKIT_README.md | less"
echo ""
echo "2️⃣  Try a quick analysis:"
echo "    ./analysis_launcher.sh current"
echo ""
echo "3️⃣  Analyze a specific file:"
echo "    python3 fluid_adaptive_analyzer.py yourfile.py"
echo ""
echo "4️⃣  Analyze multiple directories:"
echo "    python3 analyze_multiple_dirs.py"
echo ""
echo "════════════════════════════════════════════════════════════════"
echo ""
echo "📖 WHAT TO READ FIRST"
echo "════════════════════════════════════════════════════════════════"
echo ""
echo "  QUICK_REFERENCE.md         - Quick commands (START HERE!) 🌟"
echo "  INDEX.md                   - Overview of all tools"
echo "  ANALYSIS_TOOLKIT_README.md - Complete guide"
echo "  ACCOMPLISHMENTS_SUMMARY.md - What was built"
echo ""
echo "════════════════════════════════════════════════════════════════"
echo ""
echo "⚡ TRY IT NOW"
echo "════════════════════════════════════════════════════════════════"
echo ""
read -p "Would you like to try a quick analysis of the current directory? [y/N] " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
    echo ""
    echo "Running analysis..."
    ./analysis_launcher.sh current
fi

echo ""
echo "════════════════════════════════════════════════════════════════"
echo ""
echo "💡 TIP: Run './analysis_launcher.sh help' to see all commands"
echo ""
