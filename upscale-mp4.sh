#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail


# Prompt the user for the source directory containing videos
read -p "Enter the source directory: " input_directory

# Prompt the user for the destination directory for converted and upscaled videos
read -p "Enter the destination directory: " output_directory

# Desired scaling factor (e.g., 2 for doubling the size)
scaling_factor=2

# Create the output directory if it doesn't exist
mkdir -p "$output_directory"

# Convert non-.mp4 videos to .mp4 format
find "$input_directory" -type f ! -name "*.mp4" -exec ffmpeg -i {} -c:v libx264 -crf 23 -c:a aac -strict experimental -b:a 192k "$output_directory/{}.mp4" \;

# Upscale all .mp4 videos in the source directory and its subfolders
find "$input_directory" -type f -name "*.mp4" | while read -r video; do
  # Get the file name without extension
  filename=$(basename -- "$video")
  filename_noext="${filename%.*}"

  # Upscale the video and save it to the destination directory
  ffmpeg -i "$video" -vf "scale=iw*$scaling_factor:ih*$scaling_factor" "$output_directory/$filename_noext-upscaled.mp4"
done

echo "Conversion and upscaling completed."
