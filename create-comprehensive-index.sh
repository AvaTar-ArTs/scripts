#!/bin/bash
# 📊 **COMPREHENSIVE FILESYSTEM INDEX**
# Creates complete inventory before reorganization

set -e

echo "📊 CREATING COMPREHENSIVE FILESYSTEM INDEX"
echo "=========================================="

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
section() { echo -e "${PURPLE}📁 $1${NC}"; }
count() { echo -e "${CYAN}🔢 $1${NC}"; }

INDEX_FILE="$HOME/filesystem_master_index_$(date +%Y%m%d_%H%M%S).txt"

echo "Creating master index: $INDEX_FILE"
echo ""

# Function to safely count files
safe_count() {
    local path="$1"
    if [ -d "$path" ] 2>/dev/null; then
        find "$path" -type f 2>/dev/null | wc -l | tr -d ' '
    else
        echo "0"
    fi
}

# Function to get directory size
dir_size() {
    local path="$1"
    if [ -d "$path" ] 2>/dev/null; then
        du -sh "$path" 2>/dev/null | cut -f1
    else
        echo "N/A"
    fi
}

# Function to analyze directory contents
analyze_directory() {
    local path="$1"
    local name="$2"

    if [ ! -d "$path" ]; then
        return
    fi

    section "$name ($path)"

    # Count files
    local file_count=$(safe_count "$path")
    local size=$(dir_size "$path")
    count "Files: $file_count | Size: $size"

    # Show subdirectories (top level only)
    echo "Subdirectories:"
    find "$path" -maxdepth 1 -type d 2>/dev/null | tail -n +2 | sort | while read -r dir; do
        local dirname=$(basename "$dir")
        local sub_count=$(safe_count "$dir")
        local sub_size=$(dir_size "$dir")
        echo "  📂 $dirname/ ($sub_count files, $sub_size)"
    done

    # Show file types
    echo "File types:"
    find "$path" -type f 2>/dev/null | head -1000 | sed 's/.*\.//' | sort | uniq -c | sort -nr | head -10 | while read -r count ext; do
        echo "  .$ext: $count files"
    done

    echo ""
}

{
    echo "FILESYSTEM MASTER INDEX"
    echo "======================="
    echo "Generated: $(date)"
    echo "User: $USER"
    echo "Home: $HOME"
    echo ""

    # PYTHON ECOSYSTEM
    echo "🐍 PYTHON ECOSYSTEM"
    echo "=================="

    analyze_directory "$HOME/pythons" "Main Python Directory"

    # Key Python subdirectories
    for subdir in apis data_processing file_operations media_processing tools llm config clean testing analysis archives content data documentation other projects seo_marketing websites; do
        if [ -d "$HOME/pythons/$subdir" ]; then
            analyze_directory "$HOME/pythons/$subdir" "Python /$subdir"
        fi
    done

    # AI WORKSPACE
    echo "🤖 AI WORKSPACE"
    echo "=============="

    analyze_directory "$HOME/workspace" "Workspace Directory"
    analyze_directory "$HOME/workspace/ai_cli_research" "AI CLI Research"

    # AI CONFIGURATIONS
    echo "🧠 AI CONFIGURATIONS"
    echo "==================="

    analyze_directory "$HOME/.claude" "Claude Desktop Config"
    analyze_directory "$HOME/.cursor" "Cursor IDE Config"
    analyze_directory "$HOME/.config/mcp" "MCP Configuration"

    # SCRIPTS
    echo "📜 SCRIPTS & AUTOMATION"
    echo "======================="

    analyze_directory "$HOME/scripts" "Scripts Directory"

    # HOME DIRECTORY CLUTTER
    echo "🏠 HOME DIRECTORY"
    echo "================"

    echo "Loose files in home directory:"
    find "$HOME" -maxdepth 1 -type f \( -name "*.py" -o -name "*.md" -o -name "*.txt" -o -name "*.json" -o -name "*.sh" \) 2>/dev/null | sort | while read -r file; do
        filename=$(basename "$file")
        size=$(stat -f%z "$file" 2>/dev/null || echo "N/A")
        echo "  📄 $filename (${size} bytes)"
    done

    # SUMMARY STATISTICS
    echo ""
    echo "📊 SUMMARY STATISTICS"
    echo "===================="

    total_python=$(safe_count "$HOME/pythons")
    total_ai_research=$(safe_count "$HOME/workspace/ai_cli_research")
    total_claude=$(safe_count "$HOME/.claude")
    total_cursor=$(safe_count "$HOME/.cursor")
    total_scripts=$(safe_count "$HOME/scripts")
    total_mcp=$(safe_count "$HOME/.config/mcp")
    total_home_loose=$(find "$HOME" -maxdepth 1 -type f \( -name "*.py" -o -name "*.md" -o -name "*.txt" -o -name "*.json" -o -name "*.sh" \) 2>/dev/null | wc -l)

    grand_total=$((total_python + total_ai_research + total_claude + total_cursor + total_scripts + total_mcp + total_home_loose))

    echo "🐍 Python files: $total_python"
    echo "🤖 AI research: $total_ai_research"
    echo "🧠 Claude config: $total_claude"
    echo "🖥️  Cursor config: $total_cursor"
    echo "📜 Scripts: $total_scripts"
    echo "🔗 MCP config: $total_mcp"
    echo "🏠 Home loose files: $total_home_loose"
    echo ""
    echo "🎯 GRAND TOTAL: $grand_total files"

    # FILE TYPE ANALYSIS
    echo ""
    echo "📋 FILE TYPE BREAKDOWN"
    echo "======================"

    find "$HOME/pythons" "$HOME/workspace/ai_cli_research" "$HOME/.claude" "$HOME/.cursor" "$HOME/scripts" "$HOME/.config/mcp" -type f 2>/dev/null | sed 's/.*\.//' | sort | uniq -c | sort -nr | head -20 | while read -r count ext; do
        echo ".$ext: $count files"
    done

    # LARGEST DIRECTORIES
    echo ""
    echo "📏 LARGEST DIRECTORIES"
    echo "======================"

    for dir in "$HOME/pythons" "$HOME/workspace/ai_cli_research" "$HOME/.claude" "$HOME/.cursor" "$HOME/scripts"; do
        if [ -d "$dir" ]; then
            size=$(dir_size "$dir")
            count=$(safe_count "$dir")
            dirname=$(basename "$dir")
            echo "$dirname/: $count files ($size)"
        fi
    done | sort -k2 -nr

} > "$INDEX_FILE"

status "Comprehensive index created: $INDEX_FILE"

# Show summary
echo ""
info "INDEX SUMMARY:"
echo "=============="

tail -20 "$INDEX_FILE" | head -10

echo ""
echo "📖 Full index available at: $INDEX_FILE"
echo ""
echo "Next steps:"
echo "1. Review the index to understand your ecosystem"
echo "2. Decide on consolidation strategy"
echo "3. Use index as reference during moves"
echo ""
status "Ready for informed reorganization! 🎯"