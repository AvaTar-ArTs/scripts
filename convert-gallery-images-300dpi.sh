#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail


# Enable nullglob to avoid errors when no files match the pattern
setopt nullglob

input_dir="/Users/steven/dalle/dalle-gallery/image"
output_dir="/Users/steven/dalle/dalle-gallery/converted"

# Ensure the output directory exists
mkdir -p "$output_dir"

# Size limit in bytes (8 MB)
size_limit=$((8 * 1024 * 1024))

for filepath in "$input_dir"/*.png; do
  if [ -f "$filepath" ]; then
    filename=$(basename "$filepath" | cut -f 1 -d '.')
    output_path="$output_dir/$filename.png"

    # Convert WEBP to PNG with 300 DPI using "magick convert"
    magick convert "$filepath" -units PixelsPerInch -density 300 "$output_path"

    # Check the file size and resize if it exceeds the limit
    file_size=$(stat -f%z "$output_path")
    if [ $file_size -gt $size_limit ]; then
      echo "Resizing $output_path to meet the 8MB size limit"

      # Reduce the image quality by 10% increments until the file size is within the limit
      quality=90
      while [ $file_size -gt $size_limit ] && [ $quality -gt 10 ]; do
        magick convert "$output_path" -quality $quality "$output_path"
        file_size=$(stat -f%z "$output_path")
        quality=$((quality - 10))
      done

      # If still too large, resize the dimensions to further reduce size
      if [ $file_size -gt $size_limit ]; then
        magick convert "$output_path" -resize 90% "$output_path"
        file_size=$(stat -f%z "$output_path")
      fi
    fi

    echo "Converted $filepath to $output_path, final size: $file_size bytes"
  fi
done

# Disable nullglob after script execution
unsetopt nullglob
