#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail


# Load the environment variables from ~/.env
export $(grep -v '^#' ~/.env | xargs)

# Directory paths
MP3_DIR="~/pythons/mp3-mp4/mp3"
IMAGE_DIR="~/pythons/mp3-mp4/images"
OUTPUT_DIR="~/pythons/mp3-mp4/done"

# Step 1: Process all MP3 files in the directory
for MP3_FILE in "$MP3_DIR"/*.mp3; do
    FILENAME=$(basename "$MP3_FILE" .mp3)

    echo "Processing: $FILENAME"

    # Step 2: Transcribe the MP3 file
    echo "Transcribing $FILENAME..."
    python3 ~/pythons/mp3-mp4/transcribe.py "$MP3_FILE" "$OUTPUT_DIR/${FILENAME}_transcript.txt"
    echo "Transcribed: $FILENAME"

    # Step 3: Analyze transcription
    echo "Analyzing transcript for $FILENAME..."
    python3 ~/pythons/mp3-mp4/analyze.py "$OUTPUT_DIR/${FILENAME}_transcript.txt" "$OUTPUT_DIR/${FILENAME}_analysis.txt"
    
    if [ -f "$OUTPUT_DIR/${FILENAME}_analysis.txt" ]; then
        echo "Analyzed: $FILENAME"

        # Step 4: Match images and create video
        echo "Creating video for $FILENAME with matched images..."
        python3 ~/pythons/mp3-mp4/create_video.py "$MP3_FILE" "$OUTPUT_DIR/${FILENAME}_analysis.txt" "$IMAGE_DIR" "$OUTPUT_DIR/${FILENAME}_video.mp4"
        echo "Created video: ${FILENAME}_video.mp4"
    else
        echo "Analysis failed for $FILENAME. Cannot create video without analysis file."
    fi

    echo "Completed processing: $FILENAME"
done

echo "All files processed!"
