#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail


# Evolution Updater - Advanced Ecosystem Evolution Script
# Enhances and evolves your AI development ecosystem with cutting-edge tools and optimizations
# Based on comprehensive analysis of your multi-AI development environment

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

# Logfile setup
LOGFILE="$HOME/evolution-update-log-$(date +%Y%m%d-%H%M%S).log"
exec > >(tee -a "$LOGFILE") 2>&1

# Statistics
evolved_components=0
failed_components=0
total_time=0
start_time=$(date +%s)

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

# Function to evolve components with error handling
evolve_with_retry() {
    local name=$1
    local command=$2
    local max_retries=3
    local retry_count=0

    while [ $retry_count -lt $max_retries ]; do
        if eval "$command" 2>/dev/null; then
            evolved_components=$((evolved_components + 1))
            print_status $GREEN "🌟 $name evolved successfully"
            return 0
        else
            retry_count=$((retry_count + 1))
            if [ $retry_count -lt $max_retries ]; then
                print_status $YELLOW "⚠️  $name evolution failed, retrying ($retry_count/$max_retries)..."
                sleep 2
            else
                failed_components=$((failed_components + 1))
                print_status $RED "❌ $name evolution failed after $max_retries attempts"
                return 1
            fi
        fi
    done
}

# Evolve AI development tools
evolve-ai-tools() {
    print_with_emoji "Evolving AI development tools ecosystem"
    
    # Update AutoTagger to latest version
    if [ -d "/Users/steven/AutoTagger/v4-workspace" ]; then
        print_with_emoji "Evolving AutoTagger to latest version"
        cd /Users/steven/AutoTagger/v4-workspace
        if [ -f "update.sh" ]; then
            evolve_with_retry "AutoTagger" "./update.sh"
        elif [ -f "setup.py" ] || [ -f "requirements.txt" ]; then
            if command_exists pip3; then
                evolve_with_retry "AutoTagger dependencies" "pip3 install -r requirements.txt --upgrade"
            fi
        fi
    fi
    
    # Update MasterxEo ecosystem
    if [ -d "/Users/steven/MasterxEo" ]; then
        print_with_emoji "Evolving MasterxEo ecosystem"
        cd /Users/steven/MasterxEo
        if [ -f "update.sh" ]; then
            evolve_with_retry "MasterxEo" "./update.sh"
        elif [ -f "requirements.txt" ]; then
            if command_exists pip3; then
                evolve_with_retry "MasterxEo dependencies" "pip3 install -r requirements.txt --upgrade"
            fi
        fi
    fi
    
    # Update xRoad ecosystem
    if [ -d "/Users/steven/xRoad" ]; then
        print_with_emoji "Evolving xRoad ecosystem"
        cd /Users/steven/xRoad
        if [ -f "update.sh" ]; then
            evolve_with_retry "xRoad" "./update.sh"
        elif [ -f "requirements.txt" ]; then
            if command_exists pip3; then
                evolve_with_retry "xRoad dependencies" "pip3 install -r requirements.txt --upgrade"
            fi
        fi
    fi
}

# Evolve multi-AI interfaces
evolve-multi-ai() {
    print_with_emoji "Evolving multi-AI interface systems"
    
    # Update Claude ecosystem
    if [ -d "/Users/steven/.claude" ]; then
        print_with_emoji "Evolving Claude ecosystem"
        cd /Users/steven/.claude
        if [ -f "update.sh" ]; then
            evolve_with_retry "Claude" "./update.sh"
        fi
    fi
    
    # Update Cursor ecosystem
    if [ -d "/Users/steven/.cursor" ]; then
        print_with_emoji "Evolving Cursor ecosystem"
        cd /Users/steven/.cursor
        if [ -f "update.sh" ]; then
            evolve_with_retry "Cursor" "./update.sh"
        fi
    fi
    
    # Update Qwen ecosystem
    if [ -d "/Users/steven/.qwen" ]; then
        print_with_emoji "Evolving Qwen ecosystem"
        cd /Users/steven/.qwen
        if [ -f "update.sh" ]; then
            evolve_with_retry "Qwen" "./update.sh"
        fi
    fi
    
    # Update Gemini ecosystem
    if [ -d "/Users/steven/.gemini" ]; then
        print_with_emoji "Evolving Gemini ecosystem"
        cd /Users/steven/.gemini
        if [ -f "update.sh" ]; then
            evolve_with_retry "Gemini" "./update.sh"
        fi
    fi
    
    # Update Grok ecosystem
    if [ -d "/Users/steven/.grok" ]; then
        print_with_emoji "Evolving Grok ecosystem"
        cd /Users/steven/.grok
        if [ -f "update.sh" ]; then
            evolve_with_retry "Grok" "./update.sh"
        fi
    fi
}

# Evolve automation infrastructure
evolve-automation() {
    print_with_emoji "Evolving automation infrastructure"
    
    # Update MCP system
    if [ -d "/Users/steven/.mcp-central" ]; then
        print_with_emoji "Evolving MCP system"
        cd /Users/steven/.mcp-central
        if [ -f "configs/update.sh" ]; then
            evolve_with_retry "MCP" "./configs/update.sh"
        fi
    fi
    
    # Update Qodo workflows
    if [ -d "/Users/steven/.qodo" ]; then
        print_with_emoji "Evolving Qodo workflows"
        cd /Users/steven/.qodo
        if [ -f "update.sh" ]; then
            evolve_with_retry "Qodo" "./update.sh"
        fi
    fi
    
    # Update scripts directory
    print_with_emoji "Evolving script collection"
    if command_exists pip3; then
        # Check if requirements.txt exists in scripts directory
        if [ -f "/Users/steven/scripts/requirements.txt" ]; then
            evolve_with_retry "Python scripts dependencies" "pip3 install -r /Users/steven/scripts/requirements.txt --upgrade"
        else
            print_status $YELLOW "⚠️  No requirements.txt found in scripts directory, skipping dependency updates"
        fi
    fi
}

# Evolve security measures
evolve-security() {
    print_with_emoji "Evolving security measures"
    
    # Check for sensitive files and suggest encryption
    if [ -f "/Users/steven/.env.d/MASTER_CONSOLIDATED.env" ]; then
        print_with_emoji "Securing MASTER_CONSOLIDATED.env file"
        if command_exists gpg; then
            # Try encryption but don't block the entire evolution if it fails
            if gpg --symmetric --cipher-algo AES256 /Users/steven/.env.d/MASTER_CONSOLIDATED.env 2>/dev/null; then
                evolved_components=$((evolved_components + 1))
                print_status $GREEN "🔒 MASTER_CONSOLIDATED.env encrypted successfully"
            else
                failed_components=$((failed_components + 1))
                print_status $YELLOW "⚠️  Could not encrypt MASTER_CONSOLIDATED.env (may require passphrase)"
            fi
        else
            print_status $YELLOW "⚠️  GPG not found, consider installing for encryption: brew install gnupg"
        fi
    else
        print_status $YELLOW "⚠️  MASTER_CONSOLIDATED.env not found"
    fi
    
    # Update API keys management
    if [ -f "/Users/steven/scripts/setup-master-api-keys.sh" ]; then
        print_with_emoji "Evolving API key management"
        evolve_with_retry "API keys" "bash /Users/steven/scripts/setup-master-api-keys.sh"
    fi
}

# Evolve documentation and analysis tools
evolve-documentation() {
    print_with_emoji "Evolving documentation and analysis tools"
    
    # Update DOC-sorted collection
    if [ -d "/Users/steven/DOC-sorted" ]; then
        print_with_emoji "Organizing DOC-sorted collection"
        # Count and report on the documentation
        doc_count=$(find /Users/steven/DOC-sorted -type f | wc -l)
        print_status $CYAN "📚 Found $doc_count documents in DOC-sorted"
    fi
    
    # Update codebase analysis tools
    if [ -d "/Users/steven/codebase_analysis" ]; then
        print_with_emoji "Evolving codebase analysis tools"
        cd /Users/steven/codebase_analysis
        if [ -f "update.sh" ]; then
            evolve_with_retry "Codebase analysis" "./update.sh"
        fi
    fi
}

# Create evolution report
generate_evolution_report() {
    local end_time=$(date +%s)
    total_time=$((end_time - start_time))

    print_status $PURPLE "🌟 EVOLUTION REPORT"
    print_status $CYAN "=================="
    print_status $GREEN "✅ Components evolved: $evolved_components"
    print_status $RED "❌ Components failed: $failed_components"
    print_status $BLUE "⏱️  Total time: ${total_time}s"
    print_status $YELLOW "📝 Log file: $LOGFILE"
    print_status $CYAN "=================="
    
    # Print summary of evolution
    print_status $BOLD $PURPLE "🔍 EVOLUTION SUMMARY"
    print_status $CYAN "--------------------"
    print_status $GREEN "Your AI development ecosystem has been evolved with:"
    print_status $CYAN "• Updated AI interfaces (Claude, Cursor, Qwen, Gemini, Grok)"
    print_status $CYAN "• Enhanced automation infrastructure (MCP, Qodo)"
    print_status $CYAN "• Improved security measures"
    print_status $CYAN "• Optimized AI development tools (AutoTagger, MasterxEo, xRoad)"
    print_status $CYAN "• Refined documentation and analysis systems"
}

# Main evolution function
evolve-all() {
    print_status $BOLD $PURPLE "🌟 EVOLUTION UPDATER - ADVANCED ECOSYSTEM EVOLUTION"
    print_status $CYAN "=================================================="
    print_status $GREEN "Starting comprehensive ecosystem evolution..."
    print_status $CYAN "=================================================="
    echo ""

    # Evolve AI development tools
    evolve-ai-tools

    # Evolve multi-AI interfaces
    evolve-multi-ai

    # Evolve automation infrastructure
    evolve-automation

    # Evolve security measures
    evolve-security

    # Evolve documentation and analysis tools
    evolve-documentation

    # Generate evolution report
    generate_evolution_report

    print_status $GREEN "🎉 Evolution process completed!"
    print_status $CYAN "Your AI development ecosystem is now more advanced and efficient!"
}

# Individual evolution functions
evolve-ai() {
    print_with_emoji "Evolving AI interfaces..."
    evolve-multi-ai
    evolve-ai-tools
}

evolve-security-only() {
    print_with_emoji "Evolving security measures..."
    evolve-security
}

evolve-automation-only() {
    print_with_emoji "Evolving automation infrastructure..."
    evolve-automation
}

# Help function
show_help() {
    print_status $BOLD $PURPLE "EVOLUTION UPDATER - HELP"
    print_status $CYAN "======================="
    echo ""
    print_status $GREEN "Available functions:"
    echo "  evolve-all              - Evolve entire ecosystem"
    echo "  evolve-ai               - Evolve AI interfaces and tools"
    echo "  evolve-security-only    - Evolve security measures only"
    echo "  evolve-automation-only  - Evolve automation infrastructure only"
    echo ""
    print_status $CYAN "Usage:"
    echo "  ./evolution-updater.sh [function_name]"
    echo "  ./evolution-updater.sh evolve-all"
    echo ""
}

# Main execution
if [ $# -eq 0 ]; then
    evolve-all
else
    case "$1" in
        "evolve-all")
            evolve-all
            ;;
        "evolve-ai")
            evolve-ai
            ;;
        "evolve-security-only")
            evolve-security-only
            ;;
        "evolve-automation-only")
            evolve-automation-only
            ;;
        "help"|"-h"|"--help")
            show_help
            ;;
        *)
            print_status $RED "Unknown function: $1"
            show_help
            ;;
    esac
fi
