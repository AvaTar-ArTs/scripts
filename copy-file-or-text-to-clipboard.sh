#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail

# Copy file content to clipboard or copy text directly

INPUT="$1"

if [ -f "$INPUT" ]; then
    # It's a file path - copy file contents
    cat "$INPUT" | pbcopy
    echo "Copied file contents to clipboard"
else
    # It's direct text - copy it
    echo "$INPUT" | pbcopy
    echo "Copied to clipboard"
fi
