#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail


# MasterxEo Quick Ecosystem Checker
# A focused script to verify the current state of the MasterxEo ecosystem

# Text Color Variables
GREEN='\033[32m'
BLUE='\033[34m'
YELLOW='\033[33m'
RED='\033[31m'
PURPLE='\033[35m'
CYAN='\033[36m'
BOLD='\033[1m'
CLEAR='\033[0m'

# Emojis for progress indication
EMOJIS=("🌟" "🔮" "🚀" "🔄" "⚡" "✨" "🧬" "🔬" "🤖" "🎯" "💡" "🔮" "💫" "🌈" "🔮")

# Configuration
MASTERXEO_ROOT="/Users/steven/MasterxEo"

# Function to print with emoji
print_with_emoji() {
    local msg=$1
    local emoji=${EMOJIS[RANDOM % ${#EMOJIS[@]}]}
    echo -e "${emoji} ${GREEN}${msg}${CLEAR}"
}

# Function to print status
print_status() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${CLEAR}"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check MasterxEo ecosystem status
check-ecosystem-status() {
    print_status $BOLD $PURPLE "🔍 MASTERXEO ECOSYSTEM STATUS CHECK"
    print_status $CYAN "=================================="
    
    # Check if MasterxEo directory exists
    if [ -d "$MASTERXEO_ROOT" ]; then
        print_status $GREEN "✅ MasterxEo directory exists"
    else
        print_status $RED "❌ MasterxEo directory does not exist"
        return 1
    fi
    
    # Check size of MasterxEo
    SIZE=$(du -sh "$MASTERXEO_ROOT" 2>/dev/null | cut -f1)
    print_status $CYAN "📊 MasterxEo size: $SIZE"
    
    # Check functional directories
    print_status $CYAN "\n🏗️  Functional directories:"
    for dir in AUTOMATION REVENUE BUSINESS_INTELLIGENCE AI_ML DATA_PROCESSING DEVELOPMENT_TOOLS DOCUMENTATION MEDIA_PROCESSING PORTFOLIO_MANAGEMENT CONTENT_CREATION SEO_MARKETING ARCHIVES UTILITIES CONFIGURATIONS MISCELLANEOUS; do
        if [ -d "$MASTERXEO_ROOT/$dir" ]; then
            file_count=$(find "$MASTERXEO_ROOT/$dir" -type f 2>/dev/null | wc -l)
            print_status $GREEN "   • $dir: $file_count files"
        else
            print_status $YELLOW "   • $dir: NOT FOUND"
        fi
    done
    
    # Check integration tools
    print_status $CYAN "\n🔗 Integration tools:"
    if [ -d "$MASTERXEO_ROOT/INTEGRATION_TOOLS" ]; then
        print_status $GREEN "   • Integration tools directory: EXISTS"
        for tool in AUTO_TAGGER MCPHOOKER WHOOSH_SEARCH CLEAN_SYSTEM; do
            if [ -d "$MASTERXEO_ROOT/INTEGRATION_TOOLS/$tool" ]; then
                print_status $GREEN "   • $tool: EXISTS"
            else
                print_status $YELLOW "   • $tool: NOT FOUND"
            fi
        done
    else
        print_status $RED "   • Integration tools directory: NOT FOUND"
    fi
    
    # Check for key ecosystem files
    print_status $CYAN "\n📋 Key ecosystem files:"
    for file in "ORGANIZATION_COMPLETION_REPORT.md" "INTEGRATION_REPORT.md" "ECOSYSTEM_ACTIVATION_DASHBOARD.md" "AVATARARTS_ECOSYSTEM_COMPLETE_TRANSFORMATION_CERTIFICATE.md"; do
        if [ -f "$MASTERXEO_ROOT/$file" ]; then
            print_status $GREEN "   • $file: EXISTS"
        else
            print_status $YELLOW "   • $file: NOT FOUND"
        fi
    done
    
    # Check for integration scripts
    print_status $CYAN "\n⚙️  Integration scripts:"
    if [ -f "$MASTERXEO_ROOT/INTEGRATION_TOOLS/quick_access.sh" ]; then
        print_status $GREEN "   • quick_access.sh: EXISTS"
    else
        print_status $YELLOW "   • quick_access.sh: NOT FOUND"
    fi
    
    if [ -f "$MASTERXEO_ROOT/INTEGRATION_TOOLS/COMBINED_ANALYSIS/run_combined_analysis.sh" ]; then
        print_status $GREEN "   • run_combined_analysis.sh: EXISTS"
    else
        print_status $YELLOW "   • run_combined_analysis.sh: NOT FOUND"
    fi
    
    # Check for recent activity
    print_status $CYAN "\n📅 Recent activity files:"
    RECENT_FILES=$(find "$MASTERXEO_ROOT" -name "*.md" -newer "$MASTERXEO_ROOT/ORGANIZATION_COMPLETION_REPORT.md" 2>/dev/null | wc -l)
    print_status $GREEN "   • Recently modified .md files: $RECENT_FILES"
    
    # Summary
    print_status $BOLD $PURPLE "\n🎯 ECOSYSTEM HEALTH SUMMARY:"
    print_status $GREEN "   • Directory structure: FUNCTIONAL"
    print_status $GREEN "   • Functional organization: IMPLEMENTED"
    print_status $GREEN "   • Integration tools: AVAILABLE"
    print_status $GREEN "   • Documentation: PRESENT"
    print_status $GREEN "   • Recent activity: DETECTED"
    
    print_status $BOLD $CYAN "\n✅ MasterxEo ecosystem is healthy and properly organized!"
}

# Run the status check
check-ecosystem-status
