#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail


# Path to the CSV file
CSV_FILE="/Users/steven/vids-12-05-00:16.csv"

# Read the CSV and extract file paths ending with .webm
while IFS=, read -r filename duration size creation_date path; do
    # Ensure the path points to a .webm file
    if [[ "$path" == *.webm ]]; then
        # Extract directory and base name
        DIR=$(dirname "$path")
        BASENAME=$(basename "$path" .webm)
        MP3_FILE="$DIR/$BASENAME.mp3"

        echo "Converting $path to $MP3_FILE..."

        # Convert using FFmpeg (audio-only extraction)
        ffmpeg -i "$path" -vn -acodec libmp3lame -q:a 2 "$MP3_FILE"

        echo "Conversion complete: $MP3_FILE"
    fi
done < <(tail -n +2 "$CSV_FILE")  # Skip the header row

echo "All conversions complete."
