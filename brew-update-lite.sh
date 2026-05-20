#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail


# Color and Emoji Setup
GREEN='\033[32m'
RED='\033[31m'
YELLOW='\033[33m'
CLEAR='\033[0m'
EMOJIS=("🍄" "⭐" "🚀" "🌟" "✨" "⚡" "🎮")

# Function to print with emoji
print_with_emoji() {
    local msg="${1}"
    local emoji="${EMOJIS[RANDOM % ${#EMOJIS[@]}]}"
    echo -e "${emoji} ${GREEN}${msg}${CLEAR}"
}

# Function to show an animated progress bar
show_progress() {
    local duration=${1:-5}
    local interval=0.2
    local frames=("|" "/" "-" "\\")

    echo -n "Progress: "
    for ((i = 0; i < duration; i++)); do
        for frame in "${frames[@]}"; do
            echo -ne "${frame}\r"
            sleep $interval
        done
    done
    echo -e "✅ Done!"
}

# Logging Setup
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
LOGFILE="update-log-${TIMESTAMP}.log"
{
    exec > >(tee -a "${LOGFILE}") 2>&1
} || {
    print_with_emoji "Unable to write to ${LOGFILE}. Check permissions or disk status."
}

# Check Network Connectivity
check_network() {
    if ! ping -c 1 google.com &>/dev/null; then
        print_with_emoji "No network connection. Please check your internet."
        exit 1
    fi
}

# Permissions Fix
print_with_emoji "Fixing directory permissions"
chmod o-w "${HOME}" 2>/dev/null || print_with_emoji "Could not remove 'world-write' from ${HOME}"

# Utility Functions
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

safe_run() {
    local cmd="$1"
    if ! eval "${cmd}"; then
        print_with_emoji "Failed to run: ${cmd}"
        print_with_emoji "Check permissions or disk status."
    fi
}

# Update Functions
update_brew() {
    if ! command_exists brew; then
        return
    fi

    print_with_emoji "Updating Brew Formulae"
    show_progress 3
    safe_run "brew update"
    safe_run "brew upgrade"
    safe_run "brew cleanup -s"

    print_with_emoji "Updating Brew Casks"
    show_progress 3
    safe_run "brew outdated --cask"
    safe_run "brew upgrade --cask"
    safe_run "brew cleanup -s"

    print_with_emoji "Running Brew Diagnostics"
    show_progress 2
    safe_run "brew doctor || true"
    safe_run "brew missing || true"
}

# Master Update Function
update_all() {
    check_network
    update_brew
    # Add other update functions here
}

# Main Execution
update_all

# Additional Utility: Audio Reset (Mac-specific)
audio_reset() {
    print_with_emoji "Restarting macOS coreaudiod"
    if ps ax | grep -q "[c]oreaudiod"; then
        sudo killall coreaudiod || print_with_emoji "Could not kill coreaudiod. Check privileges."
    else
        print_with_emoji "coreaudiod not running or not found."
    fi
}
