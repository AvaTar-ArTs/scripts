#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail


# List of files to compare and merge
files=(
    "/Users/steven/Documents/podcast/14-16-45-Podcast_Production_Assistance copy 2.md"
    "/Users/steven/Documents/podcast/ChatGPT-Project_2025_Imagery_Design.html"
    "/Users/steven/Documents/podcast/14-16-45-Podcast_Production_Assistance copy.md"
    "/Users/steven/Documents/podcast/Content Plan & Strategy.md"
    "/Users/steven/Documents/podcast/JusticeThomas.md"
    "/Users/steven/Documents/podcast/podcast-palyerzs.md"
    "/Users/steven/Documents/podcast/Podcast-Trump.md"
    "/Users/steven/Documents/podcast/Transition from Donald Trump to The Messiah of Mar-a-Lago.md"
)

# Output file
output_file="/Users/steven/Documents/podcast/merged_output.md"

# Temporary file for diffs
temp_diff="/tmp/temp_diff.txt"

# Ensure the output file is empty
> $output_file

# Compare each pair of files and merge differences into the output file
for i in "${!files[@]}"; do
    if [[ $i -gt 0 ]]; then
        # Compare the previous file with the current file
        diff "${files[$i-1]}" "${files[$i]}" > $temp_diff

        # Append the diff output to the merged file
        echo -e "\n--- Diff between ${files[$i-1]} and ${files[$i]} ---" >> $output_file
        cat $temp_diff >> $output_file
    fi
done

# Clean up
rm $temp_diff

echo "Merged content saved to: $output_file"
