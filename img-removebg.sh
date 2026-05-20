#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail


# Ask for the source directory
read -p "Enter the path to the source directory: " IMAGE_DIR

# Ask for the destination directory
read -p "Enter the path to the destination directory: " DEST_DIR

# Create the destination directory if it doesn't exist
mkdir -p "$DEST_DIR"

# Loop through each file in the source directory
for image in "$IMAGE_DIR"/*; do
    # Extract the filename without extension
    filename=$(basename -- "$image")
    filename="${filename%.*}"

    # Specify the output file in the destination directory
    output="$DEST_DIR/${filename}_nobg.png"

    # Command to remove the background
    convert "$image" -fuzz XX% -transparent white "$output"
done
