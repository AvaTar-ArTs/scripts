#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail

# Split very tall images into multiple sections

echo "✂️ Splitting tall images..."

# Check if ImageMagick is available
if ! command -v convert &> /dev/null; then
    echo "Installing ImageMagick..."
    brew install imagemagick
fi

# Create split directory
mkdir -p split

# Find and split tall images (>10k pixels height)
identify *.png | awk -F'x' '$2 > 10000 {print $1}' | while read -r file; do
    filename=$(echo "$file" | sed 's/://')
    height=$(identify "$filename" | awk -F'x' '{print $2}' | awk '{print $1}')
    
    echo "Splitting $filename (height: $height pixels)..."
    
    # Calculate number of splits needed (aim for ~5000px per section)
    sections=$(( (height + 4999) / 5000 ))
    
    for ((i=0; i<sections; i++)); do
        start_y=$((i * 5000))
        end_y=$(( (i + 1) * 5000 ))
        
        if [ $end_y -gt $height ]; then
            end_y=$height
        fi
        
        convert "$filename" -crop "2048x$((end_y - start_y))+0+$start_y" "split/${filename%.png}_part$((i+1)).png"
    done
    
    echo "  Created $sections sections"
done

echo "✅ Image splitting complete! Check split/ directory"
