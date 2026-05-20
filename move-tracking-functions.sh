#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail

# Move tracking script for organization undo capability

TRACKING_FILE="/Users/steven/tehSiTes/move_tracking_20251024_033325.csv"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

# Function to track a move operation
track_move() {
    local operation="$1"
    local source="$2"
    local destination="$3"
    local file_size=""
    local file_type=""
    
    if [ -e "$source" ]; then
        if [ -f "$source" ]; then
            file_size=$(stat -f%z "$source" 2>/dev/null || echo "unknown")
            file_type="file"
        elif [ -d "$source" ]; then
            file_size=$(du -sh "$source" | cut -f1)
            file_type="directory"
        fi
    fi
    
    echo "$TIMESTAMP,$operation,$source,$destination,$file_size,$file_type,no" >> "$TRACKING_FILE"
}

# Function to perform tracked move
move_with_tracking() {
    local source="$1"
    local destination="$2"
    
    echo "Moving: $source -> $destination"
    
    # Create destination directory if it doesn't exist
    mkdir -p "$(dirname "$destination")"
    
    # Perform the move
    if mv "$source" "$destination" 2>/dev/null; then
        track_move "MOVE" "$source" "$destination"
        echo "✅ Successfully moved: $source"
    else
        echo "❌ Failed to move: $source"
        return 1
    fi
}

# Function to create directory with tracking
mkdir_with_tracking() {
    local dir_path="$1"
    
    echo "Creating directory: $dir_path"
    
    if mkdir -p "$dir_path" 2>/dev/null; then
        track_move "MKDIR" "" "$dir_path"
        echo "✅ Successfully created: $dir_path"
    else
        echo "❌ Failed to create: $dir_path"
        return 1
    fi
}

# Export functions for use in other scripts
export -f track_move move_with_tracking mkdir_with_tracking

echo "Move tracking system initialized. CSV: $TRACKING_FILE"
