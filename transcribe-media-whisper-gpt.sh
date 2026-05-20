#!/usr/bin/env bash
#
# 🎬 Universal Media Transcription & Analysis
# Supports: MP4, MP3, M4A, WAV, AAC, FLAC, OGG, WEBM, MOV, AVI, MKV
# Uses: Whisper + GPT-4o-mini for transcription & analysis
#

set -e

# Activate transcribe environment
eval "$(mamba shell hook -s bash 2>/dev/null)" || true
mamba activate transcribe 2>/dev/null || true
export KMP_DUPLICATE_LIB_OK=TRUE

# Load API keys
source ~/.env.d/loader.sh audio-music 2>/dev/null || true

# Prompt for source directory
read -e -p "📁 Enter media directory [default: //Users/steven/Music/nocTurneMeLoDieS]: " MEDIA_DIR
MEDIA_DIR="${MEDIA_DIR:-/Users/steven/Music/nocTurneMeLoDieS/Discography}"

# Check if directory exists
if [ ! -d "$MEDIA_DIR" ]; then
    echo "❌ Directory not found: $MEDIA_DIR"
    exit 1
fi

echo ""
echo "🎬 Universal Media Transcription & Analysis"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📁 Directory: $MEDIA_DIR"
echo "🎤 Whisper: base model (local)"
echo "🤖 Analysis: GPT-4o-mini (OpenAI)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Supported media formats
MEDIA_EXTENSIONS=("mp4" "mp3" "m4a" "wav" "aac" "flac" "ogg" "webm" "mov" "avi" "mkv")

# Count total files
TOTAL_FILES=0
for ext in "${MEDIA_EXTENSIONS[@]}"; do
    count=$(find "$MEDIA_DIR" -maxdepth 1 -type f -iname "*.${ext}" 2>/dev/null | wc -l | tr -d ' ')
    TOTAL_FILES=$((TOTAL_FILES + count))
done

if [ "$TOTAL_FILES" -eq 0 ]; then
    echo "❌ No media files found in $MEDIA_DIR"
    echo "   Supported formats: ${MEDIA_EXTENSIONS[*]}"
    exit 1
fi

echo "📊 Found $TOTAL_FILES media files"
echo ""

# Run the modern Python transcription pipeline
cd ~/pythons/transcribe
python transcribe-analyze-local.py \
    --dir "$MEDIA_DIR" \
    --whisper base \
    --llm-type gpt \
    --gpt-model gpt-4o-mini

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ All media files processed!"
echo "📁 Transcripts: $MEDIA_DIR/transcripts/"
echo "🤖 Analysis: $MEDIA_DIR/analysis/"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
