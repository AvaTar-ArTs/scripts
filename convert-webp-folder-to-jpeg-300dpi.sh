#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail


input_dir="/Users/steven/Pictures/etsy/ideogram-to-sell"

for filepath in "$input_dir"/*.webp; do
  if [ -f "$filepath" ]; then
    # Extract filename without extension
    filename=$(basename "$filepath" .webp)
    
    # Define the output path in the same folder but with .jpeg extension
    output_path="$input_dir/$filename.jpeg"
    
    # Convert WEBP to JPEG with 300 DPI resolution     
    convert "$filepath" -units PixelsPerInch -density 300 "$output_path"

    echo "Converted and upscaled $filepath to $output_path with 300 DPI"
  fi
done
