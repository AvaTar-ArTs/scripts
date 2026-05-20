#!/usr/bin/env bash
# Test script to verify improvements to the scripts ecosystem

# Exit on error, undefined variables, and pipe failures
set -euo pipefail

# Source common utilities
source /Users/steven/scripts/utils/common_utils.sh

log_info "Starting test of improved scripts ecosystem..."

# Test logging functions
log_info "Testing INFO message"
log_success "Testing SUCCESS message"
log_warn "Testing WARNING message"
log_error "Testing ERROR message"

# Test utility functions
log_info "Testing utility functions..."

# Test require_cmd
if command_exists "bash"; then
    log_success "Command 'bash' exists"
else
    log_error "Command 'bash' does not exist"
fi

# Test timestamp function
log_info "Current timestamp: $(timestamp)"

# Test environment loading
log_info "Testing environment loading..."
load_env_d

# Test system information functions
log_info "Hostname: $(get_system_hostname)"
log_info "User: $(get_system_user)"
log_info "Date: $(get_date)"
log_info "Time: $(get_time)"

log_success "All tests completed successfully!"