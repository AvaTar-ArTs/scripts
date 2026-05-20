#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail

#
# MP4 to Transcript Pipeline
# Converts MP4 ? MP3 ? Transcribe ? Analyze
# Uses: ~/pythonss/transcribe/ pipeline
#

# Activate transcribe environment
eval "$(mamba shell hook -s bash)"
mamba activate transcribe
export KMP_DUPLICATE_LIB_OK=TRUE

# Load API keys
source ~/.env.d/loader.sh audio-music 2>/dev/null

# Directory paths
MP4_DIR="${1:-/Users/steven/Movies/project2025/media}"
OUTPUT_DIR="$MP4_DIR"

echo "?? MP4 Transcription Pipeline"
echo "????????????????????????????????????????????????????????????????"
echo "Source: $MP4_DIR"
echo "Output: $OUTPUT_DIR"
echo ""

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Process all MP4 files
for MP4_FILE in "$MP4_DIR"/*.mp4; do
    [[ ! -f "$MP4_FILE" ]] && continue
    
    FILENAME=$(basename "$MP4_FILE" .mp4)
    echo ""
    echo "? Processing: $FILENAME"
    
    # Convert and transcribe using Python script
    cd ~/pythonss/transcribe
    python convert-mp4-transcribe.py "$MP4_FILE"
    
    echo "? Completed: $FILENAME"
done

echo ""
echo "? All MP4 files processed!"
echo "?? Output: $OUTPUT_DIR/transcripts/ and $OUTPUT_DIR/analysis/"
