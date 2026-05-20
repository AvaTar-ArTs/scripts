#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail

# Master script to run all optimizations

echo "🚀 Starting batch optimization process..."

# Run PNG optimization
./optimize_pngs.sh

# Convert to WebP
./convert_to_webp.sh

# Split tall images
./split_tall_images.sh

# Generate final report
echo "📊 Generating final optimization report..."

cat > "optimization_report.md" << 'REPORT'
# Carbon Images Optimization Report

## Summary
- Original images: $(ls -1 *.png | wc -l) files, $(du -sh . | awk '{print $1}') total
- Optimized PNGs: $(ls -1 optimized/*.png 2>/dev/null | wc -l) files
- WebP versions: $(ls -1 webp/*.webp 2>/dev/null | wc -l) files
- Split images: $(ls -1 split/*.png 2>/dev/null | wc -l) files

## File Size Comparison
REPORT

# Add size comparisons
echo "| Format | Count | Total Size |" >> optimization_report.md
echo "|--------|-------|------------|" >> optimization_report.md
echo "| Original PNG | $(ls -1 *.png | wc -l) | $(du -sh . | awk '{print $1}') |" >> optimization_report.md
if [ -d "optimized" ]; then
    echo "| Optimized PNG | $(ls -1 optimized/*.png 2>/dev/null | wc -l) | $(du -sh optimized 2>/dev/null | awk '{print $1}') |" >> optimization_report.md
fi
if [ -d "webp" ]; then
    echo "| WebP | $(ls -1 webp/*.webp 2>/dev/null | wc -l) | $(du -sh webp 2>/dev/null | awk '{print $1}') |" >> optimization_report.md
fi

echo "✅ Batch optimization complete!"
echo "📁 Check the following directories:"
echo "   - optimized/ (optimized PNG files)"
echo "   - webp/ (WebP format files)"
echo "   - split/ (split tall images)"
echo "   - optimization_report.md (detailed report)"
