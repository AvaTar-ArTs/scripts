#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail


# Function to set DPI for images
set_dpi() {
    local input_file="$1"
    local output_file="$2"
    
    # Use ImageMagick's convert tool to set the DPI to 300
    convert "$input_file" -density 300 "$output_file"
    echo "Set DPI for $input_file to $output_file"
}

# Directories to process
directories=(
    "/Users/steven/Pictures/DaLL-E/9-16"
    "/Users/steven/Pictures/DaLL-E/1-1"
    "/Users/steven/Pictures/DaLL-E/16-9"
)

# Loop through each directory
for dir in "${directories[@]}"; do
    echo "Processing directory: $dir"
    
    # Find and process .png and .jpg files
    find "$dir" -type f \( -iname "*.png" -o -iname "*.jpg" -o -iname 
"*.jpeg" \) | while read -r file; do
        # Check file size (in bytes)
        file_size=$(stat -c%s "$file")
        max_size=$((8 * 1024 * 1024)) # 8 MB in bytes

        if (( file_size > max_size )); then
            echo "Skipping $file due to file size > 8MB"
            continue
        fi

        # Set DPI for the file
        output_file="${file%.*}-300dpi.${file##*.}"
        set_dpi "$file" "$output_file"
        
        # Optionally, you can replace the original file with the new one
        mv "$output_file" "$file"
        echo "Replaced original file with 300 DPI version: $file"
    done
done

echo "Image processing complete."
