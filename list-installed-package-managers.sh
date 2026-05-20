#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail


# This script is called "list_packages.sh"
# Usage: Run ./list_packages.sh (make it executable with chmod +x list_packages.sh)
# Output will be stored in packages_info.txt

OUTPUT_FILE="packages_info.txt"

# First, clear the output file if it already exists
> "$OUTPUT_FILE"

# Helper function to append command output to the file with headers
run_and_log() {
  local header="${1}"
  local command="${2}"
  echo "======================================" >> "$OUTPUT_FILE"
  echo "$header" >> "$OUTPUT_FILE"
  echo "======================================" >> "$OUTPUT_FILE"
  echo "" >> "$OUTPUT_FILE"
  # Run the command and append output; if command fails, record an error
  eval "$command" >> "$OUTPUT_FILE" 2>>"$OUTPUT_FILE" || echo "Command failed or not installed." >> "$OUTPUT_FILE"
  echo -e "\n" >> "$OUTPUT_FILE"
}

# 1. Homebrew
run_and_log "Homebrew Installed Packages (brew list)" "brew list"
run_and_log "Homebrew Outdated Packages (brew outdated)" "brew outdated"

# 2. pip (Python 2) - only if pip2 is available
if command -v pip2 &> /dev/null; then
  run_and_log "pip2 list" "pip2 list"
fi

# 3. pip3 (Python 3)
if command -v pip3 &> /dev/null; then
  run_and_log "pip3 list" "pip3 list"
fi

# 4. Python modules (if you want Python’s built-in site-packages, etc.)
#   Many use pip3 list or pip freeze, but here's an optional direct python3 approach:
if command -v python3 &> /dev/null; then
  run_and_log "Python 3 - site packages" "python3 -m pip list"
fi

# 5. Conda (Miniconda or Anaconda)
if command -v conda &> /dev/null; then
  run_and_log "conda list" "conda list"
fi

# 6. npm (Node.js)
if command -v npm &> /dev/null; then
  # --depth=0 to show top-level/generally installed packages without dependency trees
  run_and_log "npm (global) list" "npm list -g --depth=0"
fi

# 7. yarn
if command -v yarn &> /dev/null; then
  run_and_log "yarn (global) list" "yarn global list --depth=0"
fi

# DONE
echo "All done. See the '$OUTPUT_FILE' file for details."
