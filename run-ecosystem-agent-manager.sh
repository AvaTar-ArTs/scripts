#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail

# EcoSystem Agent Manager Runner
# This script runs the comprehensive ecosystem agent to scan, analyze, and manage Steven's entire automation ecosystem

echo "🚀 Starting EcoSystem Agent Manager..."
echo "📅 $(date)"
echo " "

# Check if Python is available
if ! command -v python3 &> /dev/null; then
    echo "❌ Python3 is not installed or not in PATH"
    exit 1
fi

echo "✅ Python3 is available"
echo " "

# Run the ecosystem agent manager
echo "🤖 Running EcoSystem Agent Manager..."
python3 /Users/steven/ecosystem_agent_manager.py

echo " "
echo "✅ EcoSystem Agent Manager completed successfully!"
echo " "

# Display summary of generated files
echo "📁 Generated Files Summary:"
echo "- ecosystem_comprehensive_report.md: Complete analysis of the ecosystem"
echo "- ecosystem_documentation.md: Comprehensive documentation of all systems"
echo "- ecosystem_assets.csv: Structured data of all assets"
echo "- ecosystem_agent.db: Database with all asset information"
echo " "

echo "📈 Next Steps:"
echo "1. Review ecosystem_comprehensive_report.md for detailed analysis"
echo "2. Examine ecosystem_documentation.md for system documentation"
echo "3. Analyze ecosystem_assets.csv for asset details"
echo "4. Use ecosystem_agent.db for further queries and analysis"
echo " "

echo "🎉 The comprehensive agent has successfully analyzed and documented Steven's entire automation ecosystem!"
echo "📅 Completed at $(date)"
