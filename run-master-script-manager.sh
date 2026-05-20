#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail


################################################################################
# Master Script Manager for Steven's Automation System
#
# This script provides a centralized interface to manage all automation scripts
# in the system. It includes:
# - Script discovery and categorization
# - Execution management
# - Status reporting
# - Health checks
# - Maintenance operations
################################################################################

set -E
trap cleanup SIGINT SIGTERM ERR EXIT

cleanup() {
    trap - SIGINT SIGTERM ERR EXIT
}

# Color setup
setup_colors() {
    if [[ -t 2 ]] && [[ -z "${NO_COLOR-}" ]] && [[ "${TERM-}" != "dumb" ]]; then
        NOFORMAT='\033[0m' RED='\033[0;31m' GREEN='\033[0;32m' ORANGE='\033[0;33m' BLUE='\033[0;34m' PURPLE='\033[0;35m' CYAN='\033[0;36m' YELLOW='\033[1;33m'
    else
        NOFORMAT='' RED='' GREEN='' ORANGE='' BLUE='' PURPLE='' CYAN='' YELLOW=''
    fi
}

msg() {
    echo >&2 -e "${1-}"
}

die() {
    local msg=$1
    local code=${2-1}
    msg "$msg"
    exit "$code"
}

prompt_yes_no() {
    local question=$1
    local response
    while true; do
        read -p "${question} (y/n) " -n 1 -r response
        echo
        case $response in
            [yY]) return 0 ;;
            [nN]) return 1 ;;
            *) echo "Please answer y or n" ;;
        esac
    done
}

parse_params() {
    action="menu"
    verbose=false
    dry_run=false
    script_name=""

    while :; do
        case "${1-}" in
        -h | --help) usage ;;
        -v | --verbose) verbose=true ;;
        --dry-run) dry_run=true ;;
        --action) 
            shift
            if [[ -n "${1-}" ]]; then
                action="${1-}"
            fi
            ;;
        --script)
            shift
            if [[ -n "${1-}" ]]; then
                script_name="${1-}"
            fi
            ;;
        -?*) die "Unknown option: $1" ;;
        *) break ;;
        esac
        shift
    done
}

usage() {
    cat <<EOF
Usage: $(basename "${BASH_SOURCE[0]}") [options]

Master Script Manager - Manage all automation scripts in the system

OPTIONS:
  -h, --help             Show this help
  -v, --verbose          Verbose output
  --dry-run              Show what would be executed without running
  --action ACTION        Action to perform: menu, list, run, health, maintenance
  --script NAME          Specific script to run (with run action)

ACTIONS:
  menu         - Interactive menu (default)
  list         - List all available scripts
  run          - Run a specific script
  health       - Perform system health check
  maintenance  - Run system maintenance

EXAMPLES:
  $(basename "${BASH_SOURCE[0]}")                    # Show interactive menu
  $(basename "${BASH_SOURCE[0]}") --action list      # List all scripts
  $(basename "${BASH_SOURCE[0]}") --action run --script cleanup  # Run cleanup script
  $(basename "${BASH_SOURCE[0]}") --action health    # Check system health

EOF
    exit 0
}

discover_scripts() {
    msg "${GREEN}🔍 Discovering scripts...${NOFORMAT}"

    # Define script categories and patterns using separate variables
    cleanup_script="/Users/steven/scripts/consolidated_cleanup.sh"
    update_script="/Users/steven/scripts/consolidated_update.sh"
    encrypt_script="/Users/steven/scripts/enhanced_encrypt_sensitive_env_files.sh"

    # Print discovered scripts
    msg "${CYAN}Discovered Scripts:${NOFORMAT}"
    printf "  %-20s %s\n" "cleanup:" "$cleanup_script"
    printf "  %-20s %s\n" "update:" "$update_script"
    printf "  %-20s %s\n" "encrypt:" "$encrypt_script"

    # Look for other scripts in the sh directory (first 10 for demo)
    msg "${CYAN}Other SH Scripts:${NOFORMAT}"
    count=0
    for script in /Users/steven/scripts/sh/*.sh; do
        if [[ -f "$script" && -r "$script" && $count -lt 5 ]]; then
            script_name=$(basename "$script" .sh)
            printf "  %-20s %s\n" "$script_name:" "$script"
            ((count++))
        fi
    done

    # Look for Python scripts
    msg "${CYAN}Python Scripts:${NOFORMAT}"
    count=0
    for script in /Users/steven/scripts/*.py; do
        if [[ -f "$script" && -r "$script" && $count -lt 5 ]]; then
            script_name=$(basename "$script" .py)
            printf "  %-20s %s\n" "$script_name:" "$script"
            ((count++))
        fi
    done
}

run_health_check() {
    msg "${GREEN}[Health Check] Running system diagnostics...${NOFORMAT}"
    
    # Check disk space
    available_space=$(df -h / | awk 'NR==2 {print $4}')
    space_gb=$(echo $available_space | sed 's/G//' | sed 's/[A-Za-z]*//g')
    
    msg "  Disk space: $available_space"
    if (( $(echo "$space_gb < 10" | bc -l) )); then
        msg "  ${RED}⚠️  Low disk space (< 10GB)${NOFORMAT}"
    else
        msg "  ${GREEN}✓ Sufficient disk space${NOFORMAT}"
    fi
    
    # Check for running processes that might interfere
    msg "  Checking for long-running processes..."
    long_processes=$(ps aux | awk '$10 ~ /^[DRSTtWXZ]/ && $11 !~ /ps|awk/ {print $11}' | head -5)
    if [ -n "$long_processes" ]; then
        msg "  ${YELLOW}ℹ️  Long-running processes found${NOFORMAT}"
    else
        msg "  ${GREEN}✓ No concerning processes${NOFORMAT}"
    fi
    
    # Check script permissions
    msg "  Checking script permissions..."
    if [ -x "/Users/steven/scripts/consolidated_cleanup.sh" ]; then
        msg "  ${GREEN}✓ Cleanup script executable${NOFORMAT}"
    else
        msg "  ${RED}❌ Cleanup script not executable${NOFORMAT}"
    fi
    
    if [ -x "/Users/steven/scripts/consolidated_update.sh" ]; then
        msg "  ${GREEN}✓ Update script executable${NOFORMAT}"
    else
        msg "  ${RED}❌ Update script not executable${NOFORMAT}"
    fi
    
    msg "${GREEN}✓ Health check completed${NOFORMAT}"
}

run_maintenance() {
    msg "${GREEN}[Maintenance] Running system maintenance...${NOFORMAT}"
    
    msg "  Running consolidated cleanup..."
    if [[ "$dry_run" == false ]]; then
        /Users/steven/scripts/consolidated_cleanup.sh --force
    else
        msg "  Would run: /Users/steven/scripts/consolidated_cleanup.sh --force"
    fi
    
    msg "  Running consolidated update..."
    if [[ "$dry_run" == false ]]; then
        /Users/steven/scripts/consolidated_update.sh --force
    else
        msg "  Would run: /Users/steven/scripts/consolidated_update.sh --force"
    fi
    
    msg "${GREEN}✓ Maintenance completed${NOFORMAT}"
}

run_specific_script() {
    if [[ -z "$script_name" ]]; then
        die "${RED}❌ No script name provided. Use --script option.${NOFORMAT}"
    fi
    
    case "$script_name" in
        "cleanup")
            msg "${GREEN}Running consolidated cleanup...${NOFORMAT}"
            if [[ "$dry_run" == false ]]; then
                /Users/steven/scripts/consolidated_cleanup.sh
            else
                msg "Would run: /Users/steven/scripts/consolidated_cleanup.sh"
            fi
            ;;
        "update")
            msg "${GREEN}Running consolidated update...${NOFORMAT}"
            if [[ "$dry_run" == false ]]; then
                /Users/steven/scripts/consolidated_update.sh
            else
                msg "Would run: /Users/steven/scripts/consolidated_update.sh"
            fi
            ;;
        "encrypt")
            msg "${GREEN}Running enhanced encryption...${NOFORMAT}"
            if [[ "$dry_run" == false ]]; then
                /Users/steven/scripts/enhanced_encrypt_sensitive_env_files.sh
            else
                msg "Would run: /Users/steven/scripts/enhanced_encrypt_sensitive_env_files.sh"
            fi
            ;;
        *)
            msg "${RED}❌ Unknown script: $script_name${NOFORMAT}"
            msg "${CYAN}Available scripts: cleanup, update, encrypt${NOFORMAT}"
            ;;
    esac
}

show_menu() {
    while true; do
        clear
        msg "${BLUE}╔══════════════════════════════════════════════════════════════╗${NOFORMAT}"
        msg "${BLUE}║                   Master Script Manager                      ║${NOFORMAT}"
        msg "${BLUE}╚══════════════════════════════════════════════════════════════╝${NOFORMAT}"
        msg ""
        msg "${CYAN}Select an option:${NOFORMAT}"
        msg "  1) Run Consolidated Cleanup"
        msg "  2) Run Consolidated Update" 
        msg "  3) Run Enhanced Encryption"
        msg "  4) List All Scripts"
        msg "  5) System Health Check"
        msg "  6) System Maintenance"
        msg "  7) Exit"
        msg ""
        
        read -p "Enter your choice (1-7): " choice
        echo
        
        case $choice in
            1)
                msg "${GREEN}Running Consolidated Cleanup...${NOFORMAT}"
                /Users/steven/scripts/consolidated_cleanup.sh
                read -p "Press Enter to continue..."
                ;;
            2)
                msg "${GREEN}Running Consolidated Update...${NOFORMAT}"
                /Users/steven/scripts/consolidated_update.sh
                read -p "Press Enter to continue..."
                ;;
            3)
                msg "${GREEN}Running Enhanced Encryption...${NOFORMAT}"
                /Users/steven/scripts/enhanced_encrypt_sensitive_env_files.sh
                read -p "Press Enter to continue..."
                ;;
            4)
                discover_scripts
                read -p "Press Enter to continue..."
                ;;
            5)
                run_health_check
                read -p "Press Enter to continue..."
                ;;
            6)
                run_maintenance
                read -p "Press Enter to continue..."
                ;;
            7)
                msg "${GREEN}Goodbye!${NOFORMAT}"
                exit 0
                ;;
            *)
                msg "${RED}Invalid option. Please try again.${NOFORMAT}"
                sleep 2
                ;;
        esac
    done
}

parse_params "$@"
setup_colors

msg "${BLUE}=== Master Script Manager for Steven's Automation System ===${NOFORMAT}"
msg ""

case "$action" in
    "menu")
        show_menu
        ;;
    "list")
        discover_scripts
        ;;
    "health")
        run_health_check
        ;;
    "maintenance")
        run_maintenance
        ;;
    "run")
        run_specific_script
        ;;
    *)
        msg "${RED}❌ Unknown action: $action${NOFORMAT}"
        usage
        ;;
esac

msg ""
msg "${GREEN}✅ Operation completed${NOFORMAT}"
msg ""

cleanup
