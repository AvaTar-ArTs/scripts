#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail


# Directory to check for existing files
target_directory="/Users/steven/Pictures/Leo"

# File containing URLs
url_file="/Users/steven/leo-img.txt"

# Read each URL from the file
while IFS= read -r url; do
  # Extract the filename from the URL
  filename=$(basename "$url")
  
  # Check if the file already exists in the target directory
  if [[ ! -f "$target_directory/$filename" ]]; then
    echo "Downloading $filename to $target_directory..."
    # Use curl to download the file to the target directory
    curl -o "$target_directory/$filename" "$url"
  else
    echo "$filename already exists in $target_directory, skipping..."
  fi
done < "$url_file"
