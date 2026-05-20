#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail


# Directory containing MP3 files
MP3_DIR="~/pythons/mp3-mp4/mp3"
IMAGE_DIR="/Users/steven/Movies/AutoTypographyh-lyrics/images"
OUTPUT_DIR="/Users/steven/Movies/AutoTypographyh-lyrics/done"

# Step 1: Process all MP3 files in the directory
echo "Starting video creation process..."
for MP3_FILE in "$MP3_DIR"/*.mp4; do
    FILENAME=$(basename "$MP3_FILE" .mp3)

    echo "Processing: $FILENAME"

    # Step 2: Transcribe the MP3 file
    echo "Transcribing $FILENAME..."
    python3 /Users/steven/Movies/AutoTypographyh-lyrics/transcribe.py "$MP3_FILE" "$OUTPUT_DIR/${FILENAME}_transcript.txt"
    echo "Transcribed: $FILENAME"


    # Step 3: Analyze the transcription
    echo "Analyzing transcript for $FILENAME..."
    python3 /Users/steven/Movies/AutoTypographyh-lyrics/analyze.py "$OUTPUT_DIR/${FILENAME}_transcript.txt" "$OUTPUT_DIR/${FILENAME}_analysis.txt"

    if [ -f "$OUTPUT_DIR/${FILENAME}_analysis.txt" ]; then
        echo "Analyzed: $FILENAME"

        # Step 4: Create the video using matched images
        echo "Creating video for $FILENAME with matched images..."
        python3 ~/pythons/mp3-mp4/create_video.py "$MP3_FILE" "$OUTPUT_DIR/${FILENAME}_analysis.txt" "$IMAGE_DIR" "$OUTPUT_DIR/${FILENAME}_video.mp4"
        echo "Created video: ${FILENAME}_video.mp4"
    else
        echo "Analysis failed for $FILENAME. Cannot create video without analysis file."
    fi

    echo "Completed processing: $FILENAME"
done

echo "All files processed!"
