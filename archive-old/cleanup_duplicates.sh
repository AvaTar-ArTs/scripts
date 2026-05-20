#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail


# Script to safely remove duplicate files
# Only removes files that are identical in size and have the same timestamp

echo "Starting duplicate file cleanup..."

# Counter for removed files
removed_count=0

# Find all files with (1) in the name
find /Users/steven/Documents/04_Development_and_Code -name "*\(1\)*" -type f | while read duplicate_file; do
    # Get the original file name by removing " (1)"
    original_file=$(echo "$duplicate_file" | sed 's/ (1)//')
    
    # Check if original file exists
    if [ -f "$original_file" ]; then
        # Compare file sizes and modification times
        duplicate_size=$(stat -f%z "$duplicate_file" 2>/dev/null)
        original_size=$(stat -f%z "$original_file" 2>/dev/null)
        duplicate_time=$(stat -f%m "$duplicate_file" 2>/dev/null)
        original_time=$(stat -f%m "$original_file" 2>/dev/null)
        
        # If sizes and times are identical, remove the duplicate
        if [ "$duplicate_size" = "$original_size" ] && [ "$duplicate_time" = "$original_time" ]; then
            echo "Removing identical duplicate: $duplicate_file"
            rm "$duplicate_file"
            ((removed_count++))
        else
            echo "Keeping different file: $duplicate_file (size: $duplicate_size vs $original_size, time: $duplicate_time vs $original_time)"
        fi
    else
        # If no original exists, rename the duplicate to remove (1)
        echo "Renaming orphaned duplicate: $duplicate_file -> $original_file"
        mv "$duplicate_file" "$original_file"
        ((removed_count++))
    fi
done

echo "Cleanup complete. Removed/renamed $removed_count files."
