#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail


# Create a temporary directory to work in
mkdir -p "/Users/steven/claude-Convos/cursor-workspaces-temp"

# Find all claude-code-chat directories and move them with unique names
for dir in /Users/steven/Library/Application\ Support/Cursor/User/workspaceStorage/*/AndrePimenta.claude-code-chat; do
  if [ -d "$dir" ]; then
    # Get the parent directory name to create a unique identifier
    parent_dir=$(basename $(dirname "$dir"))
    new_name="${parent_dir}_AndrePimenta.claude-code-chat"
    echo "Moving $dir to /Users/steven/claude-Convos/cursor-workspaces-temp/$new_name"
    mv "$dir" "/Users/steven/claude-Convos/cursor-workspaces-temp/$new_name"
  fi
done

echo "All directories moved with unique names."
