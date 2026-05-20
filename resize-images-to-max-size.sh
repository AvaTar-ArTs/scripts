#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail


# Color coding for outputs
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
CLEAR='\033[0m'

# Function to process images in the directory
process-images() {
    local input_dir=$1
    local max_size_mb=$2
    local dpi=300
    local max_size_bytes=$((max_size_mb * 1024 * 1024))  # Convert MB to bytes
    local scale_factor=1.1  # Use a smaller scaling factor to avoid large jumps in size

    setopt nullglob  # Avoid errors if no files match the pattern

    # Process each image file in the directory
    for file in "$input_dir"/*.{jpg,jpeg,png,bmp,gif}; do
        if [ -f "$file" ]; then
            filename=$(basename "$file")

            # Get current file size in bytes
            current_size=$(stat -f%z "$file")

            # Get current width and height
            width=$(sips -g pixelWidth "$file" | awk '/pixelWidth:/{print $2}')
            height=$(sips -g pixelHeight "$file" | awk '/pixelHeight:/{print $2}')

            # Copy original dimensions
            new_width=$width
            new_height=$height

            # Copy the original image to preserve it in case of oversize issues
            original_file="${file}.bak"
            cp "$file" "$original_file"

            # Resize the image and set the DPI to 300
            sips --resampleWidth $new_width --setProperty dpiWidth $dpi --setProperty dpiHeight $dpi "$file"

            # Loop to adjust the image size until it's within the desired limit
            while [ "$current_size" -gt "$max_size_bytes" ]; do
                echo -e "${YELLOW}Resizing $filename because its size is ${current_size} bytes, which exceeds the $max_size_bytes byte limit.${CLEAR}"

                # Reduce the dimensions to decrease the file size
                new_width=$(($new_width * 90 / 100))  # Decrease by 10%
                new_height=$(($new_height * 90 / 100))

                # Resize with the new dimensions
                sips --resampleWidth $new_width --setProperty dpiWidth $dpi --setProperty dpiHeight $dpi "$file"

                # Update current size after resizing
                current_size=$(stat -f%z "$file")

                # If file size is smaller than the limit, upscale until it approaches the limit
                if [ "$current_size" -lt "$max_size_bytes" ]; then
                    echo -e "${YELLOW}Upscaling $filename to reach closer to the limit.${CLEAR}"

                    # Increase dimensions gradually
                    while [ "$current_size" -lt "$max_size_bytes" ]; do
                        new_width=$(($new_width * $scale_factor / 1))
                        new_height=$(($new_height * $scale_factor / 1))

                        sips --resampleWidth $new_width --setProperty dpiWidth $dpi --setProperty dpiHeight $dpi "$file"
                        current_size=$(stat -f%z "$file")

                        # Break if the file size exceeds the limit
                        if [ "$current_size" -ge "$max_size_bytes" ]; then
                            echo -e "${RED}File size reached limit, stopping upscaling.${CLEAR}"
                            break
                        fi
                    done
                fi

                # If the new file size exceeds the limit after resizing, revert to the original image
                if [ "$current_size" -gt "$max_size_bytes" ]; then
                    echo -e "${RED}File size exceeded limit after resizing. Reverting to original.${CLEAR}"
                    mv "$original_file" "$file"  # Revert to the original file
                    break
                fi
            done

            # Remove the backup file if the resizing was successful
            [ -f "$original_file" ] && rm "$original_file"

            echo -e "${GREEN}Processed \"$filename\" to ${current_size} bytes.${CLEAR}"
        else
            echo -e "${YELLOW}No image files found in the directory.${CLEAR}"
        fi
    done
}

# Main function to prompt the user for input directory and max size
main() {
    # Prompt the user for the directory path
    echo "Please enter the directory path containing images:"
    read input_dir

    # Check if the directory exists
    if [ ! -d "$input_dir" ]; then
        echo -e "${RED}The directory $input_dir does not exist.${CLEAR}"
        exit 1
    fi

    # Prompt for maximum file size (default to 9MB)
    echo "Enter the maximum file size in MB (default is 9MB):"
    read max_size_mb

    # Use default size of 9MB if no input is provided
    if [ -z "$max_size_mb" ]; then
        max_size_mb=9
    fi

    # Run the process-images function
    process-images "$input_dir" "$max_size_mb"
}

# Run the main function
main
