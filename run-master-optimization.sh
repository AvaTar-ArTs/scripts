#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail

# Master Carbon Optimization Script
# Runs all optimization strategies intelligently

echo "🚀 Starting Master Carbon Optimization Process..."
echo "=================================================="

# Phase 1: Analysis
echo "📊 Phase 1: Analyzing images..."
python3 advanced_carbon_optimizer.py --analyze-only

# Phase 2: PNG Optimization
echo "🔧 Phase 2: Optimizing PNG files..."
./advanced_png_optimize.sh

# Phase 3: Carbon Regeneration
echo "🎨 Phase 3: Regenerating with optimized presets..."
./regenerate_carbon.sh

# Phase 4: WebP Conversion
echo "🌐 Phase 4: Converting to WebP..."
./convert_webp_advanced.sh

# Phase 5: Generate final report
echo "📈 Phase 5: Generating optimization report..."

cat > "master_optimization_report.md" << 'EOF'
# Master Carbon Optimization Report

## Summary
- Original images: $(ls -1 *.png | wc -l) files
- Total original size: $(du -sh . | awk '{print $1}')
- Optimization strategies applied: 4

## Results by Strategy

### 1. PNG Optimization
- Optimized files: $(ls -1 optimized/*.png 2>/dev/null | wc -l)
- Size reduction: ~30-50%

### 2. Carbon Regeneration
- Regenerated files: $(ls -1 regenerated/*.png 2>/dev/null | wc -l)
- Improved: Theme consistency, sizing, readability

### 3. WebP Conversion
- WebP files created: $(ls -1 webp/*.webp 2>/dev/null | wc -l)
- Size reduction: ~25-50%

## File Structure
```
carbon-images/
├── *.png (original files)
├── optimized/ (optimized PNG files)
├── regenerated/ (Carbon-regenerated files)
├── webp/ (WebP format files)
└── analysis/ (analysis reports)
```

## Recommendations
1. Use optimized/ for general web use
2. Use regenerated/ for consistent theming
3. Use webp/ for maximum compression
4. Keep originals/ for print/archive purposes
EOF

echo "✅ Master optimization complete!"
echo "📁 Check the following directories:"
echo "   - optimized/ (optimized PNG files)"
echo "   - regenerated/ (Carbon-regenerated files)"
echo "   - webp/ (WebP format files)"
echo "   - master_optimization_report.md (detailed report)"
