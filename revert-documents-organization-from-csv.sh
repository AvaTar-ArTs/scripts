#!/usr/bin/env bash

# Revert Documents Organization Script
# Generated on 2025-10-14 21:05:06
# CSV File: /Users/steven/Documents_ORGANIZATION_MAPPING_20251014_210506.csv

set -euo pipefail

CSV_FILE="/Users/steven/Documents_ORGANIZATION_MAPPING_20251014_210506.csv"
DOCUMENTS_DIR="/Users/steven/Documents"

print_info() {
    echo "ℹ️  $1"
}

print_success() {
    echo "✅ $1"
}

print_error() {
    echo "❌ $1"
}

print_warning() {
    echo "⚠️  $1"
}

if [[ ! -f "$CSV_FILE" ]]; then
    print_error "CSV mapping file not found: $CSV_FILE"
    exit 1
fi

print_info "Reverting Documents organization using: $CSV_FILE"

# Change to Documents directory
cd "$DOCUMENTS_DIR"

# Read CSV and revert moves (in reverse order)
tail -n +2 "$CSV_FILE" | tail -r | while IFS=',' read -r original_path new_path item_type category move_date size_bytes description; do
    # Unescape paths
    original_path=$(echo "$original_path" | sed 's/\\,/,/g')
    new_path=$(echo "$new_path" | sed 's/\\,/,/g')
    
    if [[ -e "$new_path" ]]; then
        print_info "Reverting: $(basename "$original_path")"
        mv "$new_path" "$original_path"
        print_success "Reverted: $(basename "$original_path")"
    else
        print_warning "Target not found: $new_path"
    fi
done

print_success "Revert completed!"
print_info "All items have been moved back to their original locations"
