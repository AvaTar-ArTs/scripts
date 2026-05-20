#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail


# Format the too-many-lost.txt file so each path is on a separate line
INPUT_FILE="/Users/steven/MasterxEo/too-many-lost.txt"
OUTPUT_FILE="/tmp/formatted_lost_files_corrected.txt"

echo "Formatting the lost files list with corrected approach..."

# First, let's examine the raw content to understand the structure
echo "Examining raw file structure..."
head -c 1000 "$INPUT_FILE" | od -c | head -20

# Since the file appears to have paths separated by spaces, we'll use a different approach
# We'll split on spaces but preserve paths that contain spaces and are quoted
perl -pe 's/\s+(?=\/)/\n/g' "$INPUT_FILE" | \
  sed 's/^"//' | \
  sed 's/"$//' | \
  sed "s/^'//" | \
  sed "s/'$//" | \
  sed 's/^[[:space:]]*//' | \
  sed 's/[[:space:]]*$//' | \
  grep -v '^$' | \
  sort | \
  uniq > "$OUTPUT_FILE.tmp"

# Count the results
COUNT=$(wc -l < "$OUTPUT_FILE.tmp")
echo "Processed $COUNT potential entries"

# Filter for actual file paths (those starting with /Users/steven)
grep "^/Users/steven" "$OUTPUT_FILE.tmp" > "$OUTPUT_FILE"

# Count the actual file paths
REAL_COUNT=$(wc -l < "$OUTPUT_FILE")
echo "Successfully formatted $REAL_COUNT actual file paths from the original list"

# Show the first 10 entries
echo "First 10 formatted entries:"
head -10 "$OUTPUT_FILE"

# Clean up
rm "$OUTPUT_FILE.tmp"

echo "Formatted file saved to: $OUTPUT_FILE"
