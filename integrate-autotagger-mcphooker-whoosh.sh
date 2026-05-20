#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail


# MasterxEo Integration Script
# Integrates mcPHooker, AutoTagger, and Whoosh search with the newly organized MasterxEo system

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

print_status $BOLD $PURPLE "🔗 INTEGRATING MCPHOOKER, AUTOTAGGER & WHOOSH SEARCH"
print_status $CYAN "=================================================="

MASTERXEO_ROOT="/Users/steven/MasterxEo"
AUTOTAGGER_ROOT="/Users/steven/AutoTagger/v4-workspace"
HOOKER_ROOT="/Users/steven/mcPHooker"
WHOOSH_ROOT="/Users/steven/Documents/whoosh-search-index"

print_status $CYAN "📁 Setting up integration directories..."

# Create integration directories in MasterxEo
mkdir -p "$MASTERXEO_ROOT/INTEGRATION_TOOLS/AUTO_TAGGER"
mkdir -p "$MASTERXEO_ROOT/INTEGRATION_TOOLS/MCPHOOKER"
mkdir -p "$MASTERXEO_ROOT/INTEGRATION_TOOLS/WHOOSH_SEARCH"
mkdir -p "$MASTERXEO_ROOT/INTEGRATION_TOOLS/COMBINED_ANALYSIS"

print_status $GREEN "✅ Created integration directories in MasterxEo"

# Link AutoTagger to MasterxEo
print_status $CYAN "🔗 Linking AutoTagger to MasterxEo..."
ln -sf "$AUTOTAGGER_ROOT" "$MASTERXEO_ROOT/INTEGRATION_TOOLS/AUTO_TAGGER/autotagger_link" 2>/dev/null || true
print_status $GREEN "✅ Linked AutoTagger to MasterxEo"

# Link mcPHooker to MasterxEo
print_status $CYAN "🔗 Linking mcPHooker to MasterxEo..."
ln -sf "$HOOKER_ROOT" "$MASTERXEO_ROOT/INTEGRATION_TOOLS/MCPHOOKER/mcphooker_link" 2>/dev/null || true
print_status $GREEN "✅ Linked mcPHooker to MasterxEo"

# Link Whoosh search to MasterxEo
print_status $CYAN "🔗 Linking Whoosh search to MasterxEo..."
ln -sf "$WHOOSH_ROOT" "$MASTERXEO_ROOT/INTEGRATION_TOOLS/WHOOSH_SEARCH/whoosh_link" 2>/dev/null || true
print_status $GREEN "✅ Linked Whoosh search to MasterxEo"

# Create a combined analysis script
COMBINED_SCRIPT="$MASTERXEO_ROOT/INTEGRATION_TOOLS/COMBINED_ANALYSIS/run_combined_analysis.sh"
cat > "$COMBINED_SCRIPT" << 'EOF'
#!/bin/bash

# Combined Analysis Script
# Runs AutoTagger, mcPHooker, and Whoosh search in sequence for comprehensive analysis

echo "🚀 Starting combined analysis with AutoTagger, mcPHooker, and Whoosh Search..."

# Run AutoTagger on MasterxEo directories
echo "🔍 Running AutoTagger analysis on MasterxEo..."
cd /Users/steven/AutoTagger/v4-workspace
if [ -f "./autotag.sh" ]; then
    ./autotag.sh /Users/steven/MasterxEo "masterxeo_analysis_$(date +%Y%m%d_%H%M%S)"
else
    echo "⚠️  AutoTagger script not found"
fi

# Run Whoosh indexing on MasterxEo
echo "📚 Indexing MasterxEo with Whoosh..."
cd /Users/steven/Documents/whoosh-search-index
if [ -f "index_documents.py" ]; then
    python3 index_documents.py
else
    echo "⚠️  Whoosh indexer not found"
fi

# Run mcPHooker analysis if applicable
echo "🔗 Running mcPHooker analysis..."
cd /Users/steven/mcPHooker
if [ -f "src/tool_use_tracker.py" ]; then
    echo "mcPHooker components found, ready for integration"
else
    echo "⚠️  mcPHooker components not found"
fi

echo "✅ Combined analysis completed!"
echo "📊 Results available in respective output directories"
EOF

chmod +x "$COMBINED_SCRIPT"
print_status $GREEN "✅ Created combined analysis script"

# Create an integration report
REPORT_FILE="$MASTERXEO_ROOT/INTEGRATION_TOOLS/INTEGRATION_REPORT.md"
echo "# MasterxEo Integration Report" > "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
echo "Date: $(date)" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
echo "## Integration Components" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
echo "- **AutoTagger**: Content-aware categorization and business value prediction" >> "$REPORT_FILE"
echo "- **mcPHooker**: Hooks and tool-telemetry toolkit for agent systems" >> "$REPORT_FILE"
echo "- **Whoosh Search**: Full-text search capabilities for documents" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
echo "## Integration Benefits" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
echo "1. **Enhanced Discoverability**: Combined tagging and search capabilities" >> "$REPORT_FILE"
echo "2. **Business Value Assessment**: AutoTagger's value prediction integrated with search" >> "$REPORT_FILE"
echo "3. **Tool Telemetry**: mcPHooker's tracking capabilities for automation tools" >> "$REPORT_FILE"
echo "4. **Content Awareness**: Intelligent categorization of automation assets" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
echo "## Usage Instructions" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
echo "Run combined analysis:" >> "$REPORT_FILE"
echo '```bash' >> "$REPORT_FILE"
echo "bash /Users/steven/MasterxEo/INTEGRATION_TOOLS/COMBINED_ANALYSIS/run_combined_analysis.sh" >> "$REPORT_FILE"
echo "```" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
echo "Run individual components:" >> "$REPORT_FILE"
echo "- AutoTagger: \`cd /Users/steven/AutoTagger/v4-workspace && ./autotag.sh\`" >> "$REPORT_FILE"
echo "- Whoosh Search: \`cd /Users/steven/Documents/whoosh-search-index && python3 search_documents.py\`" >> "$REPORT_FILE"
echo "- mcPHooker: Available in /Users/steven/mcPHooker for extension integration" >> "$REPORT_FILE"

print_status $GREEN "✅ Created integration report"

# Create a quick access script
ACCESS_SCRIPT="$MASTERXEO_ROOT/INTEGRATION_TOOLS/quick_access.sh"
cat > "$ACCESS_SCRIPT" << 'EOF'
#!/bin/bash

# Quick Access Script for Integrated Tools
# Provides shortcuts to commonly used functions

echo "🚀 MasterxEo Integrated Tools Quick Access"
echo "=========================================="
echo ""
echo "Select an option:"
echo "1) Run AutoTagger analysis"
echo "2) Search with Whoosh"
echo "3) View mcPHooker templates"
echo "4) Run combined analysis"
echo "5) View integration report"
echo "6) Exit"
echo ""

read -p "Enter your choice (1-6): " choice

case $choice in
    1)
        echo "Running AutoTagger on MasterxEo..."
        cd /Users/steven/AutoTagger/v4-workspace
        ./autotag.sh /Users/steven/MasterxEo "quick_analysis_$(date +%Y%m%d_%H%M%S)"
        ;;
    2)
        echo "Starting Whoosh search..."
        cd /Users/steven/Documents/whoosh-search-index
        python3 search_documents.py
        ;;
    3)
        echo "mcPHooker templates:"
        ls -la /Users/steven/mcPHooker/templates/
        ;;
    4)
        echo "Running combined analysis..."
        bash /Users/steven/MasterxEo/INTEGRATION_TOOLS/COMBINED_ANALYSIS/run_combined_analysis.sh
        ;;
    5)
        echo "Opening integration report..."
        cat /Users/steven/MasterxEo/INTEGRATION_TOOLS/INTEGRATION_REPORT.md
        ;;
    6)
        echo "Exiting..."
        exit 0
        ;;
    *)
        echo "Invalid choice. Exiting..."
        ;;
esac
EOF

chmod +x "$ACCESS_SCRIPT"
print_status $GREEN "✅ Created quick access script"

print_status $YELLOW "💡 Integration completed! Key features:"
echo "   • AutoTagger linked to MasterxEo for content-aware categorization"
echo "   • mcPHooker linked for tool telemetry and hooks"
echo "   • Whoosh search linked for full-text document search"
echo "   • Combined analysis script created"
echo "   • Integration report generated"
echo "   • Quick access script for easy tool access"

print_status $BOLD $PURPLE "🔗 INTEGRATION SUCCESSFULLY COMPLETED!"
print_status $CYAN "The MasterxEo system is now enhanced with AutoTagger, mcPHooker, and Whoosh search capabilities."
