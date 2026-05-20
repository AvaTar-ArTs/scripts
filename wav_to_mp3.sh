#!/bin/bash
set -euo pipefail

# Prompt user for folder path or individual wav files
read -p "Enter folder path or individual WAV files (separated by space): " input

# Expand ~ to home directory if present
input="${input/#\~/$HOME}"

# Determine if input is a directory or list of files
if [ -d "$input" ]; then
  # Get all .wav files in the directory safely handling spaces
  files=()
  while IFS= read -r -d $'\0' file; do
    files+=("$file")
  done < <(find "$input" -maxdepth 1 -type f -name "*.wav" -print0)
else
  # Treat input as list of files (handles quoted filenames)
  eval "files=($input)"
fi

if [ ${#files[@]} -eq 0 ]; then
  echo "No WAV files found."
  exit 1
fi

for file in "${files[@]}"; do
  [ -f "$file" ] || continue
  out="${file%.wav}.mp3"
  echo "Converting:"
  echo "  $file"
  echo "  -> $out"
  ffmpeg -y -i "$file" -codec:a libmp3lame -qscale:a 2 "$out" -hide_banner -loglevel error
done

echo "Done."
