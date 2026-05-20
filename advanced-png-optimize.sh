#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail

# Advanced PNG Optimization Script
# Based on Carbon's capabilities and best practices

echo "🔧 Advanced PNG Optimization Starting..."

# Install required tools
install_tools() {
    if ! command -v pngquant &> /dev/null; then
        echo "Installing pngquant..."
        brew install pngquant
    fi
    
    if ! command -v optipng &> /dev/null; then
        echo "Installing optipng..."
        brew install optipng
    fi
    
    if ! command -v cwebp &> /dev/null; then
        echo "Installing webp..."
        brew install webp
    fi
}

# Optimize based on image characteristics
optimize_image() {
    local file="$1"
    local size_mb=$(du -m "$file" | cut -f1)
    local height=$(identify "$file" | awk -F'x' '{print $2}' | awk '{print $1}')
    
    echo "Optimizing $file (Size: $size_mb MB, Height: $height px)..."
    
    # Choose optimization strategy based on characteristics
    if [ $size_mb -gt 5 ] || [ $height -gt 15000 ]; then
        # Aggressive optimization for very large files
        pngquant --quality=80-90 --ext .opt.png "$file"
        optipng -o7 -strip all "${file%.png}.opt.png"
    elif [ $size_mb -gt 2 ] || [ $height -gt 8000 ]; then
        # Moderate optimization
        pngquant --quality=85-95 --ext .opt.png "$file"
        optipng -o5 -strip all "${file%.png}.opt.png"
    else
        # Light optimization
        pngquant --quality=90-100 --ext .opt.png "$file"
        optipng -o3 -strip all "${file%.png}.opt.png"
    fi
    
    # Move to output directory
    mv "${file%.png}.opt.png" "optimized/$file"
    
    # Show results
    original_size=$(du -h "$file" | awk '{print $1}')
    optimized_size=$(du -h "optimized/$file" | awk '{print $1}')
    echo "  ✓ $file: $original_size → $optimized_size"
}

# Main optimization process
install_tools
mkdir -p optimized

# Process each PNG file
for file in *.png; do
    optimize_image "$file"
done

echo "✅ PNG optimization complete!"
