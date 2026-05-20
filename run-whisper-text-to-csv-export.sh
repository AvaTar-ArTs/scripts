#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail

python3 final_whisper_to_csv.py   --root "/Users/steven/Documents/Whisper-Text"   --out  "/Users/steven/Documents/Whisper-Text/combined_output_09-09-25.csv"
