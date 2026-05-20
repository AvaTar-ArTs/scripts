#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail

# Phase 2: High Confidence - REVIEW RECOMMENDED
# Both methods agree - review before removal
# Generated automatically from merged analysis

BACKUP_DIR=~/backups/pythons_cleanup_$(date +%Y%m%d)
mkdir -p "$BACKUP_DIR"
cd ~/pythons

echo '🟡 Phase 2: High Confidence Duplicates (Review Recommended)'
echo '======================================================================'

# analyze_user_dirs_parent_folders.py -> analyze_parent_folders.py (similarity: 0.998)
echo "Reviewing: analyze_user_dirs_parent_folders.py"
if [ -f "analyze_user_dirs_parent_folders.py" ]; then
  echo "  Keep file: analyze_parent_folders.py"
  echo "  Similarity: 0.998"
  read -p "  Remove this file? (y/n): " answer
  if [ "$answer" = "y" ]; then
    cp "analyze_user_dirs_parent_folders.py" "$BACKUP_DIR/"
    rm "analyze_user_dirs_parent_folders.py"
    echo "  ✅ Removed: analyze_user_dirs_parent_folders.py"
  else
    echo "  ⏭️  Skipped: analyze_user_dirs_parent_folders.py"
  fi
else
  echo "  ⚠️  Not found: analyze_user_dirs_parent_folders.py"
fi
echo ""

# openai-image-generater.py -> fancyimg.py (similarity: 0.974)
echo "Reviewing: openai-image-generater.py"
if [ -f "openai-image-generater.py" ]; then
  echo "  Keep file: fancyimg.py"
  echo "  Similarity: 0.974"
  read -p "  Remove this file? (y/n): " answer
  if [ "$answer" = "y" ]; then
    cp "openai-image-generater.py" "$BACKUP_DIR/"
    rm "openai-image-generater.py"
    echo "  ✅ Removed: openai-image-generater.py"
  else
    echo "  ⏭️  Skipped: openai-image-generater.py"
  fi
else
  echo "  ⚠️  Not found: openai-image-generater.py"
fi
echo ""

# cover_1.py -> cover2.py (similarity: 0.943)
echo "Reviewing: cover_1.py"
if [ -f "cover_1.py" ]; then
  echo "  Keep file: cover2.py"
  echo "  Similarity: 0.943"
  read -p "  Remove this file? (y/n): " answer
  if [ "$answer" = "y" ]; then
    cp "cover_1.py" "$BACKUP_DIR/"
    rm "cover_1.py"
    echo "  ✅ Removed: cover_1.py"
  else
    echo "  ⏭️  Skipped: cover_1.py"
  fi
else
  echo "  ⚠️  Not found: cover_1.py"
fi
echo ""

# vids_1.py -> 2025-vid.py (similarity: 0.928)
echo "Reviewing: vids_1.py"
if [ -f "vids_1.py" ]; then
  echo "  Keep file: 2025-vid.py"
  echo "  Similarity: 0.928"
  read -p "  Remove this file? (y/n): " answer
  if [ "$answer" = "y" ]; then
    cp "vids_1.py" "$BACKUP_DIR/"
    rm "vids_1.py"
    echo "  ✅ Removed: vids_1.py"
  else
    echo "  ⏭️  Skipped: vids_1.py"
  fi
else
  echo "  ⚠️  Not found: vids_1.py"
fi
echo ""

# askreddit-loop-1.py -> AskReddit_loop.py (similarity: 0.902)
echo "Reviewing: askreddit-loop-1.py"
if [ -f "askreddit-loop-1.py" ]; then
  echo "  Keep file: AskReddit_loop.py"
  echo "  Similarity: 0.902"
  read -p "  Remove this file? (y/n): " answer
  if [ "$answer" = "y" ]; then
    cp "askreddit-loop-1.py" "$BACKUP_DIR/"
    rm "askreddit-loop-1.py"
    echo "  ✅ Removed: askreddit-loop-1.py"
  else
    echo "  ⏭️  Skipped: askreddit-loop-1.py"
  fi
else
  echo "  ⚠️  Not found: askreddit-loop-1.py"
fi
echo ""

# resize-skip-8below_1.py -> resize-skip-8below.py (similarity: 0.894)
echo "Reviewing: resize-skip-8below_1.py"
if [ -f "resize-skip-8below_1.py" ]; then
  echo "  Keep file: resize-skip-8below.py"
  echo "  Similarity: 0.894"
  read -p "  Remove this file? (y/n): " answer
  if [ "$answer" = "y" ]; then
    cp "resize-skip-8below_1.py" "$BACKUP_DIR/"
    rm "resize-skip-8below_1.py"
    echo "  ✅ Removed: resize-skip-8below_1.py"
  else
    echo "  ⏭️  Skipped: resize-skip-8below_1.py"
  fi
else
  echo "  ⚠️  Not found: resize-skip-8below_1.py"
fi
echo ""

# story-key-trans_1.py -> story-key-trans copy.py (similarity: 0.885)
echo "Reviewing: story-key-trans_1.py"
if [ -f "story-key-trans_1.py" ]; then
  echo "  Keep file: story-key-trans copy.py"
  echo "  Similarity: 0.885"
  read -p "  Remove this file? (y/n): " answer
  if [ "$answer" = "y" ]; then
    cp "story-key-trans_1.py" "$BACKUP_DIR/"
    rm "story-key-trans_1.py"
    echo "  ✅ Removed: story-key-trans_1.py"
  else
    echo "  ⏭️  Skipped: story-key-trans_1.py"
  fi
else
  echo "  ⚠️  Not found: story-key-trans_1.py"
fi
echo ""

# story-key-trans.py -> story-key-trans copy.py (similarity: 0.885)
echo "Reviewing: story-key-trans.py"
if [ -f "story-key-trans.py" ]; then
  echo "  Keep file: story-key-trans copy.py"
  echo "  Similarity: 0.885"
  read -p "  Remove this file? (y/n): " answer
  if [ "$answer" = "y" ]; then
    cp "story-key-trans.py" "$BACKUP_DIR/"
    rm "story-key-trans.py"
    echo "  ✅ Removed: story-key-trans.py"
  else
    echo "  ⏭️  Skipped: story-key-trans.py"
  fi
else
  echo "  ⚠️  Not found: story-key-trans.py"
fi
echo ""

# analyze-prompt_1.py -> analyze-mp3-transcript-prompts (1).py (similarity: 0.864)
echo "Reviewing: analyze-prompt_1.py"
if [ -f "analyze-prompt_1.py" ]; then
  echo "  Keep file: analyze-mp3-transcript-prompts (1).py"
  echo "  Similarity: 0.864"
  read -p "  Remove this file? (y/n): " answer
  if [ "$answer" = "y" ]; then
    cp "analyze-prompt_1.py" "$BACKUP_DIR/"
    rm "analyze-prompt_1.py"
    echo "  ✅ Removed: analyze-prompt_1.py"
  else
    echo "  ⏭️  Skipped: analyze-prompt_1.py"
  fi
else
  echo "  ⚠️  Not found: analyze-prompt_1.py"
fi
echo ""

# leonardo-convert-loop2.py -> leonardo-convert-json-writer.py (similarity: 0.862)
echo "Reviewing: leonardo-convert-loop2.py"
if [ -f "leonardo-convert-loop2.py" ]; then
  echo "  Keep file: leonardo-convert-json-writer.py"
  echo "  Similarity: 0.862"
  read -p "  Remove this file? (y/n): " answer
  if [ "$answer" = "y" ]; then
    cp "leonardo-convert-loop2.py" "$BACKUP_DIR/"
    rm "leonardo-convert-loop2.py"
    echo "  ✅ Removed: leonardo-convert-loop2.py"
  else
    echo "  ⏭️  Skipped: leonardo-convert-loop2.py"
  fi
else
  echo "  ⚠️  Not found: leonardo-convert-loop2.py"
fi
echo ""

# test_onedrive_gallery_logic.py -> test_google_gallery_logic.py (similarity: 0.852)
echo "Reviewing: test_onedrive_gallery_logic.py"
if [ -f "test_onedrive_gallery_logic.py" ]; then
  echo "  Keep file: test_google_gallery_logic.py"
  echo "  Similarity: 0.852"
  read -p "  Remove this file? (y/n): " answer
  if [ "$answer" = "y" ]; then
    cp "test_onedrive_gallery_logic.py" "$BACKUP_DIR/"
    rm "test_onedrive_gallery_logic.py"
    echo "  ✅ Removed: test_onedrive_gallery_logic.py"
  else
    echo "  ⏭️  Skipped: test_onedrive_gallery_logic.py"
  fi
else
  echo "  ⚠️  Not found: test_onedrive_gallery_logic.py"
fi
echo ""

# mp4-mp3-analyze2.py -> media_processor2.py (similarity: 0.782)
echo "Reviewing: mp4-mp3-analyze2.py"
if [ -f "mp4-mp3-analyze2.py" ]; then
  echo "  Keep file: media_processor2.py"
  echo "  Similarity: 0.782"
  read -p "  Remove this file? (y/n): " answer
  if [ "$answer" = "y" ]; then
    cp "mp4-mp3-analyze2.py" "$BACKUP_DIR/"
    rm "mp4-mp3-analyze2.py"
    echo "  ✅ Removed: mp4-mp3-analyze2.py"
  else
    echo "  ⏭️  Skipped: mp4-mp3-analyze2.py"
  fi
else
  echo "  ⚠️  Not found: mp4-mp3-analyze2.py"
fi
echo ""

echo "✅ Phase 2 Complete! Backed up to: $BACKUP_DIR"
