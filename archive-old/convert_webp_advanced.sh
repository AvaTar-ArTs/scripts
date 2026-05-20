#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail

# Advanced WebP Conversion Script
# Creates multiple WebP variants for different use cases

echo "🌐 Converting to WebP with multiple quality levels..."

mkdir -p webp

convert_to_webp() {
    local file="$1"
    local quality="$2"
    local suffix="$3"
    
    echo "Converting $file to WebP (quality: $quality)..."
    cwebp -q $quality -m 6 "$file" -o "webp/${file%.png}_$suffix.webp"
    
    # Show size comparison
    png_size=$(du -h "$file" | awk '{print $1}')
    webp_size=$(du -h "webp/${file%.png}_$suffix.webp" | awk '{print $1}')
    echo "  ✓ $file: $png_size → $webp_size (quality: $quality)"
}

# Convert with different quality levels
for file in *.png; do
    # High quality for print/web
    convert_to_webp "$file" 90 "high"
    
    # Medium quality for general web use
    convert_to_webp "$file" 75 "medium"
    
    # Low quality for thumbnails/previews
    convert_to_webp "$file" 60 "low"
done

echo "✅ WebP conversion complete!"
