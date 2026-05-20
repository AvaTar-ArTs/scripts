#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail


# Path to the CSV file on your server
csv_file_path="/gal/15kups.csv"

# Directory to save the images
save_dir="/gal"

# Create the directory if it doesn't exist
mkdir -p "$save_dir"

# Read the CSV file and download images
while IFS= read -r url
do
    # Download each image to the specified directory
    wget -P "$save_dir" "$url"
done < "$csv_file_path"
