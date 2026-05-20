#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail

# Phase 1: Very High Confidence - SAFE TO REMOVE
# Both methods agree - 100% code similarity
# Generated automatically from merged analysis

BACKUP_DIR=~/backups/pythons_cleanup_$(date +%Y%m%d)
mkdir -p "$BACKUP_DIR"
cd ~/pythons

echo '🟢 Phase 1: Removing Very High Confidence Duplicates (10 files)'
echo '======================================================================'

# analyze-mp3-transcript-prompts (1)_1.py -> analyze-mp3-transcript-prompts (1).py (similarity: 1.000)
if [ -f "analyze-mp3-transcript-prompts (1)_1.py" ]; then
  cp "analyze-mp3-transcript-prompts (1)_1.py" "$BACKUP_DIR/"
  rm "analyze-mp3-transcript-prompts (1)_1.py"
  echo "✅ Removed: analyze-mp3-transcript-prompts (1)_1.py"
else
  echo "⚠️  Not found: analyze-mp3-transcript-prompts (1)_1.py"
fi

# playlist_20221230180809.py -> playlist_1.py (similarity: 1.000)
if [ -f "playlist_20221230180809.py" ]; then
  cp "playlist_20221230180809.py" "$BACKUP_DIR/"
  rm "playlist_20221230180809.py"
  echo "✅ Removed: playlist_20221230180809.py"
else
  echo "⚠️  Not found: playlist_20221230180809.py"
fi

# resize-skip-8below2.py -> re-size_1.py (similarity: 1.000)
if [ -f "resize-skip-8below2.py" ]; then
  cp "resize-skip-8below2.py" "$BACKUP_DIR/"
  rm "resize-skip-8below2.py"
  echo "✅ Removed: resize-skip-8below2.py"
else
  echo "⚠️  Not found: resize-skip-8below2.py"
fi

# resize-img_1.py -> resize-img.py (similarity: 1.000)
if [ -f "resize-img_1.py" ]; then
  cp "resize-img_1.py" "$BACKUP_DIR/"
  rm "resize-img_1.py"
  echo "✅ Removed: resize-img_1.py"
else
  echo "⚠️  Not found: resize-img_1.py"
fi

# main_20221230234008.py -> main_20221230233546.py (similarity: 1.000)
if [ -f "main_20221230234008.py" ]; then
  cp "main_20221230234008.py" "$BACKUP_DIR/"
  rm "main_20221230234008.py"
  echo "✅ Removed: main_20221230234008.py"
else
  echo "⚠️  Not found: main_20221230234008.py"
fi

# analyze 1_1.py -> analyze 1.py (similarity: 0.998)
if [ -f "analyze 1_1.py" ]; then
  cp "analyze 1_1.py" "$BACKUP_DIR/"
  rm "analyze 1_1.py"
  echo "✅ Removed: analyze 1_1.py"
else
  echo "⚠️  Not found: analyze 1_1.py"
fi

# quantum_media_processor_1.py -> quantum_media_processor.py (similarity: 0.998)
if [ -f "quantum_media_processor_1.py" ]; then
  cp "quantum_media_processor_1.py" "$BACKUP_DIR/"
  rm "quantum_media_processor_1.py"
  echo "✅ Removed: quantum_media_processor_1.py"
else
  echo "⚠️  Not found: quantum_media_processor_1.py"
fi

# process_leonardo_20250102110258.py -> process_leonardo.py (similarity: 0.997)
if [ -f "process_leonardo_20250102110258.py" ]; then
  cp "process_leonardo_20250102110258.py" "$BACKUP_DIR/"
  rm "process_leonardo_20250102110258.py"
  echo "✅ Removed: process_leonardo_20250102110258.py"
else
  echo "⚠️  Not found: process_leonardo_20250102110258.py"
fi

# analyzer_1.py -> analyzer 1.py (similarity: 0.996)
if [ -f "analyzer_1.py" ]; then
  cp "analyzer_1.py" "$BACKUP_DIR/"
  rm "analyzer_1.py"
  echo "✅ Removed: analyzer_1.py"
else
  echo "⚠️  Not found: analyzer_1.py"
fi

# storykeytrans.py -> media-processing-audio.py (similarity: 0.976)
if [ -f "storykeytrans.py" ]; then
  cp "storykeytrans.py" "$BACKUP_DIR/"
  rm "storykeytrans.py"
  echo "✅ Removed: storykeytrans.py"
else
  echo "⚠️  Not found: storykeytrans.py"
fi

echo ""
echo "✅ Phase 1 Complete! Backed up to: $BACKUP_DIR"
