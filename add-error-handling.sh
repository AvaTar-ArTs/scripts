#!/usr/bin/env bash
# Script to add error handling to scripts that don't have it

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
TEMP_DIR=$(mktemp -d)

# Find all shell scripts
log_info "Finding all shell scripts in $SCRIPTS_DIR..."

while IFS= read -r -d '' script; do
    # Skip the utility scripts directory and this script itself
    if [[ "$script" == *"/utils/"* ]] || [[ "$script" == *"/add_error_handling.sh" ]]; then
        continue
    fi
    
    # Check if the script already has error handling
    if grep -q "set -e\|set -u\|set -o pipefail" "$script"; then
        continue
    fi
    
    # Check if it's a shell script by looking at the shebang
    if head -1 "$script" | grep -q -E "^#!.*\b(bash|sh|zsh)\b"; then
        log_info "Adding error handling to: $script"
        
        # Create a backup
        cp "$script" "$TEMP_DIR/$(basename "$script").bak"
        
        # Read the first line (shebang)
        first_line=$(head -n 1 "$script")
        
        # Read the rest of the file
        rest_of_file=$(tail -n +2 "$script")
        
        # Write the file back with error handling after the shebang
        {
            echo "$first_line"
            echo ""
            echo "# Exit on error, undefined variables, and pipe failures"
            echo "set -euo pipefail"
            echo ""
            echo "$rest_of_file"
        } > "$script"
        
        log_success "Updated: $script"
    fi
done < <(find "$SCRIPTS_DIR" -name "*.sh" -print0)

log_info "Completed adding error handling to scripts."
log_info "Backups of modified files are in: $TEMP_DIR"