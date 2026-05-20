#!/usr/bin/env bash
set -euo pipefail

# Usage:
#   ./audio_metadata_csv.sh /path/to/audio_dir /path/to/output.csv
# Defaults to current dir -> ./audio_metadata.csv

DIR="${1:-.}"
OUT="${2:-./audio_metadata.csv}"

command -v ffprobe >/dev/null 2>&1 || { echo "ffprobe not found. Install ffmpeg (brew install ffmpeg) and re-run."; exit 1; }

echo "filename,filepath,size_bytes,duration_sec,bitrate_bps,channels,sample_rate,md5" > "$OUT"

shopt -s nullglob
for f in "$DIR"/*.{mp3,wav,m4a,flac,ogg,opus} ; do
  [ -f "$f" ] || continue

  filename="$(basename "$f")"
  filepath="$(cd "$(dirname "$f")" && pwd)/$(basename "$f")"

  IFS=$'\n' read -r duration size bit_rate channels sample_rate < <(
    ffprobe -v error \
      -select_streams a:0 \
      -show_entries format=duration,size,bit_rate \
      -show_entries stream=channels,sample_rate \
      -of default=noprint_wrappers=1:nokey=1 "$f" 2>/dev/null || printf "\n\n\n\n"
  )

  if command -v md5 >/dev/null 2>&1; then
    md5sum="$(md5 -q "$f")"
  else
    md5sum="$(openssl md5 -binary "$f" | xxd -p)"
  fi

  # CSV-safe quoting for filename/filepath
  esc_name="${filename//\"/\"\"}"
  esc_path="${filepath//\"/\"\"}"
  printf '"%s","%s",%s,%s,%s,%s,%s,%s\n' "$esc_name" "$esc_path" "$size" "$duration" "$bit_rate" "$channels" "$sample_rate" "$md5sum" >> "$OUT"
done

echo "Wrote CSV -> $OUT"
