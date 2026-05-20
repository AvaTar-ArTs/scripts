#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail

# Quick Analysis Utility Script
# Provides shortcuts for common analysis tasks

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ANALYZER="$SCRIPT_DIR/fluid_adaptive_analyzer.py"
MULTI_ANALYZER="$SCRIPT_DIR/analyze_multiple_dirs.py"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_header() {
    echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║   🔍 Quick Analysis Utility            ║${NC}"
    echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
    echo ""
}

print_usage() {
    echo "Usage: analysis_launcher.sh [command] [path]"
    echo ""
    echo "Commands:"
    echo "  file <path>        - Analyze single file (adaptive)"
    echo "  dir <path>         - Analyze directory (adaptive)"
    echo "  quick <path>       - Quick analysis"
    echo "  deep <path>        - Deep analysis"
    echo "  all                - Analyze all configured directories"
    echo "  python             - Analyze ~/pythons"
    echo "  scripts            - Analyze ~/Documents/analyze-scripts"
    echo "  sites              - Analyze ~/ai-sites"
    echo "  current            - Analyze current directory"
    echo "  git-changed        - Analyze git changed files"
    echo ""
    echo "Examples:"
    echo "  analysis_launcher.sh file script.py"
    echo "  analysis_launcher.sh deep ~/projects/api"
    echo "  analysis_launcher.sh all"
    echo "  analysis_launcher.sh current"
}

analyze_file() {
    local file="$1"
    local strategy="${2:-adaptive}"

    echo -e "${GREEN}Analyzing file: $file${NC}"
    echo -e "${YELLOW}Strategy: $strategy${NC}"
    echo ""

    python3 "$ANALYZER" "$file" "$strategy"
}

analyze_directory() {
    local dir="$1"
    local strategy="${2:-adaptive}"

    echo -e "${GREEN}Analyzing directory: $dir${NC}"
    echo -e "${YELLOW}Strategy: $strategy${NC}"
    echo ""

    python3 "$ANALYZER" "$dir" "$strategy"
}

analyze_all() {
    echo -e "${GREEN}Analyzing all configured directories...${NC}"
    echo ""
    python3 "$MULTI_ANALYZER"
}

analyze_git_changed() {
    echo -e "${GREEN}Analyzing git changed files...${NC}"
    echo ""

    # Get changed files
    changed_files=$(git diff --name-only 2>/dev/null)

    if [ -z "$changed_files" ]; then
        echo -e "${YELLOW}No changed files found${NC}"
        return 1
    fi

    echo "Changed files:"
    echo "$changed_files"
    echo ""

    # Analyze each changed file
    while IFS= read -r file; do
        if [ -f "$file" ]; then
            echo -e "${BLUE}Analyzing: $file${NC}"
            python3 "$ANALYZER" "$file" quick
            echo ""
        fi
    done <<< "$changed_files"
}

# Main script
print_header

case "$1" in
    file)
        if [ -z "$2" ]; then
            echo -e "${RED}Error: No file specified${NC}"
            print_usage
            exit 1
        fi
        analyze_file "$2" "${3:-adaptive}"
        ;;

    dir)
        if [ -z "$2" ]; then
            echo -e "${RED}Error: No directory specified${NC}"
            print_usage
            exit 1
        fi
        analyze_directory "$2" "${3:-adaptive}"
        ;;

    quick)
        if [ -z "$2" ]; then
            echo -e "${RED}Error: No path specified${NC}"
            print_usage
            exit 1
        fi
        if [ -f "$2" ]; then
            analyze_file "$2" quick
        else
            analyze_directory "$2" quick
        fi
        ;;

    deep)
        if [ -z "$2" ]; then
            echo -e "${RED}Error: No path specified${NC}"
            print_usage
            exit 1
        fi
        if [ -f "$2" ]; then
            analyze_file "$2" deep
        else
            analyze_directory "$2" deep
        fi
        ;;

    all)
        analyze_all
        ;;

    python)
        analyze_directory "$HOME/pythons" adaptive
        ;;

    scripts)
        analyze_directory "$HOME/Documents/analyze-scripts" adaptive
        ;;

    sites)
        analyze_directory "$HOME/ai-sites" adaptive
        ;;

    current)
        analyze_directory "$(pwd)" adaptive
        ;;

    git-changed)
        analyze_git_changed
        ;;

    help|--help|-h)
        print_usage
        ;;

    *)
        echo -e "${RED}Error: Unknown command '$1'${NC}"
        echo ""
        print_usage
        exit 1
        ;;
esac

echo ""
echo -e "${GREEN}✅ Analysis complete!${NC}"
