#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail


# Prompt for the source directory containing MP4 videos
read -p "Enter the source directory for MP4 videos: " input_directory

# Trim any trailing/leading spaces or hidden characters from the input
input_directory=$(echo "$input_directory" | xargs)

# Validate if the source directory exists
if [ ! -d "$input_directory" ]; then
  echo "Source directory not found. Please provide a valid directory 
path."
  exit 1
fi

# Set the desired output resolution to 1080x1920
resolution="1080x1920"

# Loop through all MP4 files in the source directory
for file in "$input_directory"/*.mp4; do
  # Check if the file exists
  if [ ! -f "$file" ]; then
    echo "No MP4 files found in the directory."
    exit 1
  fi

  # Get the original file size
  original_size=$(stat -c%s "$file")
  echo "Original size of $file: $(($original_size / 1024 / 1024)) MB"

  # Compress and resize the video to 1080x1920 using ffmpeg
  output_file="compressed_$(basename "$file")"
  ffmpeg -i "$file" -vf scale=$resolution -c:v libx264 -crf 23 -preset 
medium -c:a copy "$input_directory/$output_file"

  # Get the new file size
  new_size=$(stat -c%s "$input_directory/$output_file")
  echo "New size of $output_file: $(($new_size / 1024 / 1024)) MB"

done

echo "Compression and resizing completed."
