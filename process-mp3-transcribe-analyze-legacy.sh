#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail


# Directory containing MP3 files
INPUT_DIR="~/pythons/mp3-mp4"
FILENAME_PATTERN="*.mp3"

OUTPUT_DIR="~/pythons/mp3-mp4/done"

# Step 1: Process all MP3 files in the directory
for FILE in "$INPUT_DIR"/$FILENAME_PATTERN; do
    [ -e "$FILE" ] || continue
    FILENAME=$(basename "$FILE" .mp3)

    # Step 2: Transcribe the MP3 file
    python3 ~/pythons/mp3-mp4/transcribe.py "$FILE" "$OUTPUT_DIR/${FILENAME}_transcript.txt"
    
    # Step 3: Analyze the transcription
    python3 ~/pythons/mp3-mp4/analyze.py "$OUTPUT_DIR/${FILENAME}_transcript.txt" "$OUTPUT_DIR/${FILENAME}_analysis.txt"
    
    if [ -f "$OUTPUT_DIR/${FILENAME}_analysis.txt" ]; then
        echo "Analyzed: $FILENAME"
    fi
    
    echo "Completed processing: $FILENAME"
done

echo "All files processed!"
