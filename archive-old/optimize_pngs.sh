#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail

# Lossless PNG optimization using pngquant and optipng

echo "🔧 Optimizing PNG files..."

# Check if tools are available
if ! command -v pngquant &> /dev/null; then
    echo "Installing pngquant..."
    brew install pngquant
fi

if ! command -v optipng &> /dev/null; then
    echo "Installing optipng..."
    brew install optipng
fi

# Create optimized directory
mkdir -p optimized

# Optimize each PNG
for file in *.png; do
    echo "Optimizing $file..."
    
    # First pass: pngquant (lossy but good quality)
    pngquant --quality=85-95 --ext .opt.png "$file"
    
    # Second pass: optipng (lossless)
    optipng -o7 -strip all "${file%.png}.opt.png"
    
    # Move to optimized directory
    mv "${file%.png}.opt.png" "optimized/$file"
    
    # Show size comparison
    original_size=$(du -h "$file" | awk '{print $1}')
    optimized_size=$(du -h "optimized/$file" | awk '{print $1}')
    echo "  $file: $original_size → $optimized_size"
done

echo "✅ Optimization complete! Check optimized/ directory"
