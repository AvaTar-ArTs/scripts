#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail

# List of video files to be converted
   files=(
     "/Users/steven/Movies/j2025/05-31-2025-Google Chrome 4.mp4"
     "/Users/steven/Movies/j2025/05-31-2025-Google Chrome-converted.mp4"
     "/Users/steven/Movies/j2025/05-31-2025-Google Chrome.mp4"
     "/Users/steven/Movies/j2025/invideo-ai-720 Diddy on Trial_ RICO, Sex Trafficking &  2025-05-31.mp4"
     "/Users/steven/Movies/j2025/invideo-ai-720 Trump & Musk_ Satirical Showdown! 2025-05-31.mp4"
     "/Users/steven/Movies/j2025/invideo-ai-1080 Elon Musk's Fraud Allegations_ The Full  2025-05-31.mp4"
     "/Users/steven/Movies/j2025/invideo-ai-1080 How Prosecutors Built the Diddy RICO Cas 2025-05-31_converted.mp4"
     "/Users/steven/Movies/j2025/invideo-ai-1080 How Prosecutors Built the Diddy RICO Cas 2025-05-31.mp4"
     "/Users/steven/Movies/j2025/invideo-ai-1080 Proud to Be FGC Alumni_ United in Legacy 2025-05-31.mp4"
     "/Users/steven/Movies/j2025/invideo-ai-1080 Trump, Elon & Diddy_ The Press Conferenc 2025-05-31.mp4"
     "/Users/steven/Movies/j2025/invideo-ai-1080 Trump, Musk & Doocy_ The Press Conferenc 2025-05-31.mp4"
     "/Users/steven/Movies/j2025/invideo-ai-1080 Trump’s Freudian Collapse_ The Confessio 2025-05-31.mp4"
     "/Users/steven/Movies/j2025/The Irony of Trump's Accusations Against Hill/The Irony of Trump's Accusations Against Hill.mp4"
     "/Users/steven/Movies/j2025/trump-n-musk-satricial-showdown-1.mp4"
     "/Users/steven/Movies/j2025/Trump's Accusations  Political Strategy or Ps/Trump's Accusations  Political Strategy or Ps.mp4"
     "/Users/steven/Movies/j2025/Trump's Rhetoric  Mobilizing Support and Clou/Trump's Rhetoric  Mobilizing Support and Clou.mp4"
     "/Users/steven/Movies/j2025/Trump's Role in the January 6th Capitol Riot/Trump's Role in the January 6th Capitol Riot.mp4"
     "/Users/steven/Movies/j2025/Understanding Trump's Projection  A Psycholog/Understanding Trump's Projection  A Psycholog.mp4"
   )
   # Loop through each file and convert to mp3
   for file in "${files[@]}"; do
     # Extract the directory and base name of the file
     dir=$(dirname "$file")
     base=$(basename "$file" .mp4)
     
     # Output mp3 file path
     output="${dir}/${base}.mp3"
     
     # Convert to mp3 using ffmpeg
     ffmpeg -i "$file" -q:a 0 -map a "$output"
   done
   
