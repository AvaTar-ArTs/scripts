#!/usr/bin/env bash
# Script to generate advanced meta CSV for ~/scripts directory

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
    echo -e "${RED}[ERROR]${NC} $*" >&2
}

SCRIPTS_DIR="$HOME/scripts"
PYTHON_SCRIPT="$SCRIPTS_DIR/generate_advanced_meta_csv.py"
OUTPUT_FILE="$SCRIPTS_DIR/advanced_scripts_meta.csv"

log_info "Starting advanced meta CSV generation for ~/scripts directory..."

if [[ ! -f "$PYTHON_SCRIPT" ]]; then
    log_error "Python script not found: $PYTHON_SCRIPT"
    exit 1
fi

if [[ ! -d "$SCRIPTS_DIR" ]]; then
    log_error "Scripts directory not found: $SCRIPTS_DIR"
    exit 1
fi

log_info "Running Python script to generate advanced meta CSV..."
python3 "$PYTHON_SCRIPT"

if [[ -f "$OUTPUT_FILE" ]]; then
    log_success "Advanced meta CSV generated successfully: $OUTPUT_FILE"
    
    # Show basic statistics
    ROW_COUNT=$(wc -l < "$OUTPUT_FILE")
    log_info "Total rows in CSV (including header): $ROW_COUNT"
    
    # Show first few rows as sample
    log_info "Sample of generated CSV:"
    head -n 5 "$OUTPUT_FILE"
else
    log_error "Failed to generate advanced meta CSV"
    exit 1
fi

log_success "Advanced meta CSV generation completed!"