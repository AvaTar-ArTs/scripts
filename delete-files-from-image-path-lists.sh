#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail


# List of files containing paths to be deleted
FILES=(
  "/Users/steven/Sort/image_paths.csv"
  "/Users/steven/Sort/ImageScan-618.csv"
  "/Users/steven/Sort/image_paths.txt"
)

# Function to process each file and delete the listed paths
process_file() {
  local file_path=$1
  # Check if the file exists
  if [[ ! -f "$file_path" ]]; then
    echo "File not found: $file_path"
    return
  fi

  # Determine the file extension
  case "$file_path" in
    *.csv)
      while IFS=, read -r path; do
        # Check if the file exists before attempting to delete
        if [[ -f "$path" ]]; then
          echo "Deleting file: $path"
          rm "$path"
        else
          echo "File not found: $path"
        fi
      done < "$file_path"
      ;;
    *.txt)
      while IFS= read -r path; do
        # Check if the file exists before attempting to delete
        if [[ -f "$path" ]]; then
          echo "Deleting file: $path"
          rm "$path"
        else
          echo "File not found: $path"
        fi
      done < "$file_path"
      ;;
    *)
      echo "Unsupported file format: $file_path"
      ;;
  esac
}

# Process each file
for file in "${FILES[@]}"; do
  process_file "$file"
done

echo "File deletion completed."
