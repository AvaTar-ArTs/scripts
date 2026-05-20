#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail


###############################################################################
# COLOR & EMOJI SETUP
###############################################################################

GREEN='\033[32m'
RED='\033[31m'
YELLOW='\033[33m'
CLEAR='\033[0m'

EMOJIS=("🚀" "⏳" "🔄" "📦" "✅" "⚠️" "❌")

print_with_emoji() {
    local msg="${1}"
    local emoji="${EMOJIS[RANDOM % ${#EMOJIS[@]}]}"
    echo -e "${emoji} ${GREEN}${msg}${CLEAR}"
}

print_warning() {
    local msg="${1}"
    echo -e "⚠️  ${YELLOW}${msg}${CLEAR}"
}

print_error() {
    local msg="${1}"
    echo -e "❌  ${RED}${msg}${CLEAR}"
}

###############################################################################
# LOGGING SETUP
###############################################################################

TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
LOGFILE="update-log-${TIMESTAMP}.log"
# We wrap tee in a try block so if the file system is read-only, we at least get
# normal output in the terminal.
{
    exec > >(tee -a "${LOGFILE}") 2>&1
} || {
    print_warning "Unable to write to ${LOGFILE}. Check permissions or disk status."
}

###############################################################################
# PERMISSIONS FIX
###############################################################################

print_with_emoji "Fixing directory permissions"
chmod o-w "${HOME}" 2>/dev/null || print_warning "Could not remove 'world-write' from ${HOME}"

###############################################################################
# UTILITY FUNCTIONS
###############################################################################

# Safely check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Attempt to gracefully handle read-only filesystems or insufficient permissions
safe_run() {
    local cmd="$1"
    if ! eval "${cmd}"; then
        print_warning "Failed to run: ${cmd}"
        print_warning "Check permissions or disk status."
    fi
}

###############################################################################
# ENVIRONMENT MANAGEMENT FUNCTIONS
###############################################################################
# This script uses function names in lowercase for clarity.
# If you prefer Conda, skip the Python package section below.
###############################################################################

update_python_packages() {
    local python_bin="$1"

    if ! command_exists "${python_bin}"; then
        return
    fi

    local python_path
    python_path="$(command -v "${python_bin}")"

    print_with_emoji "Using ${python_path} to upgrade pip tooling"
    safe_run "${python_path} -m pip install --upgrade pip setuptools wheel"

    print_with_emoji "Checking for outdated packages"
    local outdated_packages
    outdated_packages="$(${python_path} -m pip list --outdated --format=freeze 2>/dev/null)"

    if [ -z "${outdated_packages}" ]; then
        print_with_emoji "No outdated packages to update"
        return
    fi

    local packages=()
    while IFS= read -r line; do
        [ -z "${line}" ] && continue
        package="${line%%==*}"
        [ -n "${package}" ] && packages+=("${package}")
    done <<< "${outdated_packages}"

    if [ ${#packages[@]} -eq 0 ]; then
        print_with_emoji "No outdated packages to update"
        return
    fi

    print_with_emoji "Updating outdated packages"
    safe_run "${python_path} -m pip install --upgrade ${packages[*]}"
}

update_conda() {
    if ! command_exists conda; then
        return
    fi

    print_with_emoji "Updating Conda (Base Environment)"
    safe_run "conda update --yes conda"
    safe_run "conda update --all --yes"
}

###############################################################################
# BREW FUNCTIONS
###############################################################################

update_brew() {
    if ! command_exists brew; then
        return
    fi

    print_with_emoji "Updating Brew Formulae"
    safe_run "brew update"
    safe_run "brew upgrade"
    safe_run "brew cleanup -s"

    print_with_emoji "Updating Brew Casks"
    safe_run "brew outdated --cask"
    safe_run "brew upgrade --cask"
    safe_run "brew cleanup -s"

    print_with_emoji "Running Brew Diagnostics"
    safe_run "brew doctor || true"
    safe_run "brew missing || true"
}

###############################################################################
# PYTHON PACKAGE UPDATES
###############################################################################

update_pip2() {
    if command_exists python2; then
        update_python_packages python2
    fi
}

update_pip3() {
    if command_exists python3; then
        update_python_packages python3
    fi
}

###############################################################################
# JS PACKAGE MANAGEMENT
###############################################################################

update_npm() {
    if ! command_exists npm; then
        return
    fi

    print_with_emoji "Updating npm Packages (Global)"
    # Clean up any stray hidden package folders that can confuse npm
    local npm_root
    npm_root="$(npm root -g 2>/dev/null)"
    if [ -n "${npm_root}" ] && [ -d "${npm_root}" ]; then
        local pattern
        for pattern in ".npm-*" ".tmp-*" ".xai-*"; do
            find "${npm_root}" -mindepth 1 -maxdepth 2 -type d -name "${pattern}" -print0 |
                xargs -0 rm -rf 2>/dev/null || true
        done
    fi

    safe_run "npm update -g --depth=0"
}

update_yarn() {
    if ! command_exists yarn; then
        return
    fi

    print_with_emoji "Updating Yarn Packages (Global)"
    local yarn_version
    yarn_version="$(yarn --version 2>/dev/null)"

    if [ -n "${yarn_version}" ]; then
        local major="${yarn_version%%.*}"
        if [ "${major}" -ge 2 ] 2>/dev/null; then
            safe_run "yarn set version latest"
            safe_run "yarn plugin import interactive-tools"
        else
            safe_run "yarn global upgrade"
        fi
    fi
}

update_nvm() {
    if ! command_exists nvm; then
        return
    fi

    print_with_emoji "Updating Node.js with NVM"
    # Reinstalls packages from the existing node version
    safe_run "nvm install node --reinstall-packages-from=node"
    safe_run "nvm alias default node"
}



###############################################################################
# MASTER UPDATE FUNCTION
###############################################################################

update_all() {
    update_brew         # if installed
    update_pip2         # if installed
    update_pip3         # if installed
    update_conda        # if installed
    update_npm          # if installed
    update_yarn         # if installed
    update_nvm          # if installed
}

###############################################################################
# MAIN EXECUTION
###############################################################################

# If you prefer to comment out the actual call to "update_all" so you can
# selectively run it, do so below.
update_all

###############################################################################
# Additional Utility: AUDIO RESET (Mac-specific)
###############################################################################

audio_reset() {
    print_with_emoji "Restarting macOS coreaudiod"
    # shellcheck disable=SC2009,SC2046
    if ps ax | grep -q "[c]oreaudiod"; then
        sudo killall coreaudiod || print_error "Could not kill coreaudiod. Check privileges."
    else
        print_warning "coreaudiod not running or not found."
    fi
}
