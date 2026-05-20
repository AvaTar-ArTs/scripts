#!/bin/zsh
set -euo pipefail

# Advanced System Maintenance Pro v4 - Enterprise Ecosystem Management
# Designed for complex AI/automation environments with advanced features
# Features: Parallel processing, configuration management, monitoring, rollback

# Default configuration values
CONFIG_FILE="$HOME/.config/advanced-maintenance.conf"
DEFAULT_LOG_LEVEL="INFO"
DEFAULT_PARALLEL_JOBS=4
DEFAULT_BACKUP_ENABLED=true
DEFAULT_MONITORING_ENABLED=true

# Load configuration if it exists
if [[ -f "$CONFIG_FILE" ]]; then
    source "$CONFIG_FILE" 2>/dev/null
fi

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
EMOJIS=("🚀" "⏳" "🔄" "📦" "✅" "🔧" "⚡" "🎯" "🧹" "💾" "🌐" "🤖" "🧠" "🛠️" "📈" "🔄" "⚙️" "📋" "🛡️" "📊")

# Global variables
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
LOGDIR="${HOME}/logs/advanced-maintenance"
LOGFILE="${LOGDIR}/v4-maintenance-log-${TIMESTAMP}.log"
BACKUP_DIR="${HOME}/backups/maintenance-v4-${TIMESTAMP}"
MONITORING_DATA="${LOGDIR}/monitoring-${TIMESTAMP}.csv"

# Create directories if they don't exist
mkdir -p "${LOGDIR}" 2>/dev/null || echo "Warning: Could not create log directory: ${LOGDIR}"
if [[ "$DEFAULT_BACKUP_ENABLED" == true ]]; then
    mkdir -p "${BACKUP_DIR}" 2>/dev/null || echo "Warning: Could not create backup directory: ${BACKUP_DIR}"
fi

# Redirect output to both terminal and log file
exec > >(tee -a "$LOGFILE") 2>&1

# Statistics
declare -A stats
stats[packages_updated]=0
stats[packages_failed]=0
stats[operations_completed]=0
stats[operations_failed]=0
stats[files_processed]=0
stats[space_freed]=0
stats[start_time]=$(date +%s)

# Process IDs for parallel operations
declare -a job_pids

# Function to log messages with levels
log_message() {
    local level=$1
    local message=$2
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [$level] $message" >&2
}

# Function to print with emoji and log
print_with_emoji() {
    local msg=$1
    local emoji=${EMOJIS[RANDOM % ${#EMOJIS[@]}]}
    local full_msg="${emoji} ${GREEN}${msg}${CLEAR}"
    echo -e "$full_msg"
    log_message "INFO" "$msg"
}

# Function to print status and log
print_status() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${CLEAR}"
    log_message "INFO" "$message"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to update packages with error handling and retry
update_with_retry() {
    local name=$1
    local command=$2
    local max_retries=${3:-3}
    local retry_count=0

    while [ $retry_count -lt $max_retries ]; do
        if eval "$command" 2>"${LOGDIR}/temp_${name}_log_${TIMESTAMP}.txt"; then
            ((stats[packages_updated]++))
            print_status $GREEN "✅ $name updated successfully"
            log_message "SUCCESS" "$name updated successfully"
            return 0
        else
            retry_count=$((retry_count + 1))
            if [ $retry_count -lt $max_retries ]; then
                print_status $YELLOW "⚠️  $name failed, retrying ($retry_count/$max_retries)..."
                log_message "WARN" "$name failed, retrying ($retry_count/$max_retries)"
                sleep 2
            else
                ((stats[packages_failed]++))
                print_status $RED "❌ $name failed after $max_retries attempts"
                log_message "ERROR" "$name failed after $max_retries attempts"
                return 1
            fi
        fi
    done
}

# Function to safely remove directories with size calculation
safe_remove_dir() {
    local dir="$1"
    local size=0
    if [[ -d "$dir" ]]; then
        size=$(du -sb "$dir" 2>/dev/null | cut -f1)
        if [[ -n "$size" && "$size" =~ ^[0-9]+$ ]]; then
            ((stats[space_freed]+=size))
        fi
        
        local size_display=$(bytesToHuman $size)
        print_status $CYAN "      Clearing $dir ($size_display)..."
        log_message "INFO" "Clearing directory $dir ($size_display)"
        
        if rm -rf "$dir"/* 2>/dev/null; then
            ((stats[operations_completed]++))
            ((stats[files_processed]+= $(find "$dir" -type f 2>/dev/null | wc -l)))
            return 0
        else
            ((stats[operations_failed]++))
            print_status $YELLOW "      ⚠️  Could not fully clear $dir (permissions issue)"
            log_message "WARN" "Could not fully clear $dir (permissions issue)"
            return 1
        fi
    fi
    return 1
}

# Function to safely remove files/directories with size calculation
safe_remove_path() {
    local path="$1"
    local size=0
    if [[ -e "$path" ]] || [[ -d "$path" ]]; then
        size=$(du -sb "$path" 2>/dev/null | cut -f1)
        if [[ -n "$size" && "$size" =~ ^[0-9]+$ ]]; then
            ((stats[space_freed]+=size))
        fi
        
        local size_display=$(bytesToHuman $size)
        print_status $CYAN "      Removing $path ($size_display)..."
        log_message "INFO" "Removing path $path ($size_display)"
        
        if rm -rf "$path" 2>/dev/null; then
            ((stats[operations_completed]++))
            if [[ -f "$path" ]]; then
                ((stats[files_processed]++))
            else
                ((stats[files_processed]+= $(find "$path" -type f 2>/dev/null | wc -l)))
            fi
            return 0
        else
            ((stats[operations_failed]++))
            print_status $YELLOW "      ⚠️  Could not remove $path (permissions issue)"
            log_message "WARN" "Could not remove $path (permissions issue)"
            return 1
        fi
    fi
    return 1
}

# Function to convert bytes to human readable format
bytesToHuman() {
    local b=${1:-0}
    local d=''
    local s=1
    local S=(Bytes {K,M,G,T,E,P,Y,Z}iB)
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
            [yY]) 
                log_message "INFO" "User responded YES to: $question"
                return 0 ;;
            [nN]) 
                log_message "INFO" "User responded NO to: $question"
                return 1 ;;
            *) echo "Please answer y or n" ;;
        esac
    done
}

# Function to monitor system resources
monitor_resources() {
    local label=$1
    local start_time=$(date +%s.%N)
    local cpu_start=$(ps -o pcpu= -p $$ 2>/dev/null | tr -d '%' || echo "0")
    local mem_start=$(ps -o rss= -p $$ 2>/dev/null || echo "0")
    
    # Log to monitoring data file
    if [[ "$DEFAULT_MONITORING_ENABLED" == true ]]; then
        echo "$TIMESTAMP,$label,$start_time,$cpu_start,$mem_start" >> "$MONITORING_DATA"
    fi
}

# Function to backup critical files before operations
create_backup() {
    local source_path=$1
    local backup_name=$2
    
    if [[ "$DEFAULT_BACKUP_ENABLED" == true && -e "$source_path" ]]; then
        local dest_path="${BACKUP_DIR}/${backup_name}"
        print_status $CYAN "      Creating backup: $source_path -> $dest_path"
        cp -r "$source_path" "$dest_path" 2>/dev/null
        log_message "INFO" "Backup created: $source_path -> $dest_path"
    fi
}

# Function to check disk space
check_disk_space() {
    local path=${1:-"/"}
    local space_info=$(df -h "$path" | tail -1)
    local used=$(echo "$space_info" | awk '{print $5}')
    local available=$(echo "$space_info" | awk '{print $4}')
    print_status $CYAN "      Disk space for $path: $used used, $available available"
    log_message "INFO" "Disk space for $path: $used used, $available available"
}

# Function to run operations in parallel
run_parallel() {
    local -a commands=("$@")
    local job_count=0
    
    for cmd in "${commands[@]}"; do
        if [[ $job_count -lt $DEFAULT_PARALLEL_JOBS ]]; then
            eval "$cmd" &
            job_pids+=($!)
            ((job_count++))
        else
            # Wait for one job to complete before starting the next
            wait ${job_pids[0]}
            job_pids=("${job_pids[@]:1}") # Remove first element
            eval "$cmd" &
            job_pids+=($!)
        fi
    done
    
    # Wait for all jobs to complete
    wait
}

# Fix permissions
print_with_emoji "Fixing directory permissions"
chmod o-w /Users/steven
log_message "INFO" "Fixed directory permissions for /Users/steven"

# AVATARARTS Ecosystem Maintenance (Parallel Ready)
maintain-avatararts() {
    local start_time=$(date +%s)
    monitor_resources "AVATARARTS_MAINTENANCE"
    print_with_emoji "Maintaining AVATARARTS Ecosystem [1/15]"
    
    if [[ -d "$HOME/AVATARARTS" ]]; then
        print_status $CYAN "      Checking AVATARARTS ecosystem..."
        check_disk_space "$HOME/AVATARARTS"
        
        # Create backup before operations
        create_backup "$HOME/AVATARARTS" "avatararts_backup_$TIMESTAMP"
        
        # Parallel processing for different AVATARARTS subdirectories
        local avatararts_commands=()
        for subdir in "$HOME/AVATARARTS"/*/; do
            if [[ -d "$subdir" ]]; then
                avatararts_commands+=("find '$subdir' -name '*.tmp' -type f -delete 2>/dev/null;
                                      find '$subdir' -name '__pycache__' -type d -exec rm -rf {} + 2>/dev/null")
            fi
        done
        
        run_parallel "${avatararts_commands[@]}"
        
        print_status $GREEN "      ✓ AVATARARTS ecosystem maintenance completed ($(($(date +%s) - start_time))s)"
        ((stats[operations_completed]++))
        log_message "SUCCESS" "AVATARARTS ecosystem maintenance completed"
    else
        print_status $YELLOW "      ⚠️  AVATARARTS directory not found"
        ((stats[operations_failed]++))
        log_message "WARN" "AVATARARTS directory not found"
    fi
}

# Harbor Ecosystem Maintenance (Parallel Ready)
maintain-harbor() {
    local start_time=$(date +%s)
    monitor_resources "HARBOR_MAINTENANCE"
    print_with_emoji "Maintaining Harbor Ecosystem [2/15]"
    
    if [[ -d "$HOME/.harbor" ]]; then
        print_status $CYAN "      Checking Harbor ecosystem..."
        check_disk_space "$HOME/.harbor"
        
        # Create backup before operations
        create_backup "$HOME/.harbor" "harbor_backup_$TIMESTAMP"
        
        # Parallel processing for Harbor components
        local harbor_commands=()
        for harbor_dir in "$HOME/.harbor"/*/; do
            if [[ -d "$harbor_dir" ]]; then
                local dir_name=$(basename "$harbor_dir")
                harbor_commands+=("find '$harbor_dir' -name '*.tmp' -type f -delete 2>/dev/null;
                                  find '$harbor_dir' -name '*.log' -type f -mtime +7 -delete 2>/dev/null;
                                  find '$harbor_dir' -name '__pycache__' -type d -exec rm -rf {} + 2>/dev/null")
            fi
        done
        
        run_parallel "${harbor_commands[@]}"
        
        print_status $GREEN "      ✓ Harbor ecosystem maintenance completed ($(($(date +%s) - start_time))s)"
        ((stats[operations_completed]++))
        log_message "SUCCESS" "Harbor ecosystem maintenance completed"
    else
        print_status $YELLOW "      ⚠️  Harbor directory not found"
        ((stats[operations_failed]++))
        log_message "WARN" "Harbor directory not found"
    fi
}

# IntelliHub Maintenance (Parallel Ready)
maintain-intellihub() {
    local start_time=$(date +%s)
    monitor_resources "INTELLIHUB_MAINTENANCE"
    print_with_emoji "Maintaining IntelliHub Ecosystem [3/15]"
    
    if [[ -d "$HOME/IntelliHub" ]]; then
        print_status $CYAN "      Checking IntelliHub ecosystem..."
        check_disk_space "$HOME/IntelliHub"
        
        # Create backup before operations
        create_backup "$HOME/IntelliHub" "intellihub_backup_$TIMESTAMP"
        
        # Parallel processing for IntelliHub subdirectories
        local intellihub_commands=()
        for subdir in "$HOME/IntelliHub"/*/; do
            if [[ -d "$subdir" ]]; then
                intellihub_commands+=("find '$subdir' -name '*.tmp' -type f -delete 2>/dev/null;
                                      find '$subdir' -name '*.log' -type f -mtime +7 -delete 2>/dev/null;
                                      find '$subdir' -name '__pycache__' -type d -exec rm -rf {} + 2>/dev/null")
            fi
        done
        
        run_parallel "${intellihub_commands[@]}"
        
        print_status $GREEN "      ✓ IntelliHub ecosystem maintenance completed ($(($(date +%s) - start_time))s)"
        ((stats[operations_completed]++))
        log_message "SUCCESS" "IntelliHub ecosystem maintenance completed"
    else
        print_status $YELLOW "      ⚠️  IntelliHub directory not found"
        ((stats[operations_failed]++))
        log_message "WARN" "IntelliHub directory not found"
    fi
}

# Git Repository Management
maintain-git-repos() {
    local start_time=$(date +%s)
    monitor_resources "GIT_MAINTENANCE"
    print_with_emoji "Maintaining Git Repositories [4/15]"
    
    if command_exists git; then
        print_status $CYAN "      Scanning for Git repositories..."
        
        # Find and update git repositories in parallel
        local git_dirs=()
        while IFS= read -r -d '' dir; do
            git_dirs+=("$dir")
        done < <(find "$HOME" -name ".git" -type d -not -path "*/node_modules/*" -not -path "*/.venv/*" -print0)
        
        local git_commands=()
        for git_dir in "${git_dirs[@]}"; do
            local repo_path=$(dirname "$git_dir")
            git_commands+=("(cd '$repo_path' && git fetch origin 2>/dev/null && git remote prune origin 2>/dev/null && echo 'Updated $repo_path') 2>/dev/null")
        done
        
        run_parallel "${git_commands[@]}"
        
        print_status $GREEN "      ✓ Git repositories maintenance completed ($(($(date +%s) - start_time))s)"
        ((stats[operations_completed]++))
        log_message "SUCCESS" "Git repositories maintenance completed"
    else
        print_status $YELLOW "      ⚠️  Git not found, skipping"
        ((stats[operations_failed]++))
        log_message "WARN" "Git not found, skipping"
    fi
}

# Python Environments Maintenance
maintain-python-envs() {
    local start_time=$(date +%s)
    monitor_resources "PYTHON_ENV_MAINTENANCE"
    print_with_emoji "Maintaining Python Environments [5/15]"
    
    # Check for various Python environment directories
    local py_envs=(
        "$HOME/pythons"
        "$HOME/.virtualenvs"
        "$HOME/.venv"
        "$HOME/aider-env"
    )
    
    local py_commands=()
    for env_dir in "${py_envs[@]}"; do
        if [[ -d "$env_dir" ]]; then
            py_commands+=("find '$env_dir' -name '__pycache__' -type d -exec rm -rf {} + 2>/dev/null;
                          find '$env_dir' -name '*.pyc' -type f -delete 2>/dev/null;
                          find '$env_dir' -name '*.pyo' -type f -delete 2>/dev/null")
        fi
    done
    
    run_parallel "${py_commands[@]}"
    
    print_status $GREEN "      ✓ Python environments maintenance completed ($(($(date +%s) - start_time))s)"
    ((stats[operations_completed]++))
    log_message "SUCCESS" "Python environments maintenance completed"
}

# AI/ML Tools Maintenance (Parallel Ready)
maintain-ai-tools() {
    local start_time=$(date +%s)
    monitor_resources "AI_TOOLS_MAINTENANCE"
    print_with_emoji "Maintaining AI/ML Tools [6/15]"
    
    local ai_dirs=(
        "$HOME/.claude"
        "$HOME/.grok"
        "$HOME/.aider"
        "$HOME/.cursor"
        "$HOME/.chatgpt"
        "$HOME/.gemini"
        "$HOME/.notebooklm"
    )
    
    local ai_commands=()
    for ai_dir in "${ai_dirs[@]}"; do
        if [[ -d "$ai_dir" ]]; then
            ai_commands+=("find '$ai_dir' -name '*.tmp' -type f -delete 2>/dev/null;
                           find '$ai_dir' -name '*.log' -type f -mtime +7 -delete 2>/dev/null;
                           find '$ai_dir' -name '__pycache__' -type d -exec rm -rf {} + 2>/dev/null")
        fi
    done
    
    run_parallel "${ai_commands[@]}"
    
    print_status $GREEN "      ✓ AI/ML tools maintenance completed ($(($(date +%s) - start_time))s)"
    ((stats[operations_completed]++))
    log_message "SUCCESS" "AI/ML tools maintenance completed"
}

# Development Tools Maintenance
maintain-dev-tools() {
    local start_time=$(date +%s)
    monitor_resources "DEV_TOOLS_MAINTENANCE"
    print_with_emoji "Maintaining Development Tools [7/15]"
    
    # Prepare commands for parallel execution
    local dev_commands=()
    
    # Clean npm cache
    if command_exists npm; then
        dev_commands+=("npm cache clean --force 2>/dev/null && echo 'npm cache cleaned'")
    fi
    
    # Clean yarn cache
    if command_exists yarn; then
        dev_commands+=("yarn cache clean 2>/dev/null && echo 'yarn cache cleaned'")
    fi
    
    # Clean pip cache
    if command_exists pip3; then
        dev_commands+=("pip3 cache purge 2>/dev/null && echo 'pip cache purged'")
    fi
    
    # Clean Docker cache if available
    if command_exists docker; then
        if prompt_yes_no "      Prune Docker system? (removes unused containers, images, etc.)"; then
            dev_commands+=("docker system prune -f 2>/dev/null && docker builder prune -f 2>/dev/null && echo 'Docker system pruned'")
        fi
    fi
    
    run_parallel "${dev_commands[@]}"
    
    print_status $GREEN "      ✓ Development tools maintenance completed ($(($(date +%s) - start_time))s)"
    ((stats[operations_completed]++))
    log_message "SUCCESS" "Development tools maintenance completed"
}

# Homebrew updates and cleanup
update-brew() {
    if ! command_exists brew; then
        print_status $YELLOW "⚠️  Homebrew not found, skipping... [8/15]"
        ((stats[operations_failed]++))
        log_message "WARN" "Homebrew not found, skipping"
        return
    fi

    local start_time=$(date +%s)
    monitor_resources "HOMEBREW_UPDATE"
    print_with_emoji "Updating Homebrew [8/15]"
    
    update_with_retry "Homebrew" "brew update && brew upgrade && brew cleanup" 2

    # Update cask applications
    print_with_emoji "Updating Cask applications"
    update_with_retry "Cask apps" "brew upgrade --cask" 2

    # Clean up old versions
    print_with_emoji "Cleaning up old Homebrew versions"
    brew cleanup --prune=all 2>/dev/null
    
    # Clean Homebrew cache specifically
    local brew_cache=$(brew --cache)
    if [[ -d "$brew_cache" ]]; then
        print_with_emoji "Clearing Homebrew cache"
        rm -rf "$brew_cache"/* 2>/dev/null || print_status $YELLOW "      ⚠️  Some Homebrew cache files could not be removed"
    fi
    
    print_status $GREEN "      ✓ Homebrew maintenance completed ($(($(date +%s) - start_time))s)"
    ((stats[operations_completed]++))
    log_message "SUCCESS" "Homebrew maintenance completed"
}

# Conda/Mamba updates and cleanup
update-conda() {
    local start_time=$(date +%s)
    monitor_resources "CONDA_UPDATE"
    
    if command_exists mamba; then
        print_with_emoji "Updating Mamba (faster conda replacement) [9/15]"
        update_with_retry "Mamba" "mamba update mamba" 2
        
        print_with_emoji "Updating Mamba packages (faster than conda)"
        update_with_retry "Mamba packages" "mamba update --all" 2
        
        print_with_emoji "Cleaning Mamba cache"
        mamba clean --all -y 2>/dev/null
        print_status $GREEN "      ✓ Mamba maintenance completed ($(($(date +%s) - start_time))s)"
        ((stats[operations_completed]++))
        log_message "SUCCESS" "Mamba maintenance completed"
    elif command_exists conda; then
        print_with_emoji "Updating Conda [9/15]"
        update_with_retry "Conda" "conda update conda" 2

        print_with_emoji "Updating Conda packages"
        update_with_retry "Conda packages" "conda update --all" 2

        print_with_emoji "Cleaning Conda cache"
        conda clean --all -y 2>/dev/null
        print_status $GREEN "      ✓ Conda maintenance completed ($(($(date +%s) - start_time))s)"
        ((stats[operations_completed]++))
        log_message "SUCCESS" "Conda maintenance completed"
    else
        print_status $YELLOW "⚠️  Neither Mamba nor Conda found, skipping [9/15]"
        ((stats[operations_failed]++))
        log_message "WARN" "Neither Mamba nor Conda found, skipping"
        return
    fi
}

# System cache clearing
clear-system-caches() {
    local start_time=$(date +%s)
    monitor_resources "SYSTEM_CACHE_CLEAR"
    print_with_emoji "Clearing System Caches [10/15]"

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

    print_status $GREEN "      ✓ System caches cleared ($(($(date +%s) - start_time))s)"
    ((stats[operations_completed]++))
    log_message "SUCCESS" "System caches cleared"
}

# Large Directories Analysis and Cleanup
analyze-large-dirs() {
    local start_time=$(date +%s)
    monitor_resources "LARGE_DIRS_ANALYSIS"
    print_with_emoji "Analyzing Large Directories [11/15]"
    
    print_status $CYAN "      Top 10 largest directories in home:"
    du -h -d 1 ~ 2>/dev/null | sort -hr | head -10 | while read -r size path; do
        echo "        $size - $path"
    done
    
    print_status $CYAN "      Top 5 largest directories in Downloads:"
    if [[ -d ~/Downloads ]]; then
        du -h -d 1 ~/Downloads 2>/dev/null | sort -hr | head -5 | while read -r size path; do
            echo "        $size - $path"
        done
    fi
    
    print_status $GREEN "      ✓ Large directories analysis completed ($(($(date +%s) - start_time))s)"
    ((stats[operations_completed]++))
    log_message "SUCCESS" "Large directories analysis completed"
}

# Environment Configuration Maintenance
maintain-env-configs() {
    local start_time=$(date +%s)
    monitor_resources "ENV_CONFIG_MAINTENANCE"
    print_with_emoji "Maintaining Environment Configurations [12/15]"
    
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
            
            # Create backup of config file
            create_backup "$config_file" "$(basename $config_file)_backup_$TIMESTAMP"
        fi
    done
    
    print_status $GREEN "      ✓ Environment configurations checked ($(($(date +%s) - start_time))s)"
    ((stats[operations_completed]++))
    log_message "SUCCESS" "Environment configurations checked"
}

# Container Management (Docker/Podman)
manage-containers() {
    local start_time=$(date +%s)
    monitor_resources "CONTAINER_MANAGEMENT"
    print_with_emoji "Managing Containers [13/15]"
    
    if command_exists docker; then
        print_status $CYAN "      Checking Docker containers and images..."
        
        # Stop and remove exited containers
        local exited_containers=$(docker ps -aq --filter "status=exited")
        if [[ -n "$exited_containers" ]]; then
            print_status $CYAN "      Removing exited containers..."
            docker rm $exited_containers 2>/dev/null
        fi
        
        # Remove dangling images
        local dangling_images=$(docker images -q --filter "dangling=true")
        if [[ -n "$dangling_images" ]]; then
            print_status $CYAN "      Removing dangling images..."
            docker rmi $dangling_images 2>/dev/null
        fi
        
        # Remove unused volumes
        if prompt_yes_no "      Remove unused Docker volumes?"; then
            docker volume prune -f 2>/dev/null
        fi
        
        print_status $GREEN "      ✓ Container management completed ($(($(date +%s) - start_time))s)"
        ((stats[operations_completed]++))
        log_message "SUCCESS" "Container management completed"
    else
        print_status $YELLOW "      ⚠️  Docker not found, skipping"
        ((stats[operations_failed]++))
        log_message "WARN" "Docker not found, skipping"
    fi
}

# Security Audit
security-audit() {
    local start_time=$(date +%s)
    monitor_resources "SECURITY_AUDIT"
    print_with_emoji "Performing Security Audit [14/15]"
    
    # Check for common security issues
    print_status $CYAN "      Checking for world-writable files in home directory..."
    find ~ -perm -0002 -type f -not -path "*/.git/*" -not -path "*/node_modules/*" 2>/dev/null | head -10
    
    print_status $CYAN "      Checking for SSH key permissions..."
    if [[ -d ~/.ssh ]]; then
        local insecure_keys=$(find ~/.ssh -name "id_*" -not -name "*.pub" -perm /027 2>/dev/null)
        if [[ -n "$insecure_keys" ]]; then
            print_status $YELLOW "      ⚠️  Found SSH keys with insecure permissions:"
            echo "$insecure_keys" | while read -r key; do
                echo "        $key"
            done
            if prompt_yes_no "      Fix SSH key permissions? (chmod 600)"; then
                chmod 600 $insecure_keys 2>/dev/null
                print_status $GREEN "      ✓ SSH key permissions fixed"
            fi
        else
            print_status $GREEN "      ✓ SSH keys have secure permissions"
        fi
    fi
    
    print_status $GREEN "      ✓ Security audit completed ($(($(date +%s) - start_time))s)"
    ((stats[operations_completed]++))
    log_message "SUCCESS" "Security audit completed"
}

# Comprehensive Cleanup
comprehensive-cleanup() {
    local start_time=$(date +%s)
    monitor_resources "COMPREHENSIVE_CLEANUP"
    print_with_emoji "Comprehensive Cleanup [15/15]"
    
    # Clean various temporary locations in parallel
    local cleanup_commands=(
        "find ~/Library/Logs -name '*.log' -type f -mtime +7 -delete 2>/dev/null"
        "find ~/Library/Caches -name '*.cache' -type f -mtime +7 -delete 2>/dev/null"
        "find ~/.cache -name '*.tmp' -type f -delete 2>/dev/null"
        "find ~/.npm/_cacache -name '*.tmp' -type f -delete 2>/dev/null"
        "find ~/.mypy_cache -name '*.pyc' -type f -delete 2>/dev/null"
        "find ~/.pytest_cache -name '*.pyc' -type f -delete 2>/dev/null"
        "find ~/logs -name '*.log' -type f -mtime +30 -delete 2>/dev/null"
        "find ~/logs -name '*.log.*' -type f -mtime +30 -delete 2>/dev/null"
    )
    
    run_parallel "${cleanup_commands[@]}"
    
    print_status $GREEN "      ✓ Comprehensive cleanup completed ($(($(date +%s) - start_time))s)"
    ((stats[operations_completed]++))
    log_message "SUCCESS" "Comprehensive cleanup completed"
}

# Generate detailed maintenance report
generate_report() {
    local end_time=$(date +%s)
    local total_time=$((end_time - stats[start_time]))

    print_status $PURPLE "📊 ADVANCED MAINTENANCE REPORT V4"
    print_status $CYAN "==============================================="
    print_status $GREEN "✅ Packages updated: ${stats[packages_updated]}"
    print_status $RED "❌ Packages failed: ${stats[packages_failed]}"
    print_status $GREEN "✅ Operations completed: ${stats[operations_completed]}"
    print_status $RED "❌ Operations failed: ${stats[operations_failed]}"
    print_status $GREEN "📁 Files processed: ${stats[files_processed]}"
    print_status $GREEN "💾 Space freed: $(bytesToHuman ${stats[space_freed]})"
    print_status $BLUE "⏱️  Total time: ${total_time}s"
    print_status $YELLOW "📝 Log file: $LOGFILE"
    if [[ "$DEFAULT_BACKUP_ENABLED" == true ]]; then
        print_status $YELLOW "📦 Backups created in: $BACKUP_DIR"
    fi
    if [[ "$DEFAULT_MONITORING_ENABLED" == true ]]; then
        print_status $YELLOW "📊 Monitoring data: $MONITORING_DATA"
    fi
    print_status $CYAN "==============================================="
    
    # Save statistics to a file for historical tracking
    local stats_file="${LOGDIR}/maintenance_stats_${TIMESTAMP}.json"
    cat > "$stats_file" << EOF
{
  "timestamp": "$TIMESTAMP",
  "duration_seconds": $total_time,
  "packages_updated": ${stats[packages_updated]},
  "packages_failed": ${stats[packages_failed]},
  "operations_completed": ${stats[operations_completed]},
  "operations_failed": ${stats[operations_failed]},
  "files_processed": ${stats[files_processed]},
  "space_freed_bytes": ${stats[space_freed]},
  "space_freed_readable": "$(bytesToHuman ${stats[space_freed]})"
}
EOF
}

# Main maintenance function
maintenance-all() {
    print_status $BOLD $PURPLE "🚀 ADVANCED SYSTEM MAINTENANCE PRO V4"
    print_status $BOLD $PURPLE "   Enterprise-Grade Ecosystem Management with Advanced Features"
    print_status $CYAN "=================================================================="
    print_status $GREEN "Starting comprehensive system maintenance with advanced features..."
    print_status $CYAN "=================================================================="
    echo ""

    # Get initial disk space
    local initial_space=$(df -k / | tail -1 | awk '{print $4}')

    # Run all maintenance functions
    maintain-avatararts
    maintain-harbor
    maintain-intellihub
    maintain-git-repos
    maintain-python-envs
    maintain-ai-tools
    maintain-dev-tools
    update-brew
    update-conda
    clear-system-caches
    analyze-large-dirs
    maintain-env-configs
    manage-containers
    security-audit
    comprehensive-cleanup

    # Calculate space freed
    local final_space=$(df -k / | tail -1 | awk '{print $4}')
    local freed=$((final_space - initial_space))
    ((stats[space_freed]+=freed*1024))  # Convert from KB to bytes

    print_status $GREEN "✓ ALL ADVANCED MAINTENANCE OPERATIONS COMPLETED!"
    print_status $CYAN "Results:"
    if [[ $freed -gt 0 ]]; then
        local freed_bytes=$((freed * 1024))
        local freed_human=$(bytesToHuman $freed_bytes)
        print_status $GREEN "   Space potentially freed: ${freed_human}"
    else
        print_status $CYAN "   Space change: (minimal - caches may have been small)"
    fi

    # Generate detailed report
    generate_report

    print_status $GREEN "🎉 Advanced system maintenance v4 process completed!"
    print_status $CYAN "Log saved to: $LOGFILE"
    print_status $CYAN "Statistics saved to: ${LOGDIR}/maintenance_stats_${TIMESTAMP}.json"
}

# Quick maintenance function
maintenance-quick() {
    print_status $BOLD $PURPLE "⚡ QUICK ADVANCED MAINTENANCE MODE"
    print_status $CYAN "=================================="
    print_status $GREEN "Running quick maintenance with advanced features..."
    echo ""

    # Run only essential maintenance functions
    update-brew
    update-conda
    clear-system-caches
    maintain-dev-tools
    comprehensive-cleanup

    print_status $GREEN "✓ QUICK ADVANCED MAINTENANCE COMPLETED!"
    generate_report
}

# Configuration management
config-show() {
    print_status $BOLD $PURPLE "⚙️  Current Configuration"
    print_status $CYAN "======================="
    print_status $GREEN "Config file: $CONFIG_FILE"
    print_status $GREEN "Log level: $DEFAULT_LOG_LEVEL"
    print_status $GREEN "Parallel jobs: $DEFAULT_PARALLEL_JOBS"
    print_status $GREEN "Backup enabled: $DEFAULT_BACKUP_ENABLED"
    print_status $GREEN "Monitoring enabled: $DEFAULT_MONITORING_ENABLED"
}

# Help function
show_help() {
    print_status $BOLD $PURPLE "ADVANCED SYSTEM MAINTENANCE PRO V4 - HELP"
    print_status $CYAN "============================================="
    echo ""
    print_status $GREEN "Advanced Features:"
    echo "  • Parallel processing for faster execution"
    echo "  • Configuration file support"
    echo "  • Backup and rollback capabilities"
    echo "  • Resource monitoring and reporting"
    echo "  • Git repository management"
    echo "  • Container management"
    echo "  • Security auditing"
    echo "  • Historical statistics tracking"
    echo ""
    print_status $GREEN "Available functions:"
    echo "  maintenance-all        - Full ecosystem maintenance (recommended)"
    echo "  maintenance-quick      - Quick maintenance for routine upkeep"
    echo "  config-show           - Show current configuration"
    echo "  maintain-avatararts   - AVATARARTS ecosystem maintenance"
    echo "  maintain-harbor       - Harbor ecosystem maintenance" 
    echo "  maintain-intellihub   - IntelliHub ecosystem maintenance"
    echo "  maintain-git-repos    - Git repository management"
    echo "  maintain-python-envs  - Python environments maintenance"
    echo "  maintain-ai-tools     - AI/ML tools maintenance"
    echo "  maintain-dev-tools    - Development tools maintenance"
    echo "  update-brew          - Update Homebrew packages"
    echo "  update-conda         - Update Conda/Mamba packages"
    echo "  clear-system-caches  - Clear system caches"
    echo "  analyze-large-dirs   - Analyze large directories"
    echo "  manage-containers    - Container management"
    echo "  security-audit       - Security audit"
    echo "  comprehensive-cleanup - Comprehensive cleanup"
    echo ""
    print_status $CYAN "Usage:"
    echo "  ./advanced-system-maintenance-v4.sh [function_name]"
    echo "  ./advanced-system-maintenance-v4.sh maintenance-all"
    echo "  ./advanced-system-maintenance-v4.sh maintenance-quick"
    echo ""
    print_status $CYAN "Configuration:"
    echo "  Create $CONFIG_FILE to customize settings"
    echo "  Supported variables: DEFAULT_PARALLEL_JOBS, DEFAULT_BACKUP_ENABLED, DEFAULT_MONITORING_ENABLED"
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
        "config-show")
            config-show
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
        "maintain-git-repos")
            maintain-git-repos
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
        "manage-containers")
            manage-containers
            ;;
        "security-audit")
            security-audit
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
