#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail


# URL of the CSV file
csv_url="https://avatararts.org/gal/15kups.csv"

# Directory to save the images
save_dir="~/gal"

# Create the directory if it doesn't exist
mkdir -p "$save_dir"

# Fetch the CSV file and read it line by line
curl -s "$csv_url" | while IFS= read -r url
do
    # Download each image to the specified directory
    wget -P "$save_dir" "$url"
done
