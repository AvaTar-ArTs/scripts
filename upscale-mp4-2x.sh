#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail


# Prompt for the source directory containing MP4 videos
read -p "Enter the source directory for MP4 videos: " input_directory

# Trim any trailing/leading spaces or hidden characters from the input
input_directory=$(echo "$input_directory" | xargs)

# Print the directory for debugging
echo "Directory entered: '$input_directory'"

# Validate if the source directory exists and is accessible
if [ ! -d "$input_directory" ]; then
  echo "Source directory not found. Please provide a valid directory 
path."
  exit 1
fi

# Loop through all MP4 files in the source directory
# Use a while loop with IFS to handle filenames with spaces and special 
characters
find "$input_directory" -type f -name "*.mp4" | while IFS= read -r file; 
do
  # Check if the file exists
  if [ ! -f "$file" ]; then
    echo "No MP4 files found in the directory."
    continue  # Continue to the next iteration instead of exiting
  fi

  # Get the original resolution
  original_resolution=$(ffmpeg -i "$file" 2>&1 | grep -oP ', \K\d+x\d+')

  # Calculate the upscaled resolution (2x)
  width=$(echo "$original_resolution" | cut -d'x' -f1)
  height=$(echo "$original_resolution" | cut -d'x' -f2)
  upscale_width=$((width * 2))
  upscale_height=$((height * 2))

  # Print the original and upscaled resolutions
  echo "Original resolution: $original_resolution"
  echo "Upscaled resolution: ${upscale_width}x${upscale_height}"

  # Upscale the video using ffmpeg
  output_file="$input_directory/upscaled_$(basename "$file")"
  ffmpeg -i "$file" -vf scale=${upscale_width}:${upscale_height} -c:v 
libx264 -crf 23 -preset medium -c:a copy "$output_file"

  # Get the new file size
  new_size=$(stat -c%s "$output_file")
  echo "Upscaled file size: $(($new_size / 1024 / 1024)) MB"

done

echo "Upscaling completed."
