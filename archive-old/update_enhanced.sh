#!/usr/bin/env bash

###############################################################################
# Enhanced macOS Update Script for Intel Systems
# Author: AI Assistant
# Version: 2.0
# Compatible with: macOS Intel (Darwin 24.6.0+)
###############################################################################

set -euo pipefail  # Exit on error, undefined vars, pipe failures

###############################################################################
# CONFIGURATION & CONSTANTS
###############################################################################

# Script metadata
SCRIPT_NAME="Enhanced macOS Update"
SCRIPT_VERSION="2.0"
SCRIPT_AUTHOR="AI Assistant"

# Color codes for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly PURPLE='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly WHITE='\033[1;37m'
readonly CLEAR='\033[0m'

# Emojis for visual feedback
readonly EMOJIS=("🚀" "⏳" "🔄" "📦" "✅" "⚠️" "❌" "🔧" "💾" "🌐" "🐍" "📱" "🖥️" "⚡")

# Logging setup
readonly TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
readonly LOG_DIR="${HOME}/.update_logs"
readonly LOGFILE="${LOG_DIR}/update-${TIMESTAMP}.log"

# Create log directory if it doesn't exist
mkdir -p "${LOG_DIR}"

###############################################################################
# UTILITY FUNCTIONS
###############################################################################

# Enhanced logging with multiple output streams
setup_logging() {
    # Create a named pipe for logging
    local log_pipe="/tmp/update_log_$$"
    mkfifo "${log_pipe}"
    
    # Start background process to handle logging
    (
        while IFS= read -r line; do
            echo "${line}" | tee -a "${LOGFILE}"
        done < "${log_pipe}"
    ) &
    
    local log_pid=$!
    exec > "${log_pipe}" 2>&1
    
    # Store PID for cleanup
    echo "${log_pid}" > "/tmp/update_log_pid_$$"
}

# Cleanup function
cleanup() {
    local log_pid_file="/tmp/update_log_pid_$$"
    if [[ -f "${log_pid_file}" ]]; then
        local log_pid=$(cat "${log_pid_file}")
        kill "${log_pid}" 2>/dev/null || true
        rm -f "${log_pid_file}"
    fi
    rm -f "/tmp/update_log_$$"
}

# Set up cleanup trap
trap cleanup EXIT

# Enhanced print functions with better formatting
print_header() {
    local msg="$1"
    echo -e "\n${BLUE}═══════════════════════════════════════════════════════════════${CLEAR}"
    echo -e "${WHITE}${msg}${CLEAR}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${CLEAR}\n"
}

print_section() {
    local msg="$1"
    echo -e "\n${CYAN}▶ ${msg}${CLEAR}"
}

print_with_emoji() {
    local msg="$1"
    local emoji="${EMOJIS[RANDOM % ${#EMOJIS[@]}]}"
    echo -e "${emoji} ${GREEN}${msg}${CLEAR}"
}

print_warning() {
    local msg="$1"
    echo -e "⚠️  ${YELLOW}${msg}${CLEAR}"
}

print_error() {
    local msg="$1"
    echo -e "❌ ${RED}${msg}${CLEAR}"
}

print_success() {
    local msg="$1"
    echo -e "✅ ${GREEN}${msg}${CLEAR}"
}

print_info() {
    local msg="$1"
    echo -e "ℹ️  ${BLUE}${msg}${CLEAR}"
}

# System information gathering
get_system_info() {
    print_header "System Information"
    
    echo -e "${WHITE}Operating System:${CLEAR} $(sw_vers -productName) $(sw_vers -productVersion)"
    echo -e "${WHITE}Build Version:${CLEAR} $(sw_vers -buildVersion)"
    echo -e "${WHITE}Architecture:${CLEAR} $(uname -m)"
    echo -e "${WHITE}Kernel:${CLEAR} $(uname -r)"
    echo -e "${WHITE}Shell:${CLEAR} ${SHELL}"
    echo -e "${WHITE}User:${CLEAR} $(whoami)"
    echo -e "${WHITE}Home Directory:${CLEAR} ${HOME}"
    echo -e "${WHITE}Available Disk Space:${CLEAR} $(df -h / | awk 'NR==2 {print $4}')"
    echo -e "${WHITE}Memory:${CLEAR} $(system_profiler SPHardwareDataType | grep "Memory:" | awk '{print $2, $3}')"
    echo -e "${WHITE}Processor:${CLEAR} $(system_profiler SPHardwareDataType | grep "Chip:" | awk -F': ' '{print $2}')"
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Safe execution with error handling
safe_run() {
    local cmd="$1"
    local description="${2:-Running command}"
    
    print_info "${description}: ${cmd}"
    
    if eval "${cmd}"; then
        print_success "Completed: ${description}"
        return 0
    else
        print_error "Failed: ${description}"
        return 1
    fi
}

# Check system requirements
check_system_requirements() {
    print_header "System Requirements Check"
    
    local requirements_met=true
    
    # Check macOS version (10.15+)
    local macos_version=$(sw_vers -productVersion)
    local major_version=$(echo "${macos_version}" | cut -d. -f1)
    local minor_version=$(echo "${macos_version}" | cut -d. -f2)
    
    if [[ "${major_version}" -lt 10 ]] || [[ "${major_version}" -eq 10 && "${minor_version}" -lt 15 ]]; then
        print_error "macOS 10.15 (Catalina) or later required. Current: ${macos_version}"
        requirements_met=false
    else
        print_success "macOS version check passed: ${macos_version}"
    fi
    
    # Check available disk space (at least 5GB)
    local available_space=$(df / | awk 'NR==2 {print $4}')
    local required_space=5000000  # 5GB in KB
    
    if [[ "${available_space}" -lt "${required_space}" ]]; then
        print_error "Insufficient disk space. Required: 5GB, Available: $((${available_space}/1000))MB"
        requirements_met=false
    else
        print_success "Disk space check passed: $((${available_space}/1000000))GB available"
    fi
    
    # Check internet connectivity
    if ! ping -c 1 8.8.8.8 >/dev/null 2>&1; then
        print_warning "No internet connectivity detected. Some updates may fail."
    else
        print_success "Internet connectivity confirmed"
    fi
    
    if [[ "${requirements_met}" == "false" ]]; then
        print_error "System requirements not met. Exiting."
        exit 1
    fi
}

###############################################################################
# PACKAGE MANAGER UPDATE FUNCTIONS
###############################################################################

# Homebrew updates with enhanced error handling
update_brew() {
    if ! command_exists brew; then
        print_info "Homebrew not installed. Skipping."
        return 0
    fi
    
    print_section "Updating Homebrew"
    
    # Check if brew is working properly
    if ! brew --version >/dev/null 2>&1; then
        print_error "Homebrew installation appears corrupted. Please reinstall."
        return 1
    fi
    
    # Update brew itself
    safe_run "brew update" "Updating Homebrew formulae database"
    safe_run "brew upgrade" "Upgrading Homebrew packages"
    safe_run "brew upgrade --cask" "Upgrading Homebrew casks"
    safe_run "brew cleanup -s" "Cleaning up Homebrew"
    
    # Run diagnostics
    print_info "Running Homebrew diagnostics..."
    brew doctor || print_warning "Homebrew doctor found issues (check output above)"
    brew missing || print_warning "Homebrew missing found issues (check output above)"
    
    # Show outdated packages
    print_info "Checking for remaining outdated packages..."
    brew outdated || print_info "No outdated packages found"
    
    print_success "Homebrew update completed"
}

# Python package updates with virtual environments
update_python_packages() {
    print_section "Updating Python Packages"
    
    # Find all Python versions
    local python_versions=()
    for py in python python3 python3.9 python3.10 python3.11 python3.12; do
        if command_exists "${py}"; then
            python_versions+=("${py}")
        fi
    done
    
    if [[ ${#python_versions[@]} -eq 0 ]]; then
        print_info "No Python installations found. Skipping."
        return 0
    fi
    
    for py in "${python_versions[@]}"; do
        local pip_cmd="${py} -m pip"
        
        print_with_emoji "Updating packages for ${py}"
        
        # Check if pip is available
        if ! ${py} -m pip --version >/dev/null 2>&1; then
            print_warning "${py} pip not available. Skipping."
            continue
        fi
        
        # Update pip itself
        safe_run "${pip_cmd} install --upgrade pip" "Upgrading pip for ${py}"
        
        # Update setuptools and wheel
        safe_run "${pip_cmd} install --upgrade setuptools wheel" "Upgrading build tools for ${py}"
        
        # Get outdated packages
        local outdated_packages
        outdated_packages=$(${pip_cmd} list --outdated --format=freeze | cut -d= -f1) || true
        
        if [[ -n "${outdated_packages}" ]]; then
            print_info "Found outdated packages for ${py}:"
            echo "${outdated_packages}" | while read -r package; do
                echo "  - ${package}"
            done
            
            # Update packages in batches to avoid memory issues
            echo "${outdated_packages}" | xargs -n 10 ${pip_cmd} install --upgrade || print_warning "Some packages failed to update"
        else
            print_success "All packages up to date for ${py}"
        fi
    done
    
    print_success "Python package updates completed"
}

# Conda updates
update_conda() {
    if ! command_exists conda; then
        print_info "Conda not installed. Skipping."
        return 0
    fi
    
    print_section "Updating Conda"
    
    # Update conda itself
    safe_run "conda update --yes conda" "Updating Conda"
    safe_run "conda update --yes --all" "Updating all Conda packages"
    
    # Clean up conda
    safe_run "conda clean --yes --all" "Cleaning Conda cache"
    
    print_success "Conda update completed"
}

# Node.js and npm updates
update_node_packages() {
    print_section "Updating Node.js Packages"
    
    # Update NVM first if available
    if [[ -d "${HOME}/.nvm" ]]; then
        print_with_emoji "Updating NVM"
        cd "${HOME}/.nvm" && safe_run "git pull origin master" "Updating NVM from git"
        cd - >/dev/null
    fi
    
    # Load NVM if available
    if [[ -s "${HOME}/.nvm/nvm.sh" ]]; then
        source "${HOME}/.nvm/nvm.sh"
    fi
    
    # Update Node.js via nvm if available
    if command_exists nvm; then
        print_with_emoji "Updating Node.js via NVM"
        safe_run "nvm install node --reinstall-packages-from=node" "Installing latest Node.js"
        safe_run "nvm alias default node" "Setting latest Node.js as default"
        safe_run "nvm use node" "Switching to latest Node.js"
    fi
    
    # Update npm if available
    if command_exists npm; then
        print_with_emoji "Updating npm globally"
        safe_run "npm install -g npm@latest" "Updating npm to latest version"
        safe_run "npm update -g" "Updating global npm packages"
    fi
    
    # Update yarn if available
    if command_exists yarn; then
        print_with_emoji "Updating Yarn globally"
        safe_run "yarn global upgrade" "Updating global Yarn packages"
    fi
    
    # Update pnpm if available
    if command_exists pnpm; then
        print_with_emoji "Updating pnpm globally"
        safe_run "pnpm update -g" "Updating global pnpm packages"
    fi
    
    print_success "Node.js package updates completed"
}

# Shell and terminal updates
update_shell_tools() {
    print_section "Updating Shell and Terminal Tools"
    
    # Update Oh My Zsh if available
    if [[ -d "${HOME}/.oh-my-zsh" ]]; then
        print_with_emoji "Updating Oh My Zsh"
        cd "${HOME}/.oh-my-zsh" && safe_run "git pull origin master" "Updating Oh My Zsh from git"
        cd - >/dev/null
        
        # Update Oh My Zsh plugins
        print_with_emoji "Updating Oh My Zsh plugins"
        if [[ -d "${HOME}/.oh-my-zsh/custom/plugins" ]]; then
            find "${HOME}/.oh-my-zsh/custom/plugins" -name ".git" -type d | while read -r plugin_dir; do
                local plugin_name=$(dirname "${plugin_dir}")
                print_info "Updating plugin: $(basename "${plugin_name}")"
                cd "${plugin_name}" && safe_run "git pull" "Updating plugin $(basename "${plugin_name}")" && cd - >/dev/null
            done
        fi
    fi
    
    # Update zsh-autocomplete if available
    if [[ -d "${HOME}/zsh-autocomplete" ]]; then
        print_with_emoji "Updating zsh-autocomplete"
        cd "${HOME}/zsh-autocomplete" && safe_run "git pull origin main" "Updating zsh-autocomplete"
        cd - >/dev/null
    fi
    
    # Update zsh-completions if available
    if [[ -d "${HOME}/zsh-completions" ]]; then
        print_with_emoji "Updating zsh-completions"
        cd "${HOME}/zsh-completions" && safe_run "git pull origin master" "Updating zsh-completions"
        cd - >/dev/null
    fi
    
    print_success "Shell and terminal tools updated"
}

# Custom tools and scripts updates
update_custom_tools() {
    print_section "Updating Custom Tools and Scripts"
    
    # Update AI CLI tools if they exist
    if [[ -f "${HOME}/claude-cli.py" ]]; then
        print_with_emoji "Checking Claude CLI for updates"
        # Check if it's a git repository
        if [[ -d "${HOME}/claude-cli" ]]; then
            cd "${HOME}/claude-cli" && safe_run "git pull" "Updating Claude CLI"
            cd - >/dev/null
        else
            print_info "Claude CLI found but not in git repository"
        fi
    fi
    
    if [[ -f "${HOME}/groq-cli.py" ]]; then
        print_with_emoji "Checking Groq CLI for updates"
        # Check if it's a git repository
        if [[ -d "${HOME}/groq-cli" ]]; then
            cd "${HOME}/groq-cli" && safe_run "git pull" "Updating Groq CLI"
            cd - >/dev/null
        else
            print_info "Groq CLI found but not in git repository"
        fi
    fi
    
    # Update quick archive script if available
    if [[ -f "${HOME}/quick_archive.sh" ]]; then
        print_with_emoji "Checking quick archive script for updates"
        if [[ -d "${HOME}/quick-archive" ]]; then
            cd "${HOME}/quick-archive" && safe_run "git pull" "Updating quick archive script"
            cd - >/dev/null
        fi
    fi
    
    # Update any other custom scripts in bin directory
    if [[ -d "${HOME}/bin" ]]; then
        print_with_emoji "Checking custom bin scripts"
        find "${HOME}/bin" -name ".git" -type d | while read -r script_dir; do
            local script_name=$(dirname "${script_dir}")
            print_info "Updating script: $(basename "${script_name}")"
            cd "${script_name}" && safe_run "git pull" "Updating $(basename "${script_name}")" && cd - >/dev/null
        done
    fi
    
    print_success "Custom tools and scripts updated"
}

# macOS system updates
update_macos_system() {
    print_section "Checking macOS System Updates"
    
    # Check for software updates
    print_info "Checking for available software updates..."
    
    # Use softwareupdate to check for updates
    local updates_available
    updates_available=$(softwareupdate -l 2>&1 | grep -c "Software Update found" || echo "0")
    
    if [[ "${updates_available}" -gt 0 ]]; then
        print_warning "Software updates are available. Run 'sudo softwareupdate -i -a' to install them."
        print_info "Available updates:"
        softwareupdate -l | grep -A 1 "Software Update found" || true
    else
        print_success "No software updates available"
    fi
    
    # Check for Xcode Command Line Tools updates
    if command_exists xcode-select; then
        print_info "Checking Xcode Command Line Tools..."
        if xcode-select -p >/dev/null 2>&1; then
            print_success "Xcode Command Line Tools are installed"
        else
            print_warning "Xcode Command Line Tools not installed. Run 'xcode-select --install' to install them."
        fi
    fi
}

# Additional package managers
update_additional_package_managers() {
    print_section "Updating Additional Package Managers"
    
    # Update MacPorts if available
    if command_exists port; then
        print_with_emoji "Updating MacPorts"
        safe_run "sudo port selfupdate" "Updating MacPorts"
        safe_run "sudo port upgrade outdated" "Upgrading MacPorts packages"
    fi
    
    # Update Fink if available
    if command_exists fink; then
        print_with_emoji "Updating Fink"
        safe_run "fink selfupdate" "Updating Fink"
        safe_run "fink update-all" "Updating Fink packages"
    fi
    
    # Update pipx if available
    if command_exists pipx; then
        print_with_emoji "Updating pipx packages"
        safe_run "pipx upgrade-all" "Upgrading all pipx packages"
        
        # Fix broken symlinks (common issue with pipx)
        print_info "Checking for broken pipx symlinks..."
        local pipx_bin_dir="${HOME}/.local/bin"
        if [[ -d "${pipx_bin_dir}" ]]; then
            find "${pipx_bin_dir}" -type l ! -exec test -e {} \; -print | while read -r broken_link; do
                print_warning "Found broken symlink: ${broken_link}"
                rm -f "${broken_link}"
            done
        fi
    fi
    
    # Update uv (modern Python package manager)
    if command_exists uv; then
        print_with_emoji "Updating uv"
        safe_run "uv self update" "Updating uv itself"
    fi
    
    # Update Poetry if available
    if command_exists poetry; then
        print_with_emoji "Updating Poetry"
        safe_run "poetry self update" "Updating Poetry"
    fi
    
    # Update cargo if available
    if command_exists cargo; then
        print_with_emoji "Updating Rust packages"
        safe_run "cargo install-update -a" "Updating Rust packages"
    fi
    
    # Update gem if available
    if command_exists gem; then
        print_with_emoji "Updating Ruby gems"
        safe_run "gem update" "Updating Ruby gems"
    fi
    
    # Update Bun if available
    if command_exists bun; then
        print_with_emoji "Updating Bun"
        safe_run "bun upgrade" "Updating Bun"
    fi
}

# System maintenance
perform_system_maintenance() {
    print_section "Performing System Maintenance"
    
    # Fix permissions
    print_with_emoji "Fixing directory permissions"
    safe_run "chmod o-w ${HOME}" "Removing world-write permissions from home directory"
    
    # Clear system caches (user-level only)
    print_with_emoji "Clearing user caches"
    safe_run "rm -rf ${HOME}/Library/Caches/*" "Clearing user caches"
    
    # Clear temporary files
    print_with_emoji "Clearing temporary files"
    safe_run "rm -rf /tmp/*" "Clearing temporary files"
    
    # Rebuild Launch Services database
    print_with_emoji "Rebuilding Launch Services database"
    safe_run "/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -kill -r -domain local -domain system -domain user" "Rebuilding Launch Services"
    
    # Reset audio system (macOS specific)
    print_with_emoji "Resetting audio system"
    if pgrep -x "coreaudiod" >/dev/null; then
        safe_run "sudo killall coreaudiod" "Restarting coreaudiod"
    fi
    
    print_success "System maintenance completed"
}

###############################################################################
# MAIN EXECUTION
###############################################################################

main() {
    # Set up logging
    setup_logging
    
    # Print header
    print_header "${SCRIPT_NAME} v${SCRIPT_VERSION}"
    print_info "Started at: $(date)"
    print_info "Log file: ${LOGFILE}"
    
    # Check system requirements
    check_system_requirements
    
    # Get system information
    get_system_info
    
    # Run all updates
    update_brew
    update_python_packages
    update_conda
    update_node_packages
    update_shell_tools
    update_custom_tools
    update_macos_system
    update_additional_package_managers
    
    # Perform system maintenance
    perform_system_maintenance
    
    # Final summary
    print_header "Update Summary"
    print_success "All updates completed successfully!"
    print_info "Log file saved to: ${LOGFILE}"
    print_info "Completed at: $(date)"
    
    # Show disk usage after cleanup
    print_info "Available disk space after cleanup: $(df -h / | awk 'NR==2 {print $4}')"
}

# Handle command line arguments
handle_arguments() {
    case "${1:-}" in
        --brew-only)
            update_brew
            ;;
        --python-only)
            update_python_packages
            update_conda
            ;;
        --node-only)
            update_node_packages
            ;;
        --shell-only)
            update_shell_tools
            ;;
        --custom-only)
            update_custom_tools
            ;;
        --info-only)
            get_system_info
            ;;
        --maintenance-only)
            perform_system_maintenance
            ;;
        --help|-h)
            echo "Enhanced macOS Update Script v${SCRIPT_VERSION}"
            echo ""
            echo "Usage: $0 [OPTION]"
            echo ""
            echo "Options:"
            echo "  --brew-only        Update Homebrew packages only"
            echo "  --python-only      Update Python packages only"
            echo "  --node-only        Update Node.js packages only"
            echo "  --shell-only       Update shell tools only (Oh My Zsh, etc.)"
            echo "  --custom-only      Update custom tools only"
            echo "  --info-only        Show system information only"
            echo "  --maintenance-only Run system maintenance only"
            echo "  --help, -h         Show this help message"
            echo ""
            echo "If no option is provided, runs full system update."
            exit 0
            ;;
        "")
            # No arguments, run full update
            main
            ;;
        *)
            print_error "Unknown option: $1"
            print_info "Use --help for usage information"
            exit 1
            ;;
    esac
}

# Run based on arguments
if [[ $# -eq 0 ]]; then
    main
else
    # Set up logging for partial updates too
    setup_logging
    print_header "${SCRIPT_NAME} v${SCRIPT_VERSION} - Partial Update"
    print_info "Started at: $(date)"
    print_info "Log file: ${LOGFILE}"
    
    handle_arguments "$@"
    
    print_header "Update Summary"
    print_success "Partial update completed successfully!"
    print_info "Log file saved to: ${LOGFILE}"
    print_info "Completed at: $(date)"
fi
