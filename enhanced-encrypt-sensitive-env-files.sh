#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail


################################################################################
# Enhanced Sensitive Environment Files Encryption Script
#
# This script securely encrypts sensitive environment files using GPG with
# improved security practices, configuration options, and error handling.
#
# FEATURES:
# - Configurable file lists and directories
# - Multiple encryption methods (symmetric or asymmetric)
# - Secure passphrase handling
# - Verification of encrypted files
# - Backup of original files before encryption
# - Logging of operations
################################################################################

set -E
trap cleanup SIGINT SIGTERM ERR EXIT

cleanup() {
    trap - SIGINT SIGTERM ERR EXIT
}

# Color setup
setup_colors() {
    if [[ -t 2 ]] && [[ -z "${NO_COLOR-}" ]] && [[ "${TERM-}" != "dumb" ]]; then
        NOFORMAT='\033[0m' RED='\033[0;31m' GREEN='\033[0;32m' ORANGE='\033[0;33m' BLUE='\033[0;34m' PURPLE='\033[0;35m' CYAN='\033[0;36m' YELLOW='\033[1;33m'
    else
        NOFORMAT='' RED='' GREEN='' ORANGE='' BLUE='' PURPLE='' CYAN='' YELLOW=''
    fi
}

msg() {
    echo >&2 -e "${1-}"
}

log_message() {
    local level=$1
    local message=$2
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [$level] $message" >> "${LOG_FILE:-/tmp/env_encryption.log}"
}

die() {
    local msg=$1
    local code=${2-1}
    msg "$msg"
    log_message "ERROR" "$msg"
    exit "$code"
}

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

parse_params() {
    force=false
    verbose=false
    dry_run=false
    backup_original=true
    encryption_method="symmetric"  # symmetric or asymmetric
    recipient=""  # For asymmetric encryption
    config_file=""
    log_file="/tmp/env_encryption.log"

    while :; do
        case "${1-}" in
        -h | --help) usage ;;
        -v | --verbose) verbose=true ;;
        --force) force=true ;;
        --dry-run) dry_run=true ;;
        --no-backup) backup_original=false ;;
        --method) 
            shift
            if [[ -n "${1-}" ]]; then
                encryption_method="${1-}"
                if [[ "$encryption_method" != "symmetric" && "$encryption_method" != "asymmetric" ]]; then
                    die "Invalid encryption method: $encryption_method. Use 'symmetric' or 'asymmetric'."
                fi
            fi
            ;;
        --recipient)
            shift
            if [[ -n "${1-}" ]]; then
                recipient="${1-}"
            fi
            ;;
        --config)
            shift
            if [[ -n "${1-}" ]]; then
                config_file="${1-}"
            fi
            ;;
        --log-file)
            shift
            if [[ -n "${1-}" ]]; then
                log_file="${1-}"
            fi
            ;;
        -?*) die "Unknown option: $1" ;;
        *) break ;;
        esac
        shift
    done
}

usage() {
    cat <<EOF
Usage: $(basename "${BASH_SOURCE[0]}") [options]

Enhanced Environment Files Encryption - Securely encrypt sensitive environment files

OPTIONS:
  -h, --help             Show this help
  -v, --verbose          Verbose output
  --force                Skip confirmations (for automation)
  --dry-run              Show what would be encrypted without actually encrypting
  --no-backup            Don't create backups of original files
  --method METHOD        Encryption method: symmetric (default) or asymmetric
  --recipient RECIPIENT  Recipient for asymmetric encryption (email/key ID)
  --config FILE          Configuration file with file list
  --log-file FILE        Log file path (default: /tmp/env_encryption.log)

EXAMPLES:
  $(basename "${BASH_SOURCE[0]}")                                    # Encrypt with defaults
  $(basename "${BASH_SOURCE[0]}") --dry-run                         # Preview operations
  $(basename "${BASH_SOURCE[0]}") --method asymmetric --recipient user@example.com  # Asymmetric encryption
  $(basename "${BASH_SOURCE[0]}") --config my_config.conf           # Use custom config

CONFIGURATION:
  If --config is provided, the file should contain a list of files to encrypt,
  one per line. If not provided, uses default file list.

EOF
    exit 0
}

check_gpg() {
    if ! command -v gpg &> /dev/null; then
        die "❌ Error: gpg is not installed. Please install gnupg to use this script.\n   On macOS: brew install gnupg"
    fi
    
    if [[ "$verbose" == true ]]; then
        msg "${CYAN}✓ GPG is installed${NOFORMAT}"
    fi
    log_message "INFO" "GPG installation verified"
}

load_config() {
    if [[ -n "$config_file" && -f "$config_file" ]]; then
        if [[ "$verbose" == true ]]; then
            msg "${CYAN}Loading configuration from: $config_file${NOFORMAT}"
        fi
        log_message "INFO" "Loading configuration from: $config_file"
        
        # Read files from config
        mapfile -t ENV_FILES < "$config_file"
    else
        # Default file list
        ENV_FILES=(
            "/Users/steven/.env.d.zip"
            "/Users/steven/.env 2.d.zip"
        )
        
        if [[ -n "$config_file" ]]; then
            msg "${ORANGE}⚠️  Config file not found: $config_file${NOFORMAT}"
            msg "${ORANGE}   Using default file list${NOFORMAT}"
            log_message "WARN" "Config file not found: $config_file, using defaults"
        fi
    fi
}

verify_file_exists() {
    local file_path=$1
    if [[ ! -f "$file_path" ]]; then
        msg "${ORANGE}⚠️  File does not exist: $file_path${NOFORMAT}"
        log_message "WARN" "File does not exist: $file_path"
        return 1
    fi
    return 0
}

create_backup() {
    local original_file=$1
    local backup_file="${original_file}.backup.$(date +%Y%m%d_%H%M%S)"
    
    if [[ "$backup_original" == true ]]; then
        if [[ "$dry_run" == false ]]; then
            if cp "$original_file" "$backup_file"; then
                msg "      ${GREEN}✓ Backup created: $backup_file${NOFORMAT}"
                log_message "INFO" "Backup created: $backup_file"
            else
                msg "      ${RED}❌ Failed to create backup: $backup_file${NOFORMAT}"
                log_message "ERROR" "Failed to create backup: $backup_file"
                return 1
            fi
        else
            msg "      Would create backup: ${original_file}.backup.timestamp"
        fi
    else
        msg "      ${ORANGE}⚠️  Backup skipped (disabled)${NOFORMAT}"
        log_message "INFO" "Backup skipped for: $original_file"
    fi
    return 0
}

encrypt_file_symmetric() {
    local file_path=$1
    local encrypted_file="${file_path}.gpg"
    
    if [[ "$dry_run" == false ]]; then
        msg "      🔐 Encrypting $file_path (symmetric)..."
        
        # Use gpg with passphrase from user input
        if gpg --symmetric --cipher-algo AES256 --output "$encrypted_file" "$file_path"; then
            msg "      ${GREEN}✓ Successfully encrypted to $encrypted_file${NOFORMAT}"
            log_message "INFO" "Successfully encrypted $file_path to $encrypted_file"
            
            # Verify the encrypted file exists and has content
            if [[ -f "$encrypted_file" && -s "$encrypted_file" ]]; then
                msg "      ${GREEN}✓ Encrypted file verified${NOFORMAT}"
                log_message "INFO" "Encrypted file verified: $encrypted_file"
            else
                msg "      ${RED}❌ Encrypted file verification failed${NOFORMAT}"
                log_message "ERROR" "Encrypted file verification failed: $encrypted_file"
                return 1
            fi
        else
            msg "      ${RED}❌ Error encrypting $file_path${NOFORMAT}"
            log_message "ERROR" "Error encrypting $file_path"
            return 1
        fi
    else
        msg "      Would encrypt $file_path (symmetric) to ${file_path}.gpg"
    fi
    
    return 0
}

encrypt_file_asymmetric() {
    local file_path=$1
    local encrypted_file="${file_path}.gpg"
    
    if [[ -z "$recipient" ]]; then
        die "❌ Recipient required for asymmetric encryption. Use --recipient option."
    fi
    
    if [[ "$dry_run" == false ]]; then
        msg "      🔐 Encrypting $file_path (asymmetric) for $recipient..."
        
        if gpg --encrypt --recipient "$recipient" --output "$encrypted_file" "$file_path"; then
            msg "      ${GREEN}✓ Successfully encrypted to $encrypted_file${NOFORMAT}"
            log_message "INFO" "Successfully asymmetrically encrypted $file_path to $encrypted_file for $recipient"
            
            # Verify the encrypted file exists and has content
            if [[ -f "$encrypted_file" && -s "$encrypted_file" ]]; then
                msg "      ${GREEN}✓ Encrypted file verified${NOFORMAT}"
                log_message "INFO" "Asymmetrically encrypted file verified: $encrypted_file"
            else
                msg "      ${RED}❌ Encrypted file verification failed${NOFORMAT}"
                log_message "ERROR" "Asymmetrically encrypted file verification failed: $encrypted_file"
                return 1
            fi
        else
            msg "      ${RED}❌ Error encrypting $file_path${NOFORMAT}"
            log_message "ERROR" "Error asymmetrically encrypting $file_path"
            return 1
        fi
    else
        msg "      Would encrypt $file_path (asymmetric) for $recipient to ${file_path}.gpg"
    fi
    
    return 0
}

remove_original() {
    local original_file=$1
    
    if [[ "$dry_run" == false ]]; then
        msg "      🗑️  Removing original file: $original_file"
        
        # Securely delete the original file (optional: use srm if available)
        if command -v srm &>/dev/null; then
            srm "$original_file" 2>/dev/null || rm "$original_file"
        else
            rm "$original_file"
        fi
        
        if [[ $? -eq 0 ]]; then
            msg "      ${GREEN}✓ Original file removed${NOFORMAT}"
            log_message "INFO" "Original file removed: $original_file"
        else
            msg "      ${RED}❌ Failed to remove original file${NOFORMAT}"
            log_message "ERROR" "Failed to remove original file: $original_file"
            return 1
        fi
    else
        msg "      Would remove original file: $original_file"
    fi
    
    return 0
}

parse_params "$@"
setup_colors

LOG_FILE="$log_file"
log_message "INFO" "Script started"

msg "${BLUE}=== Enhanced Sensitive Environment Files Encryption ===${NOFORMAT}"
msg "🔐 ${CYAN}Starting encryption of sensitive environment files...${NOFORMAT}"
msg ""

if [[ "$dry_run" == true ]]; then
    msg "${YELLOW}=== DRY RUN MODE ===${NOFORMAT}"
    msg "⚠️  This is a DRY RUN - no files will be encrypted"
    msg "   Use this to see what would be encrypted"
    msg ""
fi

# Check GPG installation
check_gpg

# Load configuration
load_config

# Show files to be processed
msg "${GREEN}[1/3] Files to be processed${NOFORMAT}"
msg "      Encryption method: $encryption_method"
if [[ "$encryption_method" == "asymmetric" && -n "$recipient" ]]; then
    msg "      Recipient: $recipient"
fi
msg "      Backup original: $([ "$backup_original" = true ] && echo "yes" || echo "no")"
msg ""

for file in "${ENV_FILES[@]}"; do
    if verify_file_exists "$file"; then
        msg "      📄 $file"
    fi
done

# Confirm with user before proceeding (unless force is used)
if [[ "$force" != true && "$dry_run" != true ]]; then
    msg ""
    if prompt_yes_no "Proceed with encrypting these files?"; then
        msg "${GREEN}✓ Encryption proceeding${NOFORMAT}"
        log_message "INFO" "User confirmed encryption"
    else
        msg "${RED}✗ Encryption cancelled by user${NOFORMAT}"
        log_message "INFO" "Encryption cancelled by user"
        exit 0
    fi
else
    if [[ "$dry_run" != true ]]; then
        msg "${GREEN}✓ Encryption proceeding (forced)${NOFORMAT}"
        log_message "INFO" "Encryption proceeding (forced)"
    fi
fi

# Process each file
msg ""
msg "${GREEN}[2/3] Processing files${NOFORMAT}"

success_count=0
error_count=0

for file in "${ENV_FILES[@]}"; do
    if ! verify_file_exists "$file"; then
        continue
    fi
    
    msg "   Processing: $(basename "$file")"
    
    # Create backup
    if ! create_backup "$file"; then
        ((error_count++))
        continue
    fi
    
    # Encrypt file based on method
    if [[ "$encryption_method" == "symmetric" ]]; then
        if ! encrypt_file_symmetric "$file"; then
            ((error_count++))
            continue
        fi
    else
        if ! encrypt_file_asymmetric "$file"; then
            ((error_count++))
            continue
        fi
    fi
    
    # Optionally remove original file after successful encryption
    if [[ "$backup_original" == false ]]; then
        if ! remove_original "$file"; then
            ((error_count++))
            continue
        fi
    else
        msg "      ${ORANGE}ℹ️  Original file preserved. To remove after verification:${NOFORMAT}"
        msg "         rm '$file'"
    fi
    
    ((success_count++))
    msg ""
done

# Summary
msg "${GREEN}[3/3] Summary${NOFORMAT}"
msg "      Successfully processed: $success_count file(s)"
msg "      Errors: $error_count file(s)"

if [[ $error_count -eq 0 && $success_count -gt 0 ]]; then
    msg ""
    msg "${GREEN}✅ Encryption process completed successfully!${NOFORMAT}"
    log_message "INFO" "Encryption process completed successfully: $success_count success, $error_count errors"
elif [[ $error_count -gt 0 ]]; then
    msg ""
    msg "${RED}❌ Encryption process completed with errors${NOFORMAT}"
    log_message "ERROR" "Encryption process completed with errors: $success_count success, $error_count errors"
else
    msg ""
    msg "${ORANGE}ℹ️  No files were processed${NOFORMAT}"
    log_message "INFO" "No files were processed"
fi

msg ""
msg "💡 ${CYAN}Next Steps:${NOFORMAT}"
msg "   • Verify encrypted files work as expected"
msg "   • Store passphrases/keys securely"
msg "   • Delete backup files when no longer needed"
msg "   • Check log file: $LOG_FILE"
msg ""

if [[ "$encryption_method" == "symmetric" ]]; then
    msg "🔓 To decrypt a file (symmetric):"
    msg "   gpg --output original_filename --decrypt encrypted_filename.gpg"
elif [[ "$encryption_method" == "asymmetric" ]]; then
    msg "🔓 To decrypt a file (asymmetric):"
    msg "   gpg --output original_filename --decrypt encrypted_filename.gpg"
fi

cleanup
