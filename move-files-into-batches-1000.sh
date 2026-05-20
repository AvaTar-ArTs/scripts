#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail


# Prompt the user for the source and destination directories
echo -n "Enter the source directory: "
read src_dir
echo -n "Enter the destination directory:"
read dest_dir

# Ensure the directories end with a "/"
src_dir=$(echo $src_dir | sed 's:/*$::')
dest_dir=$(echo $dest_dir | sed 's:/*$::')

# Set the file counter and folder counter to 1
file_counter=1
folder_counter=1

# Create the first folder
mkdir -p "$dest_dir/folder$folder_counter"

# Loop through all the files in the source directory
for file in "$src_dir"/*; do
    # Move the file to the current folder
    mv "$file" "$dest_dir/folder$folder_counter/"

    # If the file counter is 1000, reset it and increment the folder 
#counter
    if (( file_counter % 1000 == 0 )); then
        folder_counter=$((folder_counter + 1))
        mkdir -p "$dest_dir/folder$folder_counter"
    fi

    # Increment the file counter
    file_counter=$((file_counter + 1))
done

echo "Files have been organized into folders."
