#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail

#
# Batch MP3/Audio Transcription Wrapper
# Uses: ~/pythonss/transcribe/ pipeline
#

# Activate transcribe environment
eval "$(mamba shell hook -s bash)"
mamba activate transcribe
export KMP_DUPLICATE_LIB_OK=TRUE

# Load API keys
source ~/.env.d/loader.sh audio-music 2>/dev/null

# Prompt for source directory (with default)
read -e -p "Enter source media directory [default: /Users/steven/Music/nocTurneMeLoDieS/Singles]: " INPUT_DIR
INPUT_DIR="${INPUT_DIR:-/Users/steven/Music/nocTurneMeLoDieS}"

echo "🎵 Batch Transcription"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Directory: $INPUT_DIR"
echo "Using: Whisper base model"
echo ""

# Run Python transcription script
cd /Users/steven/pythons/transcribe/transcribe.py
python transcribe-analyze-local.py --dir "$INPUT_DIR" --whisper base

echo ""
echo "✅ Batch transcription complete!"
echo "📁 Output: $INPUT_DIR/transcripts/ and $INPUT_DIR/analysis/"
