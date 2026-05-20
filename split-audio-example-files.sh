#!/usr/bin/env bash
set -euo pipefail
# Activate env
source "$(conda info --base)/etc/profile.d/conda.sh"
conda activate audio-tools
# Run with fixed duration (9 minutes)
python3 "$(dirname "$0")/split_audio.py" \
  --chunk-seconds 540 \
  "/Users/steven/Movies/HeKaTe-saLome/mp3/Ktherias-30.mp3" \
  "/Users/steven/Movies/HeKaTe-saLome/mp3/ReflectionsOfDesire.mp3" \
  "/Users/steven/Movies/HeKaTe-saLome/mp3/The_Vivification_Of_Ker.mp3"
