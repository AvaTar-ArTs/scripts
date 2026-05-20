#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail


# Color coding for outputs
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
CLEAR='\033[0m'

# Function to process images in the directory
process-images() {
    local input_dir=$1
    local output_dir=$2
    local scale_factor=2
    local dpi=300

    setopt nullglob # Avoid errors if no files match the pattern

    # Ensure output directory exists
    mkdir -p "$output_dir"

    for file in "$input_dir"/*.{jpg,jpeg,png,bmp,gif}; do
        if [ -f "$file" ]; then
            filename=$(basename "$file")
            output_path="$output_dir/$filename"

            # Get current width and height
            width=$(sips -g pixelWidth "$file" | awk '/pixelWidth:/{print $2}')
            height=$(sips -g pixelHeight "$file" | awk '/pixelHeight:/{print $2}')

            # Calculate new dimensions
            new_width=$((width * scale_factor))
            new_height=$((height * scale_factor))

            # Copy the original image to the output directory
            cp "$file" "$output_path"

            # Resize the image and set new DPI
            sips --resampleWidth $new_width --setProperty dpiWidth $dpi --setProperty dpiHeight $dpi "$output_path"
            echo -e "${GREEN}Processed \"$filename\"${CLEAR}"
        else
            echo -e "${YELLOW}No image files found in the directory.${CLEAR}"
        fi
    done
}

# Example usage
input_dir="/Users/steven/Pictures/City"
output_dir="/Users/steven/Pictures/City"
process-images "$input_dir" "$output_dir"
