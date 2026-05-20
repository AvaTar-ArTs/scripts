#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail


# Directory containing the webp files
input_dir="/Users/steven/Documents/FileJuicer/de6a2e87-5ba5-4c58-bff4-d35fc090548a_Ideogram-Tshirt Juice-1/tiff"

# Loop through all .webp files in the input directory
for filepath in "$input_dir"/*.tiff; do
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
