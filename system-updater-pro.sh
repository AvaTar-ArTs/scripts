#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail


# Updater Pro - Enhanced Package Update Utility
# Integrates with Mac Cleanup Pro for comprehensive system maintenance
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
LOGFILE="update-log-$(date +%Y%m%d-%H%M%S).log"
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

# Function to update packages within a virtual environment
update_with_venv() {
    local python_bin=$1
    local pip_bin=$2
    local venv_dir=".venv"
    local python_version=$3

    print_with_emoji "Creating virtual environment for Python $python_version"
    $python_bin -m venv $venv_dir

    print_with_emoji "Activating virtual environment"
    source $venv_dir/bin/activate

    print_with_emoji "Upgrading pip and setuptools"
    $pip_bin install --upgrade pip setuptools wheel

    print_with_emoji "Checking for outdated packages"
    local outdated_packages=$($pip_bin list --outdated --format=freeze | grep -v '^\-e' | cut -d = -f 1)

    if [ -n "$outdated_packages" ]; then
        print_with_emoji "Updating Python packages"
        echo "$outdated_packages" | xargs -n1 $pip_bin install -U
    else
        print_with_emoji "No outdated packages to update"
    fi

    print_with_emoji "Deactivating virtual environment"
    deactivate

    print_with_emoji "Removing virtual environment"
    rm -rf $venv_dir
}

# Fix permissions
print_with_emoji "Fixing directory permissions"
chmod o-w /Users/steven

# Homebrew updates
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
}

# Python 2 updates
update-pip2() {
    if ! command_exists python2; then
        print_status $YELLOW "⚠️  Python 2 not found, skipping..."
        return
    fi

    print_with_emoji "Updating Python 2 packages"
    update_with_venv python2 pip2 "2.7"
}

# Python 3 updates
update-pip3() {
    if ! command_exists python3; then
        print_status $YELLOW "⚠️  Python 3 not found, skipping..."
        return
    fi

    print_with_emoji "Updating Python 3 packages"
    update_with_venv python3 pip3 "3.x"
}

# Conda updates
update-conda() {
    if ! command_exists conda; then
        print_status $YELLOW "⚠️  Conda not found, skipping..."
        return
    fi

    print_with_emoji "Updating Conda"
    update_with_retry "Conda" "conda update conda"
    
    print_with_emoji "Updating Conda packages"
    update_with_retry "Conda packages" "conda update --all"
    
    print_with_emoji "Cleaning Conda cache"
    conda clean --all -y 2>/dev/null
}

# NPM updates
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
}

# Yarn updates
update-yarn() {
    if ! command_exists yarn; then
        print_status $YELLOW "⚠️  Yarn not found, skipping..."
        return
    fi

    print_with_emoji "Updating Yarn"
    update_with_retry "Yarn" "npm install -g yarn@latest"
    
    print_with_emoji "Updating global Yarn packages"
    update_with_retry "Global Yarn packages" "yarn global upgrade"
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

# Ruby updates
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

# Docker updates
update-docker() {
    if ! command_exists docker; then
        print_status $YELLOW "⚠️  Docker not found, skipping..."
        return
    fi

    print_with_emoji "Updating Docker images"
    # Fixed: docker pull only accepts one image at a time, loop through them
    docker images --format '{{.Repository}}:{{.Tag}}' | grep -v '<none>' | head -10 | while read -r image; do
        print_status $BLUE "Pulling: $image"
        docker pull "$image" 2>/dev/null || print_status $YELLOW "⚠️  Failed to pull: $image"
    done
    
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

    # Use process substitution to avoid subshell (fixes counter loss)
    while IFS= read -r git_dir; do
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
    done < <(find ~/ -name ".git" -type d 2>/dev/null)

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
    
    # Clean conda
    if command_exists conda; then
        conda clean --all -y 2>/dev/null
    fi
    
    # Clean Docker
    if command_exists docker; then
        docker system prune -f 2>/dev/null
    fi
}

# Generate update report
generate_report() {
    local end_time=$(date +%s)
    total_time=$((end_time - start_time))
    
    print_status $PURPLE "📊 UPDATE REPORT"
    print_status $CYAN "=================="
    print_status $GREEN "✅ Packages updated: $packages_updated"
    print_status $RED "❌ Packages failed: $packages_failed"
    print_status $BLUE "⏱️  Total time: ${total_time}s"
    print_status $YELLOW "📝 Log file: $LOGFILE"
    print_status $CYAN "=================="
}

# Main update function
update-all() {
    # Fixed: print_status only takes 2 args (color, message) not 3
    print_status $PURPLE "🚀 UPDATER PRO - COMPREHENSIVE PACKAGE UPDATE"
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
    
    # Cleanup after updates
    cleanup-after-updates
    
    # Generate report
    generate_report
    
    print_status $GREEN "🎉 Update process completed!"
    print_status $CYAN "Run 'mac-cleanup-pro.sh' to clean up after updates"
}

# Audio reset function
audio-reset() {
    print_with_emoji "Resetting audio system"
    sudo killall coreaudiod
    print_status $GREEN "Audio system reset complete"
}

# Help function
show_help() {
    # Fixed: print_status only takes 2 args (color, message) not 3
    print_status $PURPLE "UPDATER PRO - HELP"
    print_status $CYAN "==================="
    echo ""
    print_status $GREEN "Available functions:"
    echo "  update-all          - Update all packages and applications"
    echo "  update-brew         - Update Homebrew packages"
    echo "  update-pip2         - Update Python 2 packages"
    echo "  update-pip3         - Update Python 3 packages"
    echo "  update-conda        - Update Conda packages"
    echo "  update-npm          - Update NPM packages"
    echo "  update-yarn         - Update Yarn packages"
    echo "  update-nvm          - Update Node.js via NVM"
    echo "  update-ruby         - Update Ruby Gems"
    echo "  update-docker       - Update Docker images"
    echo "  update-git          - Update Git repositories"
    echo "  update-system       - Check for system updates"
    echo "  update-applications - Check for app updates"
    echo "  audio-reset         - Reset audio system"
    echo ""
    print_status $CYAN "Usage:"
    echo "  ./updater-pro.sh [function_name]"
    echo "  ./updater-pro.sh update-all"
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
