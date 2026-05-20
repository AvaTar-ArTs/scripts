#!/usr/bin/env bash
# Script to standardize shebang lines across all scripts

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

# Find all shell scripts and standardize shebangs
log_info "Standardizing shebang lines in $SCRIPTS_DIR..."

while IFS= read -r -d '' script; do
    # Skip the utility scripts directory and this script itself
    if [[ "$script" == *"/utils/"* ]] || [[ "$script" == *"/standardize_shebangs.sh" ]]; then
        continue
    fi
    
    # Check if it's a shell script by looking at the first line
    first_line=$(head -n 1 "$script" 2>/dev/null || true)
    
    if [[ "$first_line" =~ ^#! ]]; then
        # Determine the correct shebang based on the script type
        if [[ "$first_line" =~ \bzsh\b ]]; then
            correct_shebang="#!/usr/bin/env zsh"
        elif [[ "$first_line" =~ \bpython3?\b ]]; then
            # For Python scripts, keep the python shebang
            continue
        elif [[ "$first_line" =~ \bsh\b ]]; then
            correct_shebang="#!/usr/bin/env sh"
        else
            # Default to bash for shell scripts
            correct_shebang="#!/usr/bin/env bash"
        fi
        
        # Only update if the shebang is different
        if [[ "$first_line" != "$correct_shebang" ]]; then
            log_info "Updating shebang in: $script"
            log_info "  From: $first_line"
            log_info "  To:   $correct_shebang"
            
            # Create a backup
            cp "$script" "$TEMP_DIR/$(basename "$script").bak"
            
            # Update the shebang
            rest_of_file=$(tail -n +2 "$script")
            {
                echo "$correct_shebang"
                echo "$rest_of_file"
            } > "$script"
            
            log_success "Updated: $script"
        fi
    fi
done < <(find "$SCRIPTS_DIR" -name "*.sh" -print0)

log_info "Completed standardizing shebang lines."
log_info "Backups of modified files are in: $TEMP_DIR"