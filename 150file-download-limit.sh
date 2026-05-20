#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail


# Prompt the user for the location of the CSV file
echo -n "Enter the path to the CSV file: "
read csv_file

# Prompt the user for the destination directory
echo -n "Enter the destination directory: "
read destination_dir

# Ensure the destination directory exists, or create it
mkdir -p "$destination_dir"

# Initialize variables
folder_counter=1
file_counter=0

# Process each URL in the CSV file
while IFS= read -r url
do
  # Check if the current folder has reached the limit of 150 files
  if (( file_counter == 150 )); then
    # Reset the file counter and increment the folder counter
    file_counter=0
    (( folder_counter++ ))
  fi

  # Create a new folder if necessary
  current_folder="$destination_dir/$folder_counter"
  mkdir -p "$current_folder"

  # Extract the filename from the URL
  filename=$(basename "$url")

  # Download the file to the current folder
  wget "$url" -O "$current_folder/$filename"

  # Increment the file counter
  (( file_counter++ ))
done < "$csv_file"
