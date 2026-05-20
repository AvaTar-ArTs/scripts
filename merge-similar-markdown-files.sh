#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail


# Create or clear the merged output file
merged_file="merged_output.md"
> "$merged_file"

# Declare an associative array to hold file groups
declare -A file_groups

# Loop through all .md files and group them by base name
for file in *.md; do
    # Get the base name (everything before the first underscore or space)
    base_name="${file%%_*}"
    base_name="${base_name%% *}"  # Remove anything after the first space
    file_groups["$base_name"]+="$file "
done

# Merge files with the same base name
for base_name in "${!file_groups[@]}"; do
    echo "### Merging files for base name: $base_name ###" >> "$merged_file"
    for file in ${file_groups["$base_name"]}; do
        echo "#### Content from $file ####" >> "$merged_file"
        cat "$file" >> "$merged_file"
        echo -e "\n" >> "$merged_file" # Add a newline for better separation
    done
done

echo "Merging complete. Output saved to $merged_file."
