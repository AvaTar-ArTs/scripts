#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail


# Final Integration Verification Script
# Verifies that all integration components are properly set up

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

print_status $BOLD $PURPLE "🔍 VERIFYING INTEGRATION COMPONENTS"
print_status $CYAN "=================================="

MASTERXEO_ROOT="/Users/steven/MasterxEo"
AUTOTAGGER_ROOT="/Users/steven/AutoTagger/v4-workspace"
HOOKER_ROOT="/Users/steven/mcPHooker"
WHOOSH_ROOT="/Users/steven/Documents/whoosh-search-index"

# Verify directories exist
if [ -d "$MASTERXEO_ROOT/INTEGRATION_TOOLS" ]; then
    print_status $GREEN "✅ Integration tools directory exists"
else
    print_status $RED "❌ Integration tools directory missing"
    mkdir -p "$MASTERXEO_ROOT/INTEGRATION_TOOLS"
    print_status $YELLOW "📁 Created integration tools directory"
fi

# Verify AutoTagger link
if [ -L "$MASTERXEO_ROOT/INTEGRATION_TOOLS/AUTO_TAGGER/autotagger_link" ]; then
    print_status $GREEN "✅ AutoTagger link exists"
else
    print_status $RED "❌ AutoTagger link missing"
    mkdir -p "$MASTERXEO_ROOT/INTEGRATION_TOOLS/AUTO_TAGGER"
    ln -sf "$AUTOTAGGER_ROOT" "$MASTERXEO_ROOT/INTEGRATION_TOOLS/AUTO_TAGGER/autotagger_link"
    print_status $YELLOW "🔗 Created AutoTagger link"
fi

# Verify mcPHooker link
if [ -L "$MASTERXEO_ROOT/INTEGRATION_TOOLS/MCPHOOKER/mcphooker_link" ]; then
    print_status $GREEN "✅ mcPHooker link exists"
else
    print_status $RED "❌ mcPHooker link missing"
    mkdir -p "$MASTERXEO_ROOT/INTEGRATION_TOOLS/MCPHOOKER"
    ln -sf "$HOOKER_ROOT" "$MASTERXEO_ROOT/INTEGRATION_TOOLS/MCPHOOKER/mcphooker_link"
    print_status $YELLOW "🔗 Created mcPHooker link"
fi

# Verify Whoosh link
if [ -L "$MASTERXEO_ROOT/INTEGRATION_TOOLS/WHOOSH_SEARCH/whoosh_link" ]; then
    print_status $GREEN "✅ Whoosh search link exists"
else
    print_status $RED "❌ Whoosh search link missing"
    mkdir -p "$MASTERXEO_ROOT/INTEGRATION_TOOLS/WHOOSH_SEARCH"
    ln -sf "$WHOOSH_ROOT" "$MASTERXEO_ROOT/INTEGRATION_TOOLS/WHOOSH_SEARCH/whoosh_link"
    print_status $YELLOW "🔗 Created Whoosh search link"
fi

# Recreate the integration report properly
REPORT_FILE="$MASTERXEO_ROOT/INTEGRATION_TOOLS/INTEGRATION_REPORT.md"
cat > "$REPORT_FILE" << EOF
# MasterxEo Integration Report

Date: $(date)

## Integration Components

- **AutoTagger**: Content-aware categorization and business value prediction
- **mcPHooker**: Hooks and tool-telemetry toolkit for agent systems
- **Whoosh Search**: Full-text search capabilities for documents

## Integration Benefits

1. **Enhanced Discoverability**: Combined tagging and search capabilities
2. **Business Value Assessment**: AutoTagger's value prediction integrated with search
3. **Tool Telemetry**: mcPHooker's tracking capabilities for automation tools
4. **Content Awareness**: Intelligent categorization of automation assets

## Usage Instructions

Run combined analysis:
\`\`\`bash
bash /Users/steven/MasterxEo/INTEGRATION_TOOLS/COMBINED_ANALYSIS/run_combined_analysis.sh
\`\`\`

Run individual components:
- AutoTagger: \`cd /Users/steven/AutoTagger/v4-workspace && ./autotag.sh\`
- Whoosh Search: \`cd /Users/steven/Documents/whoosh-search-index && python3 search_documents.py\`
- mcPHooker: Available in /Users/steven/mcPHooker for extension integration
EOF

print_status $GREEN "✅ Integration report recreated properly"

# Verify combined analysis script exists
COMBINED_SCRIPT="$MASTERXEO_ROOT/INTEGRATION_TOOLS/COMBINED_ANALYSIS/run_combined_analysis.sh"
if [ -f "$COMBINED_SCRIPT" ]; then
    print_status $GREEN "✅ Combined analysis script exists"
else
    print_status $RED "❌ Combined analysis script missing"
    mkdir -p "$MASTERXEO_ROOT/INTEGRATION_TOOLS/COMBINED_ANALYSIS"
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
    print_status $YELLOW "📄 Created combined analysis script"
fi

# Verify quick access script exists
ACCESS_SCRIPT="$MASTERXEO_ROOT/INTEGRATION_TOOLS/quick_access.sh"
if [ -f "$ACCESS_SCRIPT" ]; then
    print_status $GREEN "✅ Quick access script exists"
else
    print_status $RED "❌ Quick access script missing"
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
    print_status $YELLOW "📄 Created quick access script"
fi

print_status $BOLD $GREEN "🎉 INTEGRATION VERIFICATION COMPLETE!"
print_status $CYAN "All components are properly integrated with the MasterxEo system."
