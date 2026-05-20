#!/usr/bin/env bash

# Exit immediately if any command exits with a non-zero status,
# treat unset variables as errors, and capture failures in pipelines
set -euo pipefail

# This script is called "list_packages.sh"
# Usage: Run ./list_packages.sh [output_file]
# A header with the current date/time is added to the output file.

OUTPUT_FILE="packages_info.txt"

# Use a command-line argument for output file if provided.
if [[ $# -ge 1 ]]; then
  OUTPUT_FILE="$1"
fi

# Clear the output file and add a header with timestamp
{
  echo "======================================"
  echo "Package List Generated on: $(date)"
  echo "======================================"
  echo ""
} > "$OUTPUT_FILE"

# Helper function to append command output to the file with headers
run_and_log() {
  local header="$1"
  local command="$2"
  
  echo "======================================" >> "$OUTPUT_FILE"
  echo "$header" >> "$OUTPUT_FILE"
  echo "======================================" >> "$OUTPUT_FILE"
  echo "" >> "$OUTPUT_FILE"
  
  # Run the command and append output; if command fails, record an error
  if eval "$command" >> "$OUTPUT_FILE" 2>> "$OUTPUT_FILE"; then
    echo "" >> "$OUTPUT_FILE"
  else
    echo "Command failed or not installed." >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
  fi
}

# 1. Homebrew: List installed and outdated packages
if command -v brew &> /dev/null; then
  run_and_log "Homebrew Installed Packages (brew list)" "brew list"
  run_and_log "Homebrew Outdated Packages (brew outdated)" "brew outdated"
else
  echo "Homebrew not installed." >> "$OUTPUT_FILE"
fi

# 2. pip (Python 2) - Only if pip2 is available
if command -v pip2 &> /dev/null; then
  run_and_log "pip2 list" "pip2 list"
fi

# 3. pip3 (Python 3)
if command -v pip3 &> /dev/null; then
  run_and_log "pip3 list" "pip3 list"
fi

# 4. Python modules using python3 (site-packages via pip list)
if command -v python3 &> /dev/null; then
  run_and_log "Python 3 - site-packages (using python3 -m pip list)" \
              "python3 -m pip list"
fi

# 5. Conda (Miniconda or Anaconda)
if command -v conda &> /dev/null; then
  run_and_log "conda list" "conda list"
fi

# 6. npm (Node.js Global Packages)
if command -v npm &> /dev/null; then
  run_and_log "npm (global) list" "npm list -g --depth=0"
fi

# 7. yarn (Global Packages)
if command -v yarn &> /dev/null; then
  run_and_log "yarn (global) list" "yarn global list --depth=0"
fi

# DONE
echo "All done. See the '$OUTPUT_FILE' file for details."
