#!/usr/bin/env bash
set -euo pipefail

DIR="${1:-.}"
OUT="${2:-./audio_metadata_lufs.csv}"

command -v ffprobe >/dev/null 2>&1 || { echo "ffprobe not found. Install ffmpeg (brew install ffmpeg) and re-run."; exit 1; }
command -v ffmpeg  >/dev/null 2>&1 || { echo "ffmpeg not found. Install ffmpeg (brew install ffmpeg) and re-run."; exit 1; }

echo "filename,filepath,size_bytes,duration_sec,bitrate_bps,channels,sample_rate,integrated_lufs,md5" > "$OUT"

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
      -of default=noprint_wrappers=1:nokey=1 "$f"
  )

  # run loudness scan (ebur128). This prints lines like "I: -26.5 LUFS"
  lufs="$(ffmpeg -hide_banner -nostats -i "$f" -filter_complex ebur128 -f null - 2>&1 \
    | awk '/I:/{gsub(/,/,"",$0); print $2; exit}' || true )"

  if [ -z "$lufs" ]; then lufs=""; fi

  if command -v md5 >/dev/null 2>&1; then
    md5sum="$(md5 -q "$f")"
  else
    md5sum="$(openssl md5 -binary "$f" | xxd -p)"
  fi

  printf '%s\n' "\"$filename\",\"$filepath\",$size,$duration,$bit_rate,$channels,$sample_rate,$lufs,$md5sum" >> "$OUT"
done

echo "Wrote CSV -> $OUT"

