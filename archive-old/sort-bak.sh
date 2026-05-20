#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail


# Define the base directories to scan for top-level items
BASE_DIRECTORIES=(
    "/Users/steven"
    "/Library"
    "/Applications"
)

# Define a list of needed items (customize this list based on your requirements)
NEEDED_ITEMS=(
    "/Users/steven/Documents"
    "/Users/steven/Pictures"
    "/Users/steven/Music"
    "/Users/steven/Movies"
    "/Users/steven/Downloads"
    "/Users/steven/Desktop"
    "/Applications/SomeImportantApp.app"
    "/Library/Preferences/com.example.important.plist"
)

BACKUP_DIR="/Volumes/2T-Xx/$(date +%Y%m%d)"
CSV_FILE="$BACKUP_DIR/dry_run_backup.csv"

# Create backup directory if it doesn't exist
mkdir -p "$BACKUP_DIR"

# Initialize CSV file with headers
echo "Item,Status,Category" > "$CSV_FILE"

# Function to check if an item is in the needed list
is_needed() {
    local item="$1"
    for needed_item in "${NEEDED_ITEMS[@]}"; do
        if [ "$item" == "$needed_item" ]; then
            return 0
        fi
    done
    return 1
}

# Function to simulate a backup for a directory or file
simulate_backup_item() {
    local item="$1"
    local status="Does not exist"
    local category="Extras"

    if [ -e "$item" ]; then
        status="Exists"
        if is_needed "$item"; then
            category="Needed"
        fi
    fi

    echo "$item,$status,$category" >> "$CSV_FILE"
}

# Scan each base directory for top-level items
for base_dir in "${BASE_DIRECTORIES[@]}"; do
    if [ -d "$base_dir" ]; then
        for item in "$base_dir"/*; do
            simulate_backup_item "$item"
        done
    else
        echo "$base_dir,Does not exist,Extras" >> "$CSV_FILE"
    fi
done

echo "Dry run completed. Results saved to $CSV_FILE."
