#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail


# Prompt the user for the input MP3 file
echo "Please enter the path to the MP3 file:"
read input_mp3

# Prompt the user for the input image file
echo "Please enter the path to the image file:"
read input_image

# Prompt the user for the output MP4 file
echo "Please enter the path for the output MP4 file:"
read output_mp4

# Use FFmpeg to convert the MP3 to MP4 with the image
ffmpeg -i "$input_mp3" -i "$input_image" -c:a aac -c:v libx264 -shortest "$output_mp4"

# Inform the user that the process is complete
echo "Conversion complete: $output_mp4 has been created."
