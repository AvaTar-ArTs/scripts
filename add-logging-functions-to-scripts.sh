#!/usr/bin/env bash
# Script to improve logging consistency across scripts

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

# Find all shell scripts and add logging functions if needed
log_info "Improving logging consistency in $SCRIPTS_DIR..."

# Counter for updated scripts
updated_count=0

while IFS= read -r -d '' script; do
    # Skip the utility scripts directory and this script itself
    if [[ "$script" == *"/utils/"* ]] || [[ "$script" == *"/improve_logging.sh" ]]; then
        continue
    fi
    
    # Check if the script already has logging functions
    if grep -q "log_info\|log_success\|log_warn\|log_error" "$script"; then
        continue
    fi
    
    # Check if it's a shell script by looking at the shebang
    if head -1 "$script" 2>/dev/null | grep -q -E "^#!.*\b(bash|sh|zsh)\b"; then
        log_info "Adding logging functions to: $script"
        
        # Create a backup
        cp "$script" "$TEMP_DIR/$(basename "$script").bak"
        
        # Read the entire file
        script_content=$(cat "$script")
        
        # Write the file back with logging functions added after the shebang
        first_line=$(head -n 1 "$script")
        rest_of_content=$(tail -n +2 "$script")
        
        {
            echo "$first_line"
            echo ""
            echo "# Logging functions for consistent output"
            echo "log_info() {"
            echo "    echo -e \"\\033[0;34m[INFO]\\033[0m \$*\""
            echo "}"
            echo ""
            echo "log_success() {"
            echo "    echo -e \"\\033[0;32m[SUCCESS]\\033[0m \$*\""
            echo "}"
            echo ""
            echo "log_warn() {"
            echo "    echo -e \"\\033[1;33m[WARN]\\033[0m \$*\""
            echo "}"
            echo ""
            echo "log_error() {"
            echo "    echo -e \"\\033[0;31m[ERROR]\\033[0m \$*\" >&2"
            echo "}"
            echo ""
            echo "$rest_of_content"
        } > "$script"
        
        ((updated_count++))
        log_success "Updated: $script"
    fi
done < <(find "$SCRIPTS_DIR" -name "*.sh" -print0)

log_info "Completed adding logging functions to $updated_count scripts."
log_info "Backups of modified files are in: $TEMP_DIR"