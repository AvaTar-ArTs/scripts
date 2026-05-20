#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail

# Quick Launcher for Intelligent Organization System
# Created: October 2025

DOCS_DIR="$HOME/Documents"
ANALYZER="$DOCS_DIR/analyze-scripts/unified_content_analyzer.py"
ORG_SYSTEM="$DOCS_DIR/intelligent_org_system.py"
AUTOMATION_MASTER="$DOCS_DIR/automation_master.py"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Print header
print_header() {
    echo -e "${BOLD}${MAGENTA}"
    echo "╔═══════════════════════════════════════════════════════════════════╗"
    echo "║  🚀 Intelligent Organization System for Creative Developers      ║"
    echo "║     Built from 6 hours of real cleanup (3.85 GB freed!)          ║"
    echo "╚═══════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

# Print menu
print_menu() {
    echo -e "${BOLD}Available Commands:${NC}\n"
    echo -e "${CYAN}Quick Commands:${NC}"
    echo -e "  ${GREEN}1${NC}) ${BOLD}doctor${NC}      - Full health check (Recommended first step!)"
    echo -e "  ${GREEN}2${NC}) ${BOLD}analyze${NC}     - Analyze code quality and structure"
    echo -e "  ${GREEN}3${NC}) ${BOLD}clean${NC}       - Find and remove duplicates/artifacts"
    echo -e "  ${GREEN}4${NC}) ${BOLD}organize${NC}    - Suggest intelligent organization"
    echo -e "  ${GREEN}5${NC}) ${BOLD}report${NC}      - Generate comprehensive report"
    echo ""
    echo -e "${CYAN}Individual Tools:${NC}"
    echo -e "  ${GREEN}6${NC}) ${BOLD}analyzer${NC}    - Run unified content analyzer only"
    echo -e "  ${GREEN}7${NC}) ${BOLD}org-system${NC}  - Run organization system only"
    echo ""
    echo -e "  ${RED}q${NC}) Quit"
    echo ""
}

# Check if tools exist
check_tools() {
    local missing=0

    if [[ ! -f "$ANALYZER" ]]; then
        echo -e "${RED}✗${NC} Missing: unified_content_analyzer.py"
        missing=1
    fi

    if [[ ! -f "$ORG_SYSTEM" ]]; then
        echo -e "${RED}✗${NC} Missing: intelligent_org_system.py"
        missing=1
    fi

    if [[ ! -f "$AUTOMATION_MASTER" ]]; then
        echo -e "${RED}✗${NC} Missing: automation_master.py"
        missing=1
    fi

    if [[ $missing -eq 1 ]]; then
        echo -e "\n${RED}Error: Required tools not found in ~/Documents/${NC}"
        exit 1
    fi

    echo -e "${GREEN}✓${NC} All tools found!"
}

# Get project path
get_project_path() {
    echo -e "\n${BOLD}Enter project path:${NC}"
    echo -e "${YELLOW}(Default: ~/pythons)${NC}"
    read -r project_path

    if [[ -z "$project_path" ]]; then
        project_path="$HOME/pythons"
    fi

    # Expand ~ to home directory
    project_path="${project_path/#\~/$HOME}"

    if [[ ! -d "$project_path" ]]; then
        echo -e "${RED}✗ Directory not found: $project_path${NC}"
        return 1
    fi

    echo -e "${GREEN}✓${NC} Project: $project_path"
    return 0
}

# Run command
run_command() {
    local cmd=$1
    local project_path=$2

    case $cmd in
        doctor|analyze|clean|organize|report)
            echo -e "\n${CYAN}Running: automation_master.py $cmd${NC}\n"
            python3 "$AUTOMATION_MASTER" "$cmd" "$project_path"
            ;;
        analyzer)
            echo -e "\n${CYAN}Running: unified_content_analyzer.py${NC}\n"
            python3 "$ANALYZER" "$project_path" --pretty
            ;;
        org-system)
            echo -e "\n${CYAN}Running: intelligent_org_system.py analyze${NC}\n"
            python3 "$ORG_SYSTEM" analyze "$project_path"
            ;;
        *)
            echo -e "${RED}Unknown command: $cmd${NC}"
            return 1
            ;;
    esac

    echo -e "\n${GREEN}✓ Command completed${NC}"
}

# Main menu loop
main_menu() {
    while true; do
        echo ""
        print_menu
        echo -n "Select option: "
        read -r choice

        case $choice in
            1)
                if get_project_path; then
                    run_command "doctor" "$project_path"
                fi
                ;;
            2)
                if get_project_path; then
                    run_command "analyze" "$project_path"
                fi
                ;;
            3)
                if get_project_path; then
                    echo -e "\n${YELLOW}⚠️  This will run in DRY RUN mode (no changes)${NC}"
                    run_command "clean" "$project_path"
                fi
                ;;
            4)
                if get_project_path; then
                    run_command "organize" "$project_path"
                fi
                ;;
            5)
                if get_project_path; then
                    echo -e "\n${BOLD}Enter output filename (or press Enter for default):${NC}"
                    read -r output_file
                    if [[ -n "$output_file" ]]; then
                        python3 "$AUTOMATION_MASTER" report "$project_path" -o "$output_file"
                    else
                        run_command "report" "$project_path"
                    fi
                fi
                ;;
            6)
                if get_project_path; then
                    run_command "analyzer" "$project_path"
                fi
                ;;
            7)
                if get_project_path; then
                    run_command "org-system" "$project_path"
                fi
                ;;
            q|Q)
                echo -e "\n${GREEN}Thanks for using the Intelligent Organization System!${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}Invalid option. Please try again.${NC}"
                ;;
        esac

        echo -e "\n${YELLOW}Press Enter to continue...${NC}"
        read -r
    done
}

# Main execution
clear
print_header

echo -e "${BOLD}Checking tools...${NC}"
check_tools

echo -e "\n${GREEN}Ready to organize your code!${NC}"
echo -e "${YELLOW}Tip: Start with option 1 (doctor) for a full health check${NC}"

main_menu
