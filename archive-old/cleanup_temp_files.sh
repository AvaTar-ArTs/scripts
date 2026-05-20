#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail


# Temporary file cleanup script
# This script removes various temporary files and directories

echo "Starting temporary file cleanup..."

# Counters for tracking what we remove
tmp_files_count=0
tmp_dirs_count=0

echo "Removing *.tmp files..."
for file in $(find /Users/steven -name "*.tmp" -type f 2>/dev/null); do
  if [[ "$file" != *"cleanup_temp_files.sh"* ]]; then
    rm -f "$file"
    ((tmp_files_count++))
    echo "Removed: $file"
  fi
done

echo "Removing .tmp* files..."
for file in $(find /Users/steven -name ".tmp*" -type f 2>/dev/null); do
  if [[ "$file" != *"cleanup_temp_files.sh"* ]]; then
    rm -f "$file"
    ((tmp_files_count++))
    echo "Removed: $file"
  fi
done

echo "Removing tmp directories (excluding node_modules and similar dependencies)..."
for dir in $(find /Users/steven -type d -name "tmp" 2>/dev/null); do
  # Skip if it's inside node_modules, .git, or similar important directories
  if [[ ! "$dir" =~ (node_modules|\.git|vendor|target|dist|build|\.nvm|\.rbenv) ]]; then
    rm -rf "$dir"
    ((tmp_dirs_count++))
    echo "Removed directory: $dir"
  fi
done

echo "Removing temp directories (excluding node_modules and similar dependencies)..."
for dir in $(find /Users/steven -type d -name "temp" 2>/dev/null); do
  # Skip if it's inside node_modules, .git, or similar important directories
  if [[ ! "$dir" =~ (node_modules|\.git|vendor|target|dist|build|\.nvm|\.rbenv) ]]; then
    rm -rf "$dir"
    ((tmp_dirs_count++))
    echo "Removed directory: $dir"
  fi
done

echo ""
echo "Cleanup completed!"
echo "Files removed: $tmp_files_count"
echo "Directories removed: $tmp_dirs_count"
echo ""
echo "Note: Some temporary files in protected directories (like node_modules, .git, etc.) were not removed."
