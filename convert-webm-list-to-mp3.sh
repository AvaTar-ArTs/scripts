#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail


# Path to the TXT file
TXT_FILE="/Users/steven/webm_files.txt"

# Loop through each line in the TXT file
while IFS= read -r webm_file; do
    # Extract directory and base name
    DIR=$(dirname "$webm_file")
    BASENAME=$(basename "$webm_file" .webm)
    MP3_FILE="$DIR/$BASENAME.mp3"

    echo "Converting \"$webm_file\" to \"$MP3_FILE\"..."

    # Convert using FFmpeg (audio-only extraction)
    ffmpeg -i "$webm_file" -vn -acodec libmp3lame -q:a 2 "$MP3_FILE"

    echo "Conversion complete: \"$MP3_FILE\""
done < "$TXT_FILE"

echo "All conversions complete."
