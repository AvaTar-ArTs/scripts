#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail


# Format the too-many-lost.txt file so each path is on a separate line
INPUT_FILE="/Users/steven/MasterxEo/too-many-lost.txt"
OUTPUT_FILE="/tmp/formatted_lost_files.txt"

echo "Formatting the lost files list..."

# Process the file to put each path on a separate line
# This handles spaces, quotes, and other delimiters
cat "$INPUT_FILE" | \
  sed 's/"/"\n"/g' | \
  sed 's/"/\n/g' | \
  tr ' ' '\n' | \
  sed 's/^"//' | \
  sed 's/"$//' | \
  sed "s/^'//" | \
  sed "s/'$//" | \
  sed 's/^[[:space:]]*//' | \
  sed 's/[[:space:]]*$//' | \
  grep -v '^$' | \
  sort | \
  uniq > "$OUTPUT_FILE"

# Count the results
COUNT=$(wc -l < "$OUTPUT_FILE")
echo "Successfully formatted $COUNT file paths from the original list"

# Show the first 10 entries
echo "First 10 formatted entries:"
head -10 "$OUTPUT_FILE"

echo "Formatted file saved to: $OUTPUT_FILE"
