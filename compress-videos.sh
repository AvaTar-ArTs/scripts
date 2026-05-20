#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail


# Prompt for the input folder
read -rp "Enter the full path of the folder containing videos: " input_folder
input_folder="${input_folder%/}"  # Remove trailing slash if exists

# Generate output folder with today's date
timestamp=$(date +"%m-%d-%y")
output_folder="${input_folder}/_c-${timestamp}/"
mkdir -p "$output_folder"

# Loop through all MP4 files in the folder
for file in "$input_folder"/*.mp4; do
    filename=$(basename "$file")
    output_file="${output_folder}${filename%.*}_c.mp4"

    echo "🔄 Compressing: $filename → $output_file"

    ffmpeg -i "$file" \
    -vf "scale=640:-2,format=yuv420p" -c:v h264_videotoolbox -b:v 500k -r 24 -c:a aac -b:a 64k -ac 1 \
    -map_metadata 0 -map_chapters 0 -movflags use_metadata_tags \
    -y "$output_file"

    echo "✅ Done: $filename → $(du -h "$output_file" | cut -f1)"
done

echo "🎉 All videos processed!"
echo "📁 Compressed files are in: $output_folder"
