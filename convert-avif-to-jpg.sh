#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail


# Define the input directory
input_dir="/Users/steven/Pictures/etsy/MyDesign-IMGs/img"

# Navigate to the input directory
cd "$input_dir" || exit

# Enable NULL_GLOB to prevent errors if no files match
shopt -s nullglob

# Loop through all .avif files in the directory
for filepath in "$input_dir"/*.avif; do
  if [ -f "$filepath" ]; then
    # Extract filename without extension
    filename=$(basename "$filepath" .avif)
    # Define the output path with .jpg extension
    output_path="$input_dir/$filename.jpg"
    
    # Convert AVIF to JPEG
    convert "$filepath" "$output_path"
    
    echo "Converted $filepath to $output_path"
  fi
done
