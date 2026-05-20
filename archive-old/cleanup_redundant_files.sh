#!/usr/bin/env bash
# Script to clean up redundant and backup files

set -euo pipefail

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

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

SCRIPTS_DIR="/Users/steven/scripts"

# Find and list potentially redundant files before deletion
log_info "Looking for redundant and backup files in $SCRIPTS_DIR..."

# Find backup files with timestamps in the name
log_info "Finding timestamped backup files..."
find "$SCRIPTS_DIR" -name "*_[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]_*" -type f -print

# Find files with 'copy' in the name
log_info "Finding files with 'copy' in the name..."
find "$SCRIPTS_DIR" -name "*copy*" -type f -print

# Find files with 'backup' in the name
log_info "Finding files with 'backup' in the name..."
find "$SCRIPTS_DIR" -name "*backup*" -type f -print

# Find duplicate files with slightly different names
log_info "Finding potential duplicate files..."
find "$SCRIPTS_DIR" -name "*.sh" -exec basename {} \; | sort | uniq -d

# Actually perform the cleanup
log_info "Performing cleanup..."

# Remove backup files with timestamp patterns
find "$SCRIPTS_DIR" -name "*_[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]_*" -type f -delete
log_success "Deleted timestamped backup files"

# Remove files with 'backup' in the name (but not directories)
find "$SCRIPTS_DIR" -maxdepth 1 -name "*backup*" -type f -delete
log_success "Deleted files with 'backup' in the name"

# Note: We won't delete files with 'copy' in the name as they might be intentional
log_info "Preserved files with 'copy' in the name (please review manually)"

# Clean up old script backup directory if it exists
if [[ -d "$SCRIPTS_DIR/.script-fixes-backup-20260211_190647" ]]; then
    log_info "Removing old backup directory..."
    rm -rf "$SCRIPTS_DIR/.script-fixes-backup-20260211_190647"
    log_success "Removed old backup directory"
fi

log_info "Cleanup completed."