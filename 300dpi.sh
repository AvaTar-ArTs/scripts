#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail


# Function to convert and set DPI for images
convert_and_set_dpi() {
    local input_file="$1"
    local output_file="$2"
    local format="$3"

    # Use ImageMagick's convert tool to process the image
    convert "$input_file" -density 300 "$output_file"
    echo "Converted $input_file to $output_file with DPI set to 300"
}

# Directories to process
directories=(
    "/Users/steven/Pictures"
)

# Loop through each directory
for dir in "${directories[@]}"; do
    echo "Processing directory: $dir"

    # Find and process .webp and .tiff files
    find "$dir" -type f \( -iname "*.webp" -o -iname "*.tiff" -o -iname
"*.tif" \) | while read -r file; do
        # Check file size (in bytes)
        file_size=$(stat -c%s "$file")
        max_size=$((8 * 1024 * 1024)) # 8 MB in bytes

        if (( file_size > max_size )); then
            echo "Skipping $file due to file size > 8MB"
            continue
        fi

        # Determine the output file format and name
        if [[ "$file" == *.webp ]]; then
            output_file="${file%.*}.jpg"
            format="JPEG"
        else
            output_file="${file%.*}.png"
            format="PNG"
        fi

        # Convert the file and set DPI
        convert_and_set_dpi "$file" "$output_file" "$format"

        # Remove the original file
        rm "$file"
        echo "Removed original file $file"
    done
done

echo "Image processing complete."
