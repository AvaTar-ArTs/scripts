#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail


# Prompt the user for the source directory
read -p "Enter the source directory containing MP3 files: " SOURCE_DIR

# Prompt the user for the destination directory
read -p "Enter the destination directory for MP4 files: " DEST_DIR

# Prompt the user for the image file to use as the video background
read -p "Enter the full path to the image file: " IMAGE

# Check if the source directory exists
if [[ ! -d "$SOURCE_DIR" ]]; then
    echo "Source directory $SOURCE_DIR does not exist!"
    exit 1
fi

# Check if the destination directory exists; if not, create it
if [[ ! -d "$DEST_DIR" ]]; then
    mkdir -p "$DEST_DIR"
    echo "Created destination directory $DEST_DIR"
fi

# Check if the image file exists
if [[ ! -f "$IMAGE" ]]; then
    echo "Image file $IMAGE not found!"
    exit 1
fi

# Find all MP3 files in the source directory and its subdirectories
find "$SOURCE_DIR" -type f -name "*.mp3" | while read -r file; do
    # Extract the base name of the file
    base_name=$(basename "${file%.mp3}")
    
    # Define the output MP4 file path
    output="$DEST_DIR/$base_name.mp4"
    
    # Convert MP3 to MP4 using the image as the video background
    ffmpeg -loop 1 -i "$IMAGE" -i "$file" -c:v libx264 -c:a aac -b:a 192k -shortest "$output"
    
    # Print a message indicating the file has been processed
    echo "Converted $file to $output"
done

echo "Batch conversion complete."
