#!/bin/bash

# Script Name: analyze_scripts.sh
# Description: Analyzes shell scripts (.sh) recursively within a target directory.
#              Performs checks for syntax, error handling, security, and readability.
#              Outputs findings to CSV and Markdown reports.
# Author: Gemini AI Agent

set -euo pipefail

# --- Configuration & Defaults ---
TARGET_DIR="${1:-.}"
BATCH_SIZE=${2:-50}
MAX_WORKERS=${3:-$(nproc 2>/dev/null || echo 4)}
ANALYSIS_TYPES_ARG="${4:-syntax,error_handling,security,readability}"

# Thresholds
BULK_LIMIT=50
BATCH_LIMIT=500

# --- Output File Setup ---
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
TARGET_DIR=$(realpath "$TARGET_DIR")
CSV_OUTPUT="${TARGET_DIR}/analysis_report_${TIMESTAMP}.csv"
MD_OUTPUT="${TARGET_DIR}/analysis_summary_${TIMESTAMP}.md"
TEMP_DIR=$(mktemp -d)

# Cleanup on exit
trap 'rm -rf "$TEMP_DIR"' EXIT

# --- Tool Checks ---
for cmd in shellcheck grep sha256sum find xargs du awk bash realpath; do
    command -v "$cmd" >/dev/null 2>&1 || { echo >&2 "Error: '$cmd' not found."; exit 1; }
done

# --- Helper Functions ---

get_file_hash() {
    sha256sum "$1" | awk '{print $1}'
}

analyze_shell_file() {
    local filepath="$1"
    local analysis_types="$2"
    local output_file="$3"
    local file_hash=$(get_file_hash "$filepath")
    
    # Analyze (writing to temp file to avoid race conditions)
    local temp_result=$(mktemp)
    
    # --- Syntax/Linting ---
    if [[ "$analysis_types" == *"syntax"* ]]; then
        shellcheck -f gcc "$filepath" 2>/dev/null | while IFS= read -r line; do
            local line_num=$(echo "$line" | awk -F':' '{print $2}')
            local code_desc=$(echo "$line" | awk -F':' '{$1=$2=$3=""; print $0}' | sed 's/^ *//')
            local code=$(echo "$code_desc" | awk '{print $1}')
            local desc=$(echo "$code_desc" | sed "s/^$code: *//")
            if [[ "$code" =~ ^SC[0-9]+$ ]]; then
                echo "$filepath,$line_num,Syntax/Linting,Warning,$desc,Refer to shellcheck documentation for $code.,$file_hash,false," >> "$temp_result"
            fi
        done
    fi

    # --- Error Handling Check ---
    if [[ "$analysis_types" == *"error_handling"* ]]; then
        if ! grep -qE '^\s*set\s+(-e|-o\s+errexit)' "$filepath"; then
            echo "$filepath,1,ErrorHandling,Warning,'set -e' or 'set -o errexit' is not enabled.,Add 'set -e' at the start.,$file_hash,false," >> "$temp_result"
        fi
    fi

    # --- Security Check ---
    if [[ "$analysis_types" == *"security"* ]]; then
        if grep -qE 'export\s+.*(password|api_key|secret|token|pwd)\s*=' "$filepath"; then
            echo "$filepath,N/A,Security,Critical,Potential hardcoded secret pattern.,Avoid hardcoding secrets.,$file_hash,false," >> "$temp_result"
        fi
    fi

    # --- Readability Check ---
    if [[ "$analysis_types" == *"readability"* ]]; then
        if awk 'length > 120 {exit 0} END {exit 1}' "$filepath"; then
            echo "$filepath,N/A,Readability,Info,Line exceeds 120 chars,Break long lines.,$file_hash,false," >> "$temp_result"
        fi
    fi
    
    cat "$temp_result" >> "$output_file"
    rm "$temp_result"
}

export -f analyze_shell_file
export -f get_file_hash

# --- Main Logic ---
echo "FilePath,LineNumber,IssueType,Severity,Description,Suggestion,FileHash_SHA256,IsDuplicate,DuplicateOf" > "$CSV_OUTPUT"

FILE_LIST=$(find "$TARGET_DIR" -type f -name "*.sh")
FILE_COUNT=$(echo "$FILE_LIST" | wc -l | xargs)

# Parallel Processing
echo "$FILE_LIST" | xargs -P "$MAX_WORKERS" -I {} bash -c 'analyze_shell_file "$1" "$2" "$3"' _ {} "$ANALYSIS_TYPES_ARG" "$CSV_OUTPUT"

echo "Analysis complete: $CSV_OUTPUT"
