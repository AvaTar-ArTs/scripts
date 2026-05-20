#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail


# Directory containing the .tiff files
DIRECTORY="/Users/steven/Documents/Trashy Anti-Valentines Juice/tiff/"

# Check if the directory exists
if [ ! -d "$DIRECTORY" ]; then
  echo "Error: Directory $DIRECTORY does not exist."
  exit 1
fi

# Loop through all .tiff files in the directory
for tiff_file in "$DIRECTORY"/*.tiff; do
  # Check if there are no .tiff files
  if [ ! -e "$tiff_file" ]; then
    echo "No .tiff files found in $DIRECTORY."
    exit 0
  fi

  # Get the base name without extension
  base_name=$(basename "$tiff_file" .tiff)
  
  # Convert the .tiff file to .png
  convert "$tiff_file" "$DIRECTORY/$base_name.png"

  echo "Converted $tiff_file to $DIRECTORY/$base_name.png"
done
