#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail

# Convert PNG images to WebP format for web use

echo "🌐 Converting to WebP format..."

# Check if cwebp is available
if ! command -v cwebp &> /dev/null; then
    echo "Installing webp tools..."
    brew install webp
fi

# Create webp directory
mkdir -p webp

# Convert each PNG to WebP
for file in *.png; do
    echo "Converting $file to WebP..."
    cwebp -q 85 -m 6 "$file" -o "webp/${file%.png}.webp"
    
    # Show size comparison
    png_size=$(du -h "$file" | awk '{print $1}')
    webp_size=$(du -h "webp/${file%.png}.webp" | awk '{print $1}')
    echo "  $file: $png_size → $webp_size"
done

echo "✅ WebP conversion complete! Check webp/ directory"
