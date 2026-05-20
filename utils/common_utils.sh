#!/usr/bin/env bash
# Common utility functions for the scripts ecosystem

# Exit on error, undefined variables, and pipe failures
set -euo pipefail

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

# Log functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $*"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $*"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $*"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $*"
}

# Check if required environment variable is set
require_env() {
    local var_name="$1"
    local var_value="${!var_name:-}"
    
    if [[ -z "$var_value" ]]; then
        log_error "Required environment variable $var_name is not set"
        exit 1
    fi
}

# Check if required command exists
require_cmd() {
    local cmd="$1"
    
    if ! command -v "$cmd" &> /dev/null; then
        log_error "Required command '$cmd' is not available"
        exit 1
    fi
}

# Load environment from .env.d system if available
load_env_d() {
    if [[ -d "$HOME/.env.d" ]]; then
        for env_file in "$HOME/.env.d"/*.env; do
            if [[ -f "$env_file" ]]; then
                # shellcheck source=/dev/null
                source "$env_file"
                log_info "Loaded environment from $env_file"
            fi
        done
    else
        log_warn "Environment directory $HOME/.env.d does not exist"
    fi
}

# Create timestamp for backups/logs
timestamp() {
    date +"%Y%m%d_%H%M%S"
}

# Validate that a file exists and is readable
validate_file() {
    local file="$1"
    
    if [[ ! -f "$file" ]] || [[ ! -r "$file" ]]; then
        log_error "File does not exist or is not readable: $file"
        return 1
    fi
    
    return 0
}

# Validate that a directory exists and is readable
validate_dir() {
    local dir="$1"
    
    if [[ ! -d "$dir" ]] || [[ ! -r "$dir" ]]; then
        log_error "Directory does not exist or is not readable: $dir"
        return 1
    fi
    
    return 0
}

# Function to backup a file before modification
backup_file() {
    local file="$1"
    local backup_dir="${2:-$HOME/backups}"
    
    if [[ -f "$file" ]]; then
        mkdir -p "$backup_dir"
        local backup_name="$backup_dir/$(basename "$file").$(timestamp)"
        cp "$file" "$backup_name"
        log_info "Backed up $file to $backup_name"
    else
        log_warn "Cannot backup non-existent file: $file"
    fi
}

# Function to run a command with error handling
run_cmd() {
    local cmd="$*"
    log_info "Executing: $cmd"
    
    if eval "$cmd"; then
        log_success "Command succeeded: $cmd"
    else
        log_error "Command failed: $cmd"
        return 1
    fi
}

# Function to confirm dangerous operations
confirm_action() {
    local action="${1:-Proceed}"
    read -rp "$action? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_info "Operation cancelled by user"
        exit 0
    fi
}

# Function to get the current git branch
get_git_branch() {
    git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown"
}

# Function to check if inside a git repository
is_git_repo() {
    git rev-parse --git-dir > /dev/null 2>&1
}

# Function to check if there are uncommitted changes
has_uncommitted_changes() {
    git status --porcelain 2>/dev/null | grep -q '^..'
}

# Function to get the number of files in a directory
count_files_in_dir() {
    local dir="${1:-.}"
    find "$dir" -type f | wc -l
}

# Function to get the total size of a directory
get_dir_size() {
    local dir="${1:-.}"
    du -sh "$dir" 2>/dev/null | cut -f1
}

# Function to find files by extension
find_files_by_ext() {
    local ext="$1"
    local dir="${2:-.}"
    find "$dir" -name "*.$ext" -type f
}

# Function to check if a file is empty
is_file_empty() {
    local file="$1"
    [[ ! -s "$file" ]]
}

# Function to get the number of lines in a file
get_line_count() {
    local file="$1"
    wc -l < "$file" | tr -d ' '
}

# Function to download a file with curl or wget
download_file() {
    local url="$1"
    local dest="$2"
    
    if command -v curl &> /dev/null; then
        curl -L "$url" -o "$dest"
    elif command -v wget &> /dev/null; then
        wget "$url" -O "$dest"
    else
        log_error "Neither curl nor wget is available"
        return 1
    fi
}

# Function to check if a URL is accessible
check_url_access() {
    local url="$1"
    
    if command -v curl &> /dev/null; then
        curl -s --head --fail "$url" >/dev/null 2>&1
    elif command -v wget &> /dev/null; then
        wget --spider "$url" >/dev/null 2>&1
    else
        log_error "Neither curl nor wget is available"
        return 1
    fi
}

# Function to get the current timestamp in ISO 8601 format
get_iso_timestamp() {
    date -u +"%Y-%m-%dT%H:%M:%SZ"
}

# Function to get the current date in YYYY-MM-DD format
get_date() {
    date +%Y-%m-%d
}

# Function to get the current time in HH:MM:SS format
get_time() {
    date +%H:%M:%S
}

# Function to get the current date and time in YYYY-MM-DD HH:MM:SS format
get_datetime() {
    date +"%Y-%m-%d %H:%M:%S"
}

# Function to check if a command exists and is executable
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to validate JSON
validate_json() {
    local file="$1"
    if command_exists jq; then
        jq empty "$file" 2>/dev/null
    else
        python3 -m json.tool "$file" >/dev/null 2>&1
    fi
}

# Function to validate YAML
validate_yaml() {
    local file="$1"
    if command_exists yq; then
        yq eval "$file" >/dev/null 2>&1
    else
        python3 -c "
import yaml
with open('$file', 'r') as f:
    data = yaml.safe_load(f)
"
    fi
}

# Function to get the system-wide disk usage
get_system_disk_usage() {
    df -h
}

# Function to get the system-wide memory usage
get_system_memory_usage() {
    free -h
}

# Function to get the system-wide CPU usage
get_system_cpu_usage() {
    top -bn1 | head -n 5
}

# Function to get the system-wide process list
get_system_process_list() {
    ps aux --sort=-%cpu | head -n 20
}

# Function to get the system-wide users
get_system_users() {
    who
}

# Function to get the system-wide kernel version
get_system_kernel_version() {
    uname -r
}

# Function to get the system-wide OS version
get_system_os_version() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sw_vers
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        cat /etc/os-release 2>/dev/null || echo "OS version not available"
    else
        echo "OS version not available"
    fi
}

# Function to get the system-wide architecture
get_system_architecture() {
    uname -m
}

# Function to get the system-wide hostname
get_system_hostname() {
    hostname
}

# Function to get the system-wide environment variables
get_system_environment() {
    env
}

# Function to get the system-wide shell
get_system_shell() {
    echo $SHELL
}

# Function to get the system-wide user
get_system_user() {
    whoami
}

# Function to get the system-wide home directory
get_system_home() {
    echo $HOME
}

# Function to get the system-wide current working directory
get_system_pwd() {
    pwd
}

# Function to get the system-wide path
get_system_path() {
    echo $PATH
}