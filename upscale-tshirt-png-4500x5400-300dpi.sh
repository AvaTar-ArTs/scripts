#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail


# Input and output directories
input_dir="/Users/steven/Pictures/Tshirt/Untitled design"
output_dir="/Users/steven/Pictures/Tshirt/Untitled design/upscaled_4500x5400_300dpi"

# Create the output directory if it doesn't exist
mkdir -p "$output_dir"

# Loop through all PNG files in the input directory
for file in "$input_dir"/*.png; do
    if [ -f "$file" ]; then
        # Get the filename
        filename=$(basename "$file")
        
        # Resize the PNG image to exactly 4500x5400 and set the DPI to 300
        magick "$file" -resize 4500x5400! -density 300 "$output_dir/$filename"
        
        echo "Processed and saved: $output_dir/$filename"
    else
        echo "No PNG files found in $input_dir."
    fi
done

echo "All PNG images have been processed."
