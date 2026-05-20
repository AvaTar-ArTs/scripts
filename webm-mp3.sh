#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail


# Input and output directories (set to the same directory for simplicity)
input_dir="/Users/steven/Music/NocTurnE-meLoDieS/song-video/mp3"
output_dir="$input_dir"  # Save the MP3 files in the same directory as the WEBM files

# Loop through all .webm files in the input directory
for filepath in "$input_dir"/*.webm; do  
  if [ -f "$filepath" ]; then 
    # Extract the base filename (without extension)
    filename=$(basename "$filepath" | cut -f 1 -d '.')
    output_path="$output_dir/$filename.mp3"

    # Convert WEBM to MP3 using ffmpeg
    ffmpeg -i "$filepath" -vn -acodec libmp3lame -q:a 2 "$output_path"

    echo "Converted $filepath to $output_path"
  fi
done

echo "All conversions complete."
