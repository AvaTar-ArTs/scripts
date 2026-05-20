#!/bin/zsh
set -euo pipefail

# System Maintenance Pro - Comprehensive System Update and Cleanup Utility
# Combines the best features of both cleanup and updater scripts
# Based on comprehensive analysis and best practices

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
EMOJIS=("🚀" "⏳" "🔄" "📦" "✅" "🔧" "⚡" "🎯" "🧹" "💾")

# Logfile setup
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
LOGDIR="${HOME}/logs"
LOGFILE="${LOGDIR}/system-maintenance-log-${TIMESTAMP}.log"

# Create log directory if it doesn't exist
mkdir -p "${LOGDIR}" 2>/dev/null || echo "Warning: Could not create log directory: ${LOGDIR}"

# Redirect output to both terminal and log file
exec > >(tee -a "$LOGFILE") 2>&1

# Statistics
packages_updated=0
packages_failed=0
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

# Fix permissions
print_with_emoji "Fixing directory permissions"
chmod o-w /Users/steven

# Homebrew updates and cleanup
update-brew() {
    if ! command_exists brew; then
        print_status $YELLOW "⚠️  Homebrew not found, skipping..."
        return
    fi

    print_with_emoji "Updating Homebrew"
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
}

# Python 2 updates
update-pip2() {
    if ! command_exists python2; then
        print_status $YELLOW "⚠️  Python 2 not found, skipping..."
        return
    fi

    print_with_emoji "Updating Python 2 packages"
    update_with_retry "Python 2 pip" "python2 -m pip install --upgrade pip setuptools wheel"
    update_with_retry "Python 2 packages" "python2 -m pip list --outdated --format=freeze | grep -v '^\-e' | cut -d = -f 1 | xargs -n1 python2 -m pip install -U"
}

# Python 3 updates
update-pip3() {
    if ! command_exists python3; then
        print_status $YELLOW "⚠️  Python 3 not found, skipping..."
        return
    fi

    print_with_emoji "Updating Python 3 packages"
    update_with_retry "Python 3 pip" "python3 -m pip install --upgrade --no-user pip setuptools wheel"
    update_with_retry "Python 3 packages" "python3 -m pip list --outdated --format=freeze | grep -v '^\-e' | cut -d = -f 1 | xargs -n1 python3 -m pip install -U --no-user"
}

# Conda/Mamba updates and cleanup
update-conda() {
    if command_exists mamba; then
        print_with_emoji "Updating Mamba (faster conda replacement)"
        update_with_retry "Mamba" "mamba update mamba"
        
        print_with_emoji "Updating Mamba packages (faster than conda)"
        update_with_retry "Mamba packages" "mamba update --all"
        
        print_with_emoji "Cleaning Mamba cache"
        mamba clean --all -y 2>/dev/null
    elif command_exists conda; then
        print_with_emoji "Updating Conda"
        update_with_retry "Conda" "conda update conda"

        print_with_emoji "Updating Conda packages"
        update_with_retry "Conda packages" "conda update --all"

        print_with_emoji "Cleaning Conda cache"
        conda clean --all -y 2>/dev/null
    else
        print_status $YELLOW "⚠️  Neither Mamba nor Conda found, skipping..."
        return
    fi
}

# NPM updates and cleanup
update-npm() {
    if ! command_exists npm; then
        print_status $YELLOW "⚠️  NPM not found, skipping..."
        return
    fi

    print_with_emoji "Updating NPM"
    update_with_retry "NPM" "npm install -g npm@latest"

    print_with_emoji "Updating global NPM packages"
    update_with_retry "Global NPM packages" "npm update -g"

    print_with_emoji "Cleaning NPM cache"
    npm cache clean --force 2>/dev/null
    
    # Also clean npm global cache directories that might be large
    if [[ -d "$HOME/.npm/_cacache" ]]; then
        local size=$(du -sh "$HOME/.npm/_cacache" 2>/dev/null | awk '{print $1}')
        if [[ -n "$size" ]]; then
            print_status $CYAN "      Clearing npm cache directory (${size})..."
        fi
        rm -rf "$HOME/.npm/_cacache"/* 2>/dev/null || print_status $YELLOW "      ⚠️  Some npm cache files could not be removed"
    fi
}

# Yarn updates and cleanup
update-yarn() {
    if ! command_exists yarn; then
        print_status $YELLOW "⚠️  Yarn not found, skipping..."
        return
    fi

    print_with_emoji "Updating Yarn"
    update_with_retry "Yarn" "npm install -g yarn@latest"

    print_with_emoji "Updating global Yarn packages"
    update_with_retry "Global Yarn packages" "yarn global upgrade"
    
    print_with_emoji "Cleaning Yarn cache"
    yarn cache clean 2>/dev/null
}

# NVM updates
update-nvm() {
    if ! command_exists nvm; then
        print_status $YELLOW "⚠️  NVM not found, skipping..."
        return
    fi

    print_with_emoji "Updating Node.js with NVM"
    update_with_retry "Node.js via NVM" "nvm install node --reinstall-packages-from=node && nvm alias default node"
}

# Ruby updates and cleanup
update-ruby() {
    if ! command_exists gem; then
        print_status $YELLOW "⚠️  Ruby Gems not found, skipping..."
        return
    fi

    print_with_emoji "Updating Ruby Gems"
    update_with_retry "Ruby Gems" "gem update"

    print_with_emoji "Cleaning Ruby Gems"
    gem cleanup 2>/dev/null
}

# Docker updates and cleanup
update-docker() {
    if ! command_exists docker; then
        print_status $YELLOW "⚠️  Docker not found, skipping..."
        return
    fi

    print_with_emoji "Updating Docker images"
    update_with_retry "Docker images" "docker pull \$(docker images --format '{{.Repository}}:{{.Tag}}' | head -10)"

    print_with_emoji "Cleaning Docker system"
    docker system prune -f 2>/dev/null
}

# Git updates
update-git() {
    if ! command_exists git; then
        print_status $YELLOW "⚠️  Git not found, skipping..."
        return
    fi

    print_with_emoji "Updating Git repositories"
    local repo_count=0
    local updated_repos=0

    find ~/ -name ".git" -type d 2>/dev/null | while read -r git_dir; do
        local repo_path=$(dirname "$git_dir")
        local repo_name=$(basename "$repo_path")

        print_status $BLUE "Updating repository: $repo_name"

        cd "$repo_path" || continue

        # Check if there are any changes
        if git diff --quiet && git diff --cached --quiet; then
            # No local changes, safe to pull
            if git pull 2>/dev/null; then
                updated_repos=$((updated_repos + 1))
                print_status $GREEN "✅ $repo_name updated"
            else
                print_status $YELLOW "⚠️  $repo_name has conflicts or issues"
            fi
        else
            print_status $YELLOW "⚠️  $repo_name has local changes, skipping"
        fi

        repo_count=$((repo_count + 1))
    done

    print_status $CYAN "Updated $updated_repos out of $repo_count repositories"
}

# System updates
update-system() {
    print_with_emoji "Checking for system updates"

    if command_exists softwareupdate; then
        print_status $BLUE "Checking for macOS updates..."
        local updates=$(softwareupdate -l 2>/dev/null | grep -c "Software Update found")

        if [ "$updates" -gt 0 ]; then
            print_status $YELLOW "Found $updates system updates available"
            print_status $CYAN "Run 'sudo softwareupdate -i -a' to install all updates"
        else
            print_status $GREEN "System is up to date"
        fi
    fi
}

# Application updates
update-applications() {
    print_with_emoji "Checking for application updates"

    # Check for App Store updates
    if command_exists mas; then
        print_status $BLUE "Checking App Store updates..."
        local app_store_updates=$(mas outdated 2>/dev/null | wc -l)

        if [ "$app_store_updates" -gt 0 ]; then
            print_status $YELLOW "Found $app_store_updates App Store updates"
            print_status $CYAN "Run 'mas upgrade' to update App Store applications"
        else
            print_status $GREEN "App Store applications are up to date"
        fi
    fi

    # Check for Setapp updates
    if [ -d "/Applications/Setapp.app" ]; then
        print_status $BLUE "Checking Setapp updates..."
        open -a Setapp 2>/dev/null
        print_status $CYAN "Setapp opened - check for updates manually"
    fi
}

# System cache clearing
clear-system-caches() {
    print_with_emoji "Clearing System Caches [1/7]"

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
}

# App cache clearing
clear-app-caches() {
    print_with_emoji "Clearing Application Caches [2/7]"

    local app_caches=(
        "~/Library/Application Support/Google/Chrome/Default/Application Cache"
        "~/Library/Application Support/Google/Chrome/Default/Cache"
        "~/.gradle/caches"
        "~/Library/Application Support/Adobe/Common/Media Cache Files"
        "~/Library/Containers/*/Data/Library/Caches"
    )

    for cache_path in "${app_caches[@]}"; do
        local expanded_path=$(eval echo "$cache_path")
        if [[ -d "$expanded_path" ]]; then
            local size=$(du -sh "$expanded_path" 2>/dev/null | awk '{print $1}')
            if [[ -n "$size" ]]; then
                print_status $CYAN "      Clearing ${cache_path} (${size})..."
            else
                print_status $CYAN "      Clearing ${cache_path}..."
            fi
            rm -rf "$expanded_path"/* 2>/dev/null || print_status $YELLOW "      ⚠️  Some files in ${cache_path} could not be removed"
        fi
    done

    print_status $GREEN "      ✓ App caches cleared"
}

# System metadata clearing
clear-system-metadata() {
    print_with_emoji "Clearing System Metadata [3/7]"

    # Biome (system data - safe)
    if [[ -d ~/Library/Biome ]]; then
        local size=$(du -sh ~/Library/Biome 2>/dev/null | awk '{print $1}')
        if [[ -n "$size" ]]; then
            print_status $CYAN "      Clearing ~/Library/Biome (${size})..."
        else
            print_status $CYAN "      Clearing ~/Library/Biome..."
        fi
        rm -rf ~/Library/Biome/* 2>/dev/null || print_status $YELLOW "      ⚠️  Some Biome files could not be removed"
    fi

    # Metadata (system data - safe)
    if [[ -d ~/Library/Metadata ]]; then
        local size=$(du -sh ~/Library/Metadata 2>/dev/null | awk '{print $1}')
        if [[ -n "$size" ]]; then
            print_status $CYAN "      Clearing ~/Library/Metadata (${size})..."
        else
            print_status $CYAN "      Clearing ~/Library/Metadata..."
        fi
        rm -rf ~/Library/Metadata/* 2>/dev/null || print_status $YELLOW "      ⚠️  Some Metadata files could not be removed"
    fi

    print_status $GREEN "      ✓ System metadata cleared"
}

# Python environment cleanup
clear-python-environments() {
    print_with_emoji "Python Environments Cleanup [4/7]"

    local old_envs=(
        "~/global_python_env"
        "~/chatgpt_agent_env"
        "~/ollama_env"
        "~/.conda"
        "~/.mamba"
    )

    local total_env_size=0
    local envs_to_remove=()

    for env in "${old_envs[@]}"; do
        local expanded=$(eval echo "$env")
        if [[ -d "$expanded" ]]; then
            envs_to_remove+=("$expanded")
            local size=$(du -sh "$expanded" 2>/dev/null | awk '{print $1}' | sed 's/[A-Za-z]*//g')
            if [[ -n "$size" && "$size" =~ ^[0-9]+$ ]]; then
                total_env_size=$((total_env_size + size))
            fi
        fi
    done

    if [[ ${#envs_to_remove[@]} -gt 0 ]]; then
        if [[ $total_env_size -gt 0 ]]; then
            print_status $CYAN "      Found old Python environments (~${total_env_size}MB)"
        else
            print_status $CYAN "      Found old Python environments"
        fi
        
        if prompt_yes_no "      Delete old Python environments? (they can be recreated)"; then
            for env in "${envs_to_remove[@]}"; do
                local env_name=$(basename "$env")
                if safe_remove_path "$env"; then
                    print_status $GREEN "      ✓ $env_name removed"
                else
                    print_status $YELLOW "      ⚠️  $env_name removal incomplete"
                fi
            done
        else
            print_status $YELLOW "      ⊘ Skipping Python environments"
        fi
    else
        print_status $CYAN "      No old environments found"
    fi
}

# Package manager cache clearing
clear-package-manager-caches() {
    print_with_emoji "Package Manager Caches [5/7]"

    if command_exists npm; then
        print_status $CYAN "      Cleaning npm cache..."
        npm cache clean --force 2>/dev/null || print_status $YELLOW "      ⚠️  npm cache clean had issues"
        print_status $GREEN "      ✓ npm cache cleared"
    fi

    if command_exists yarn; then
        print_status $CYAN "      Cleaning Yarn cache..."
        yarn cache clean 2>/dev/null || print_status $YELLOW "      ⚠️  Yarn cache clean had issues"
        print_status $GREEN "      ✓ Yarn cache cleared"
    fi
}

# Docker cache clearing
clear-docker-cache() {
    print_with_emoji "Docker Cache [6/7]"

    if command_exists docker; then
        print_status $CYAN "      Checking Docker usage..."
        local docker_info=$(docker system df 2>/dev/null)
        if [[ -n "$docker_info" ]]; then
            print_status $CYAN "      Docker disk usage:"
            echo "$docker_info" | head -15
        fi
        
        if prompt_yes_no "      Prune Docker system? (removes unused containers, networks, images)"; then
            print_status $CYAN "      Pruning Docker system..."
            docker system prune -f 2>/dev/null || print_status $YELLOW "      ⚠️  Docker prune had issues"
            docker builder prune -f 2>/dev/null || print_status $YELLOW "      ⚠️  Docker builder prune had issues"
            print_status $GREEN "      ✓ Docker system pruned"
        else
            print_status $YELLOW "      ⊘ Skipping Docker pruning"
        fi
    else
        print_status $YELLOW "      ⚠️  Docker not found, skipping"
    fi
}

# Mamba/Conda cache clearing
clear-mamba-conda-cache() {
    print_with_emoji "Mamba/Conda Cache [7/7]"

    if command_exists mamba; then
        print_status $CYAN "      Cleaning Mamba cache..."
        mamba clean --all -y 2>/dev/null || print_status $YELLOW "      ⚠️  Mamba clean had issues"
        print_status $GREEN "      ✓ Mamba cache cleaned"
    elif command_exists conda; then
        print_status $CYAN "      Cleaning Conda cache..."
        conda clean --all -y 2>/dev/null || print_status $YELLOW "      ⚠️  Conda clean had issues"
        print_status $GREEN "      ✓ Conda cache cleaned"
    else
        print_status $YELLOW "      ⚠️  Neither Mamba nor Conda found, skipping"
    fi
}

# Cleanup after updates
cleanup-after-updates() {
    print_with_emoji "Cleaning up after updates"

    # Clean Homebrew
    if command_exists brew; then
        brew cleanup --prune=all 2>/dev/null
    fi

    # Clean NPM
    if command_exists npm; then
        npm cache clean --force 2>/dev/null
    fi

    # Clean Yarn
    if command_exists yarn; then
        yarn cache clean 2>/dev/null
    fi

    # Clean pip
    if command_exists pip3; then
        pip3 cache purge 2>/dev/null
    fi

    # Clean conda/mamba
    if command_exists mamba; then
        mamba clean --all -y 2>/dev/null
    elif command_exists conda; then
        conda clean --all -y 2>/dev/null
    fi

    # Clean Docker
    if command_exists docker; then
        docker system prune -f 2>/dev/null
    fi
}

# Generate maintenance report
generate_report() {
    local end_time=$(date +%s)
    total_time=$((end_time - start_time))

    print_status $PURPLE "📊 MAINTENANCE REPORT"
    print_status $CYAN "=================="
    print_status $GREEN "✅ Packages updated: $packages_updated"
    print_status $RED "❌ Packages failed: $packages_failed"
    print_status $BLUE "⏱️  Total time: ${total_time}s"
    print_status $YELLOW "📝 Log file: $LOGFILE"
    print_status $CYAN "=================="
}

# Main update function
update-all() {
    print_status $BOLD $PURPLE "🚀 SYSTEM MAINTENANCE PRO - COMPREHENSIVE UPDATE"
    print_status $CYAN "=================================================="
    print_status $GREEN "Starting comprehensive system update..."
    print_status $CYAN "=================================================="
    echo ""

    # System updates
    update-system

    # Package manager updates
    update-brew
    update-pip2
    update-pip3
    update-conda
    update-npm
    update-yarn
    update-nvm
    update-ruby
    update-docker

    # Development updates
    update-git

    # Application updates
    update-applications

    print_status $GREEN "✅ Update phase completed!"
    echo ""
    print_status $BOLD $PURPLE "🧹 STARTING CLEANUP PHASE"
    print_status $CYAN "=================================================="
    
    # Cleanup operations
    clear-system-caches
    clear-app-caches
    clear-system-metadata
    clear-python-environments
    clear-package-manager-caches
    clear-docker-cache
    clear-mamba-conda-cache

    # Cleanup after updates
    cleanup-after-updates

    # Generate report
    generate_report

    print_status $GREEN "🎉 System maintenance process completed!"
    print_status $CYAN "Log saved to: $LOGFILE"
}

# Main cleanup function
cleanup-all() {
    print_status $BOLD $PURPLE "🧹 SYSTEM MAINTENANCE PRO - COMPREHENSIVE CLEANUP"
    print_status $CYAN "=================================================="
    print_status $GREEN "Starting comprehensive system cleanup..."
    print_status $CYAN "=================================================="
    echo ""

    # Get initial disk space
    local initial_space=$(df -k / | tail -1 | awk '{print $4}')

    # Cleanup operations
    clear-system-caches
    clear-app-caches
    clear-system-metadata
    clear-python-environments
    clear-package-manager-caches
    clear-docker-cache
    clear-mamba-conda-cache

    # Cleanup after updates
    cleanup-after-updates

    # Calculate space freed
    local final_space=$(df -k / | tail -1 | awk '{print $4}')
    local freed=$((final_space - initial_space))

    print_status $GREEN "✓ CLEANUP COMPLETE!"
    print_status $CYAN "Results:"
    if [[ $freed -gt 0 ]]; then
        # Convert from KB to bytes for human readable format
        local freed_bytes=$((freed * 1024))
        local freed_human=$(bytesToHuman $freed_bytes)
        print_status $GREEN "   Space freed: ${freed_human}"
    else
        print_status $CYAN "   Space freed: (minimal - caches may have been small)"
    fi

    # Generate report
    generate_report
}

# Audio reset function
audio-reset() {
    print_with_emoji "Resetting audio system"
    sudo killall coreaudiod
    print_status $GREEN "Audio system reset complete"
}

# Help function
show_help() {
    print_status $BOLD $PURPLE "SYSTEM MAINTENANCE PRO - HELP"
    print_status $CYAN "==================="
    echo ""
    print_status $GREEN "Available functions:"
    echo "  update-all          - Update all packages and applications"
    echo "  cleanup-all         - Comprehensive system cleanup"
    echo "  maintenance-all     - Update and cleanup in sequence"
    echo "  update-brew         - Update Homebrew packages"
    echo "  update-pip2         - Update Python 2 packages"
    echo "  update-pip3         - Update Python 3 packages"
    echo "  update-conda        - Update Conda/Mamba packages (Mamba preferred if available)"
    echo "  update-npm          - Update NPM packages"
    echo "  update-yarn         - Update Yarn packages"
    echo "  update-nvm          - Update Node.js via NVM"
    echo "  update-ruby         - Update Ruby Gems"
    echo "  update-docker       - Update Docker images"
    echo "  update-git          - Update Git repositories"
    echo "  update-system       - Check for system updates"
    echo "  update-applications - Check for app updates"
    echo "  clear-system-caches - Clear system caches"
    echo "  clear-app-caches    - Clear application caches"
    echo "  clear-docker-cache  - Clear Docker cache"
    echo "  clear-mamba-conda-cache - Clear Mamba/Conda cache"
    echo "  audio-reset         - Reset audio system"
    echo ""
    print_status $CYAN "Usage:"
    echo "  ./system-maintenance.sh [function_name]"
    echo "  ./system-maintenance.sh update-all"
    echo "  ./system-maintenance.sh cleanup-all"
    echo "  ./system-maintenance.sh maintenance-all"
    echo ""
}

# Main execution
if [ $# -eq 0 ]; then
    update-all
else
    case "$1" in
        "update-all")
            update-all
            ;;
        "cleanup-all")
            cleanup-all
            ;;
        "maintenance-all")
            update-all
            echo ""
            cleanup-all
            ;;
        "update-brew")
            update-brew
            ;;
        "update-pip2")
            update-pip2
            ;;
        "update-pip3")
            update-pip3
            ;;
        "update-conda")
            update-conda
            ;;
        "update-npm")
            update-npm
            ;;
        "update-yarn")
            update-yarn
            ;;
        "update-nvm")
            update-nvm
            ;;
        "update-ruby")
            update-ruby
            ;;
        "update-docker")
            update-docker
            ;;
        "update-git")
            update-git
            ;;
        "update-system")
            update-system
            ;;
        "update-applications")
            update-applications
            ;;
        "clear-system-caches")
            clear-system-caches
            ;;
        "clear-app-caches")
            clear-app-caches
            ;;
        "clear-docker-cache")
            clear-docker-cache
            ;;
        "clear-mamba-conda-cache")
            clear-mamba-conda-cache
            ;;
        "audio-reset")
            audio-reset
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
