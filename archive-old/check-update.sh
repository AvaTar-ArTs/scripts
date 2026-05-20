#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail


# Text Color Variables
GREEN='\033[32m' # Green
YELLOW='\033[33m' # Yellow
RED='\033[31m' # Red
CLEAR='\033[0m'  # Clear color and formatting

# Emojis for progress indication
EMOJIS=("🚀" "⏳" "🔄" "📦" "✅" "🛠️" "📊" "🔧" "🚧")

# Logfile setup
LOGFILE="update-check-log-$(date +%Y%m%d-%H%M%S).log"

# Function to print with emoji
print_with_emoji() {
    local msg=$1
    local emoji=${EMOJIS[RANDOM % ${#EMOJIS[@]}]}
    echo -e "${emoji} ${GREEN}${msg}${CLEAR}" | tee -a "$LOGFILE"
}

# Function to print warning message
print_warning() {
    local msg=$1
    echo -e "${YELLOW}${msg}${CLEAR}" | tee -a "$LOGFILE"
}

# Function to print error message
print_error() {
    local msg=$1
    echo -e "${RED}${msg}${CLEAR}" | tee -a "$LOGFILE"
}

# Function to log and print update lists
log_output () {
    local output=$1
    if [ -n "$output" ]; then
        echo "$output" | tee -a "$LOGFILE"
    else
        echo "No updates available" | tee -a "$LOGFILE"
    fi
}

check_brew_updates() {
    if ! which brew &>/dev/null; then
        print_error "Brew is not installed or not in PATH"
        return
    fi

    print_with_emoji "Checking Brew Formulae updates"
    outdated_formulae=$(brew outdated 2>&1)
    if [ $? -ne 0 ]; then
        print_error "Error checking Brew Formulae updates: $outdated_formulae"
    else
        log_output "$outdated_formulae"
    fi

    print_with_emoji "Checking Brew Casks updates"
    outdated_casks=$(brew outdated --cask 2>&1)
    if [ $? -ne 0 ]; then
        print_error "Error checking Brew Casks updates: $outdated_casks"
    else
        log_output "$outdated_casks"
    fi
}

check_pip_updates() {
    local python_bin=$1
    local pip_bin=$2

    if ! which $pip_bin &>/dev/null; then
        print_error "$pip_bin is not installed or not in PATH"
        return
    fi

    print_with_emoji "Checking $pip_bin packages updates"
    outdated_packages=$($pip_bin list --outdated 2>&1 | awk 'NR>2 {print $1}')
    if [ $? -ne 0 ]; then
        print_error "Error checking $pip_bin packages updates: $outdated_packages"
    else
        log_output "$outdated_packages"
    fi
}

check_conda_updates() {
    if ! which conda &>/dev/null; then
        print_error "Conda is not installed or not in PATH"
        return
    fi

    print_with_emoji "Checking Conda updates"
    conda_updates=$(conda search --outdated 2>&1)
    if [ $? -ne 0 ]; then
        print_error "Error checking Conda updates: $conda_updates"
    else
        log_output "$conda_updates"
    fi
}

check_npm_updates() {
    if ! which npm &>/dev/null; then
        print_error "NPM is not installed or not in PATH"
        return
    fi

    print_with_emoji "Checking npm global packages updates"
    outdated_npm_packages=$(npm outdated -g --parseable 2>&1 | awk -F: '{print $2}')
    if [ $? -ne 0 ]; then
        print_error "Error checking npm global packages updates: $outdated_npm_packages"
    else
        log_output "$outdated_npm_packages"
    fi
}

check_yarn_updates() {
    if ! which yarn &>/dev/null; then
        print_error "Yarn is not installed or not in PATH"
        return
    fi

    print_with_emoji "Checking Yarn global packages updates"
    outdated_yarn_packages=$(yarn outdated --silent 2>&1)
    if [ $? -ne 0 ]; then
        print_error "Error checking Yarn global packages updates: $outdated_yarn_packages"
    else
        log_output "$outdated_yarn_packages"
    fi
}

check_rustup_updates() {
    if ! which rustup &>/dev/null; then
        print_error "Rustup is not installed or not in PATH"
        return
    fi

    print_with_emoji "Checking Rust updates"
    rustup_updates=$(rustup check 2>&1)
    if [ $? -ne 0 ]; then
        print_error "Error checking Rust updates: $rustup_updates"
    else
        log_output "$rustup_updates"
    fi
}

check_gem_updates() {
    if ! which gem &>/dev/null; then
        print_error "Gem is not installed or not in PATH"
        return
    fi

    print_with_emoji "Checking Ruby Gems updates"
    outdated_gems=$(gem outdated 2>&1)
    if [ $? -ne 0 ]; then
        print_error "Error checking Ruby Gems updates: $outdated_gems"
    else
        log_output "$outdated_gems"
    fi
}

check_apt_updates() {
    if ! which apt-get &>/dev/null; then
        print_error "APT is not installed or not in PATH"
        return
    fi

    print_with_emoji "Checking APT package updates"
    sudo apt-get update > /dev/null
    if [ $? -ne 0 ]; then
        print_error "Error running 'apt-get update'"
        return
    fi
    outdated_apt_packages=$(sudo apt-get -s upgrade 2>&1 | grep "^Inst")
    if [ $? -ne 0 ]; then
        print_error "Error checking APT package updates: $outdated_apt_packages"
    else
        log_output "$outdated_apt_packages"
    fi
}

check_docker_updates() {
    if ! which docker &>/dev/null; then
        print_error "Docker is not installed or not in PATH"
        return
    fi

    print_with_emoji "Checking Docker images updates"
    outdated_docker_images=$(docker images --filter "dangling=true" -q 2>&1)
    if [ $? -ne 0 ]; then
        print_error "Error checking Docker images updates: $outdated_docker_images"
    else
        log_output "$outdated_docker_images"
    fi
}

check_nvm_updates() {
    if ! which nvm &>/dev/null; then
        print_error "NVM is not installed or not in PATH"
        return
    fi

    print_with_emoji "Checking Node.js updates with NVM"
    nvm_check_update=$(nvm ls-remote 2>&1 | tail -1)
    if [ $? -ne 0 ]; then
        print_error "Error checking Node.js updates with NVM: $nvm_check_update"
    else
        log_output "$nvm_check_update"
    fi
}

check_composer_updates() {
    if ! which composer &>/dev/null; then
        print_error "Composer is not installed or not in PATH"
        return
    fi

    print_with_emoji "Checking Composer global package updates"
    outdated_composer_packages=$(composer global outdated 2>&1)
    if [ $? -ne 0 ]; then
        print_error "Error checking Composer global package updates: $outdated_composer_packages"
    else
        log_output "$outdated_composer_packages"
    fi
}

check_all_updates() {
    check_brew_updates
    check_pip_updates python2 pip2
    check_pip_updates python3 pip3
    check_conda_updates
    check_npm_updates
    check_yarn_updates
    check_rustup_updates
    check_gem_updates
    check_apt_updates
    check_docker_updates
    check_nvm_updates
    check_composer_updates
}

# Run check_all_updates
check_all_updates
