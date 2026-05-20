#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail


# Load the environment variables from ~/.env
export $(grep -v '^#' ~/.env | xargs)

# Directory paths
MP4_DIR="/Users/steven/Movies/project2025/media"  # Directory containing your MP4 files
OUTPUT_DIR="/Users/steven/Movies/project2025/media"  # Directory to save MP3 and transcript files
ANALYZE_SCRIPT="/Users/steven/Movies/project2025/media"  # Path to analyze.py script

# Create output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

# Step 1: Process all MP4 files in the directory
for MP4_FILE in "$MP4_DIR"/*.mp4; do
    FILENAME=$(basename "$MP4_FILE" .mp4)

    echo "Processing: $FILENAME"

    # Step 2: Convert the MP4 file to MP3
    echo "Converting $FILENAME to MP3..."
    ffmpeg -i "$MP4_FILE" "$OUTPUT_DIR/${FILENAME}.mp3"
    echo "Converted $FILENAME to MP3"

    # Step 3: Transcribe the MP3 file
    echo "Transcribing $FILENAME..."
    python3 ~/pythons/transcribe.py "$OUTPUT_DIR/${FILENAME}.mp3" "$OUTPUT_DIR/${FILENAME}_transcript.txt"
    echo "Transcribed: $FILENAME"

    # Step 4: Analyze the transcript using analyze.py
    echo "Analyzing transcript for $FILENAME..."
    python3 ~/pythons/analyze.py "$ANALYZE_SCRIPT" "$OUTPUT_DIR/${FILENAME}_transcript.txt" "$OUTPUT_DIR/${FILENAME}_analysis.txt"
    echo "Analyzed: $FILENAME"

    echo "Completed processing: $FILENAME"
done

echo "All files processed!"
