#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail


# Directories
mp3_dir="$1"
img_dir="$2"
output_dir="$3"

# Create output directory if it doesn't exist
mkdir -p "$output_dir"

# Loop through all MP3 files in the mp3 directory
for mp3_file in "$mp3_dir"/*.mp3; do
    # Get the base name of the MP3 file
    base_name=$(basename "$mp3_file" .mp3)
    
    # Find corresponding image file
    img_file_jpg="$img_dir/$base_name.jpg"
    img_file_png="$img_dir/$base_name.png"
    
    # Determine if image file exists
    if [[ -f "$img_file_jpg" ]]; then
        img_file="$img_file_jpg"
    elif [[ -f "$img_file_png" ]]; then
        img_file="$img_file_png"
    else
        echo "No image found for $base_name, skipping..."
        continue
    fi
    
    # Define output file name
    output_file="$output_dir/$base_name.mp4"
    
    # Convert MP3 to MP4 with image
    ffmpeg -loop 1 -i "$img_file" -i "$mp3_file" -c:v libx264 -c:a aac -b:a 192k -shortest "$output_file"
    
    echo "Converted $mp3_file to $output_file"
done
