#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail

# Directory paths
MP3_DIR="/Users/steven/Music/nocTurneMeLoDieS/" # Corrected directory path
OUTPUT_DIR="/Users/steven/Music/nocTurneMeLoDieS/"  # Corrected directory path
ANALYZE_SCRIPT="/Users/steven/Movies/project2025/info.py"  # Path to analyze.py script

# Create output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

# Step 1: Process all MP3 files in the directory
for MP3_FILE in "$MP3_DIR"/*.mp3; do
    if [ ! -f "$MP3_FILE" ]; then
        echo "No MP3 files found in $MP3_DIR"
        exit 1
    fi

    FILENAME=$(basename "$MP3_FILE" .mp3)

    echo "Processing: $FILENAME"

    # Step 2: Convert the MP3 file to MP3
    echo "Converting $FILENAME to MP3..."
    ffmpeg -y -i "$MP3_FILE" "$OUTPUT_DIR/${FILENAME}.mp3"
    echo "Converted $FILENAME to MP3"

    # Step 3: Transcribe the MP3 file
    echo "Transcribing $FILENAME..."
    python3 ~/pythons/transcribe.py "$OUTPUT_DIR/${FILENAME}.mp3" "$OUTPUT_DIR/${FILENAME}_transcript.txt"
    echo "Transcribed: $FILENAME"

    # Step 4: Analyze the transcript using analyze.py
    echo "Analyzing transcript for $FILENAME..."
    python3 "$ANALYZE_SCRIPT" "$OUTPUT_DIR/${FILENAME}_transcript.txt" "$OUTPUT_DIR/${FILENAME}_analysis.txt"
    echo "Analyzed: $FILENAME"

    echo "Completed processing: $FILENAME"
done

echo "All files processed!"
