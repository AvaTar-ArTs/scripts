#!/bin/zsh
set -euo pipefail

# Advanced System Maintenance Pro v3 - Comprehensive Ecosystem Management
# Designed for complex AI/automation environments like AVATARARTS, Harbor, IntelliHub
# Combines system maintenance, ecosystem management, and specialized tool maintenance

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
EMOJIS=("🚀" "⏳" "🔄" "📦" "✅" "🔧" "⚡" "🎯" "🧹" "💾" "🌐" "🤖" "🧠" "🛠️" "📈")

# Logfile setup
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
LOGDIR="${HOME}/logs"
LOGFILE="${LOGDIR}/advanced-maintenance-v3-log-${TIMESTAMP}.log"

# Create log directory if it doesn't exist
mkdir -p "${LOGDIR}" 2>/dev/null || echo "Warning: Could not create log directory: ${LOGDIR}"

# Redirect output to both terminal and log file
exec > >(tee -a "$LOGFILE") 2>&1

# Statistics
packages_updated=0
packages_failed=0
operations_completed=0
operations_failed=0
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

# Function to update packages with error handling
update_with_retry() {
    local name=$1
    local command=$2
    local max_retries=3
    local retry_count=0

    while [ $retry_count -lt $max_retries ]; do
        if eval "$command" 2>/dev/null; then
            packages_updated=$((packages_updated + 1))
            print_status $GREEN "✅ $name updated successfully"
            return 0
        else
            retry_count=$((retry_count + 1))
            if [ $retry_count -lt $max_retries ]; then
                print_status $YELLOW "⚠️  $name failed, retrying ($retry_count/$max_retries)..."
                sleep 2
            else
                packages_failed=$((packages_failed + 1))
                print_status $RED "❌ $name failed after $max_retries attempts"
                return 1
            fi
        fi
    done
}

# Function to safely remove directories with size calculation
safe_remove_dir() {
    local dir="$1"
    if [[ -d "$dir" ]]; then
        local size=$(du -sh "$dir" 2>/dev/null | cut -f1)
        if [[ -n "$size" ]]; then
            print_status $CYAN "      Clearing $dir ($size)..."
        else
            print_status $CYAN "      Clearing $dir..."
        fi
        rm -rf "$dir"/* 2>/dev/null || {
            print_status $YELLOW "      ⚠️  Could not fully clear $dir (permissions issue)"
            return 1
        }
        return 0
    fi
    return 1
}

# Function to safely remove files/directories with size calculation
safe_remove_path() {
    local path="$1"
    if [[ -e "$path" ]] || [[ -d "$path" ]]; then
        local size=$(du -sh "$path" 2>/dev/null | cut -f1)
        if [[ -n "$size" ]]; then
            print_status $CYAN "      Removing $path ($size)..."
        else
            print_status $CYAN "      Removing $path..."
        fi
        rm -rf "$path" 2>/dev/null || {
            print_status $YELLOW "      ⚠️  Could not remove $path (permissions issue)"
            return 1
        }
        return 0
    fi
    return 1
}

# Function to convert bytes to human readable format
bytesToHuman() {
    b=${1:-0}
    d=''
    s=1
    S=(Bytes {K,M,G,T,E,P,Y,Z}iB)
    while ((b > 1024)); do
        d="$(printf ".%02d" $((b % 1024 * 100 / 1024)))"
        b=$((b / 1024))
        ((s++))
    done
    echo "$b$d ${S[$s]}"
}

# Function to prompt yes/no
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

# Function to check disk space
check_disk_space() {
    local path=${1:-"/"}
    local space_info=$(df -h "$path" | tail -1)
    local used=$(echo "$space_info" | awk '{print $5}')
    local available=$(echo "$space_info" | awk '{print $4}')
    print_status $CYAN "      Disk space for $path: $used used, $available available"
}

# Fix permissions
print_with_emoji "Fixing directory permissions"
chmod o-w /Users/steven

# AVATARARTS Ecosystem Maintenance
maintain-avatararts() {
    print_with_emoji "Maintaining AVATARARTS Ecosystem [1/12]"
    
    if [[ -d "$HOME/AVATARARTS" ]]; then
        print_status $CYAN "      Checking AVATARARTS ecosystem..."
        check_disk_space "$HOME/AVATARARTS"
        
        # Look for any temporary or cache files in AVATARARTS
        find "$HOME/AVATARARTS" -name "*.tmp" -type f -delete 2>/dev/null
        find "$HOME/AVATARARTS" -name "*.log" -type f -mtime +7 -delete 2>/dev/null
        find "$HOME/AVATARARTS" -name "__pycache__" -type d -exec rm -rf {} + 2>/dev/null
        
        print_status $GREEN "      ✓ AVATARARTS ecosystem maintenance completed"
        operations_completed=$((operations_completed + 1))
    else
        print_status $YELLOW "      ⚠️  AVATARARTS directory not found"
        operations_failed=$((operations_failed + 1))
    fi
}

# Harbor Ecosystem Maintenance
maintain-harbor() {
    print_with_emoji "Maintaining Harbor Ecosystem [2/12]"
    
    if [[ -d "$HOME/.harbor" ]]; then
        print_status $CYAN "      Checking Harbor ecosystem..."
        check_disk_space "$HOME/.harbor"
        
        # Clean Harbor cache directories
        for harbor_dir in "$HOME/.harbor"/*/; do
            if [[ -d "$harbor_dir" ]]; then
                local dir_name=$(basename "$harbor_dir")
                print_status $CYAN "      Cleaning Harbor component: $dir_name"
                
                # Remove temporary files
                find "$harbor_dir" -name "*.tmp" -type f -delete 2>/dev/null
                find "$harbor_dir" -name "*.log" -type f -mtime +7 -delete 2>/dev/null
                find "$harbor_dir" -name "__pycache__" -type d -exec rm -rf {} + 2>/dev/null
            fi
        done
        
        print_status $GREEN "      ✓ Harbor ecosystem maintenance completed"
        operations_completed=$((operations_completed + 1))
    else
        print_status $YELLOW "      ⚠️  Harbor directory not found"
        operations_failed=$((operations_failed + 1))
    fi
}

# IntelliHub Maintenance
maintain-intellihub() {
    print_with_emoji "Maintaining IntelliHub Ecosystem [3/12]"
    
    if [[ -d "$HOME/IntelliHub" ]]; then
        print_status $CYAN "      Checking IntelliHub ecosystem..."
        check_disk_space "$HOME/IntelliHub"
        
        # Clean IntelliHub cache and temporary files
        find "$HOME/IntelliHub" -name "*.tmp" -type f -delete 2>/dev/null
        find "$HOME/IntelliHub" -name "*.log" -type f -mtime +7 -delete 2>/dev/null
        find "$HOME/IntelliHub" -name "__pycache__" -type d -exec rm -rf {} + 2>/dev/null
        
        print_status $GREEN "      ✓ IntelliHub ecosystem maintenance completed"
        operations_completed=$((operations_completed + 1))
    else
        print_status $YELLOW "      ⚠️  IntelliHub directory not found"
        operations_failed=$((operations_failed + 1))
    fi
}

# Python Environments Maintenance
maintain-python-envs() {
    print_with_emoji "Maintaining Python Environments [4/12]"
    
    # Check for various Python environment directories
    local py_envs=(
        "$HOME/pythons"
        "$HOME/.virtualenvs"
        "$HOME/.venv"
        "$HOME/aider-env"
    )
    
    for env_dir in "${py_envs[@]}"; do
        if [[ -d "$env_dir" ]]; then
            print_status $CYAN "      Checking Python environment: $env_dir"
            check_disk_space "$env_dir"
            
            # Clean Python cache files
            find "$env_dir" -name "__pycache__" -type d -exec rm -rf {} + 2>/dev/null
            find "$env_dir" -name "*.pyc" -type f -delete 2>/dev/null
            find "$env_dir" -name "*.pyo" -type f -delete 2>/dev/null
        fi
    done
    
    print_status $GREEN "      ✓ Python environments maintenance completed"
    operations_completed=$((operations_completed + 1))
}

# AI/ML Tools Maintenance (Claude, Grok, Aider, etc.)
maintain-ai-tools() {
    print_with_emoji "Maintaining AI/ML Tools [5/12]"
    
    local ai_dirs=(
        "$HOME/.claude"
        "$HOME/.grok"
        "$HOME/.aider"
        "$HOME/.cursor"
        "$HOME/.chatgpt"
        "$HOME/.gemini"
        "$HOME/.notebooklm"
        "$HOME/.claude-conversations"
    )
    
    for ai_dir in "${ai_dirs[@]}"; do
        if [[ -d "$ai_dir" ]]; then
            print_status $CYAN "      Checking AI tool directory: $ai_dir"
            check_disk_space "$ai_dir"
            
            # Clean temporary and cache files
            find "$ai_dir" -name "*.tmp" -type f -delete 2>/dev/null
            find "$ai_dir" -name "*.log" -type f -mtime +7 -delete 2>/dev/null
            find "$ai_dir" -name "__pycache__" -type d -exec rm -rf {} + 2>/dev/null
        fi
    done
    
    print_status $GREEN "      ✓ AI/ML tools maintenance completed"
    operations_completed=$((operations_completed + 1))
}

# Development Tools Maintenance
maintain-dev-tools() {
    print_with_emoji "Maintaining Development Tools [6/12]"
    
    # Clean npm cache
    if command_exists npm; then
        print_status $CYAN "      Cleaning npm cache..."
        npm cache clean --force 2>/dev/null
        print_status $GREEN "      ✓ npm cache cleaned"
    fi
    
    # Clean yarn cache
    if command_exists yarn; then
        print_status $CYAN "      Cleaning yarn cache..."
        yarn cache clean 2>/dev/null
        print_status $GREEN "      ✓ yarn cache cleaned"
    fi
    
    # Clean pip cache
    if command_exists pip3; then
        print_status $CYAN "      Cleaning pip cache..."
        pip3 cache purge 2>/dev/null
        print_status $GREEN "      ✓ pip cache cleaned"
    fi
    
    # Clean Docker cache if available
    if command_exists docker; then
        print_status $CYAN "      Checking Docker system..."
        if prompt_yes_no "      Prune Docker system? (removes unused containers, images, etc.)"; then
            docker system prune -f 2>/dev/null
            docker builder prune -f 2>/dev/null
            print_status $GREEN "      ✓ Docker system pruned"
        else
            print_status $YELLOW "      ⊘ Skipping Docker pruning"
        fi
    fi
    
    print_status $GREEN "      ✓ Development tools maintenance completed"
    operations_completed=$((operations_completed + 1))
}

# Homebrew updates and cleanup
update-brew() {
    if ! command_exists brew; then
        print_status $YELLOW "⚠️  Homebrew not found, skipping..."
        operations_failed=$((operations_failed + 1))
        return
    fi

    print_with_emoji "Updating Homebrew [7/12]"
    update_with_retry "Homebrew" "brew update && brew upgrade && brew cleanup"

    # Update cask applications
    print_with_emoji "Updating Cask applications"
    update_with_retry "Cask apps" "brew upgrade --cask"

    # Clean up old versions
    print_with_emoji "Cleaning up old Homebrew versions"
    brew cleanup --prune=all 2>/dev/null
    
    # Clean Homebrew cache specifically
    local brew_cache=$(brew --cache)
    if [[ -d "$brew_cache" ]]; then
        print_with_emoji "Clearing Homebrew cache"
        rm -rf "$brew_cache"/* 2>/dev/null || print_status $YELLOW "      ⚠️  Some Homebrew cache files could not be removed"
    fi
    
    operations_completed=$((operations_completed + 1))
}

# Conda/Mamba updates and cleanup
update-conda() {
    if command_exists mamba; then
        print_with_emoji "Updating Mamba (faster conda replacement) [8/12]"
        update_with_retry "Mamba" "mamba update mamba"
        
        print_with_emoji "Updating Mamba packages (faster than conda)"
        update_with_retry "Mamba packages" "mamba update --all"
        
        print_with_emoji "Cleaning Mamba cache"
        mamba clean --all -y 2>/dev/null
        operations_completed=$((operations_completed + 1))
    elif command_exists conda; then
        print_with_emoji "Updating Conda [8/12]"
        update_with_retry "Conda" "conda update conda"

        print_with_emoji "Updating Conda packages"
        update_with_retry "Conda packages" "conda update --all"

        print_with_emoji "Cleaning Conda cache"
        conda clean --all -y 2>/dev/null
        operations_completed=$((operations_completed + 1))
    else
        print_status $YELLOW "⚠️  Neither Mamba nor Conda found, skipping [8/12]"
        operations_failed=$((operations_failed + 1))
        return
    fi
}

# System cache clearing
clear-system-caches() {
    print_with_emoji "Clearing System Caches [9/12]"

    # User Caches (safe - rebuilds)
    if [[ -d ~/Library/Caches ]]; then
        local cache_size=$(du -sh ~/Library/Caches 2>/dev/null | awk '{print $1}')
        if [[ -n "$cache_size" ]]; then
            print_status $CYAN "      Clearing ~/Library/Caches (${cache_size})..."
        else
            print_status $CYAN "      Clearing ~/Library/Caches..."
        fi
        rm -rf ~/Library/Caches/* 2>/dev/null || print_status $YELLOW "      ⚠️  Some cache files could not be removed"
    fi

    # System temp files (safe)
    print_status $CYAN "      Clearing temporary files..."
    rm -rf /var/tmp/* 2>/dev/null || true
    rm -rf /tmp/* 2>/dev/null || true

    print_status $GREEN "      ✓ System caches cleared"
    operations_completed=$((operations_completed + 1))
}

# Large Directories Analysis and Cleanup
analyze-large-dirs() {
    print_with_emoji "Analyzing Large Directories [10/12]"
    
    print_status $CYAN "      Top 10 largest directories in home:"
    du -h -d 1 ~ 2>/dev/null | sort -hr | head -10
    
    print_status $CYAN "      Top 5 largest directories in Downloads:"
    if [[ -d ~/Downloads ]]; then
        du -h -d 1 ~/Downloads 2>/dev/null | sort -hr | head -5
    fi
    
    print_status $GREEN "      ✓ Large directories analysis completed"
    operations_completed=$((operations_completed + 1))
}

# Environment Configuration Maintenance
maintain-env-configs() {
    print_with_emoji "Maintaining Environment Configurations [11/12]"
    
    # Check and backup important config files
    local config_files=(
        "$HOME/.zshrc"
        "$HOME/.bashrc" 
        "$HOME/.bash_profile"
        "$HOME/.env.d"
        "$HOME/.config"
    )
    
    for config_file in "${config_files[@]}"; do
        if [[ -e "$config_file" ]]; then
            print_status $CYAN "      Checking config: $config_file"
            if [[ -d "$config_file" ]]; then
                check_disk_space "$config_file"
            else
                local size=$(du -sh "$config_file" 2>/dev/null | cut -f1)
                print_status $CYAN "      Size: $size"
            fi
        fi
    done
    
    print_status $GREEN "      ✓ Environment configurations checked"
    operations_completed=$((operations_completed + 1))
}

# Comprehensive Cleanup
comprehensive-cleanup() {
    print_with_emoji "Comprehensive Cleanup [12/12]"
    
    # Clean various temporary locations
    local temp_locations=(
        "$HOME/.cache"
        "$HOME/.npm/_cacache"
        "$HOME/.mypy_cache"
        "$HOME/.pytest_cache"
        "$HOME/.ruff_cache"
        "$HOME/.cargo/registry/cache"
        "$HOME/.rustup"
    )
    
    for temp_loc in "${temp_locations[@]}"; do
        if [[ -d "$temp_loc" ]]; then
            local size=$(du -sh "$temp_loc" 2>/dev/null | awk '{print $1}')
            if [[ -n "$size" ]]; then
                if prompt_yes_no "      Clear $temp_loc ($size)?"; then
                    rm -rf "$temp_loc"/* 2>/dev/null
                    print_status $GREEN "      ✓ Cleared $temp_loc"
                else
                    print_status $YELLOW "      ⊘ Skipped $temp_loc"
                fi
            fi
        fi
    done
    
    # Clean up old log files
    find ~/logs -name "*.log" -type f -mtime +30 -delete 2>/dev/null
    find ~/logs -name "*.log.*" -type f -mtime +30 -delete 2>/dev/null
    
    print_status $GREEN "      ✓ Comprehensive cleanup completed"
    operations_completed=$((operations_completed + 1))
}

# Generate maintenance report
generate_report() {
    local end_time=$(date +%s)
    total_time=$((end_time - start_time))

    print_status $PURPLE "📊 ADVANCED MAINTENANCE REPORT V3"
    print_status $CYAN "====================================="
    print_status $GREEN "✅ Packages updated: $packages_updated"
    print_status $RED "❌ Packages failed: $packages_failed"
    print_status $GREEN "✅ Operations completed: $operations_completed"
    print_status $RED "❌ Operations failed: $operations_failed"
    print_status $BLUE "⏱️  Total time: ${total_time}s"
    print_status $YELLOW "📝 Log file: $LOGFILE"
    print_status $CYAN "====================================="
}

# Main maintenance function
maintenance-all() {
    print_status $BOLD $PURPLE "🚀 ADVANCED SYSTEM MAINTENANCE PRO V3"
    print_status $BOLD $PURPLE "   Optimized for Complex AI/Automation Ecosystems"
    print_status $CYAN "========================================================="
    print_status $GREEN "Starting comprehensive system maintenance for complex ecosystems..."
    print_status $CYAN "========================================================="
    echo ""

    # Get initial disk space
    local initial_space=$(df -k / | tail -1 | awk '{print $4}')

    # Run all maintenance functions
    maintain-avatararts
    maintain-harbor
    maintain-intellihub
    maintain-python-envs
    maintain-ai-tools
    maintain-dev-tools
    update-brew
    update-conda
    clear-system-caches
    analyze-large-dirs
    maintain-env-configs
    comprehensive-cleanup

    # Calculate space freed
    local final_space=$(df -k / | tail -1 | awk '{print $4}')
    local freed=$((final_space - initial_space))

    print_status $GREEN "✓ ALL MAINTENANCE OPERATIONS COMPLETED!"
    print_status $CYAN "Results:"
    if [[ $freed -gt 0 ]]; then
        # Convert from KB to bytes for human readable format
        local freed_bytes=$((freed * 1024))
        local freed_human=$(bytesToHuman $freed_bytes)
        print_status $GREEN "   Space potentially freed: ${freed_human}"
    else
        print_status $CYAN "   Space change: (minimal - caches may have been small)"
    fi

    # Generate report
    generate_report

    print_status $GREEN "🎉 Advanced system maintenance v3 process completed!"
    print_status $CYAN "Log saved to: $LOGFILE"
}

# Quick maintenance function
maintenance-quick() {
    print_status $BOLD $PURPLE "⚡ QUICK MAINTENANCE MODE"
    print_status $CYAN "=========================="
    print_status $GREEN "Running quick maintenance operations..."
    echo ""

    # Run only essential maintenance functions
    update-brew
    update-conda
    clear-system-caches
    maintain-dev-tools
    comprehensive-cleanup

    print_status $GREEN "✓ QUICK MAINTENANCE COMPLETED!"
    generate_report
}

# Help function
show_help() {
    print_status $BOLD $PURPLE "ADVANCED SYSTEM MAINTENANCE PRO V3 - HELP"
    print_status $CYAN "============================================"
    echo ""
    print_status $GREEN "Available functions:"
    echo "  maintenance-all     - Full ecosystem maintenance (recommended)"
    echo "  maintenance-quick   - Quick maintenance for routine upkeep"
    echo "  maintain-avatararts - AVATARARTS ecosystem maintenance"
    echo "  maintain-harbor     - Harbor ecosystem maintenance" 
    echo "  maintain-intellihub - IntelliHub ecosystem maintenance"
    echo "  maintain-python-envs - Python environments maintenance"
    echo "  maintain-ai-tools   - AI/ML tools maintenance"
    echo "  maintain-dev-tools  - Development tools maintenance"
    echo "  update-brew         - Update Homebrew packages"
    echo "  update-conda        - Update Conda/Mamba packages"
    echo "  clear-system-caches - Clear system caches"
    echo "  analyze-large-dirs  - Analyze large directories"
    echo "  comprehensive-cleanup - Comprehensive cleanup"
    echo ""
    print_status $CYAN "Usage:"
    echo "  ./advanced-system-maintenance-v3.sh [function_name]"
    echo "  ./advanced-system-maintenance-v3.sh maintenance-all"
    echo "  ./advanced-system-maintenance-v3.sh maintenance-quick"
    echo ""
}

# Main execution
if [ $# -eq 0 ]; then
    maintenance-all
else
    case "$1" in
        "maintenance-all")
            maintenance-all
            ;;
        "maintenance-quick")
            maintenance-quick
            ;;
        "maintain-avatararts")
            maintain-avatararts
            ;;
        "maintain-harbor")
            maintain-harbor
            ;;
        "maintain-intellihub")
            maintain-intellihub
            ;;
        "maintain-python-envs")
            maintain-python-envs
            ;;
        "maintain-ai-tools")
            maintain-ai-tools
            ;;
        "maintain-dev-tools")
            maintain-dev-tools
            ;;
        "update-brew")
            update-brew
            ;;
        "update-conda")
            update-conda
            ;;
        "clear-system-caches")
            clear-system-caches
            ;;
        "analyze-large-dirs")
            analyze-large-dirs
            ;;
        "comprehensive-cleanup")
            comprehensive-cleanup
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
