#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail


# Add the gallery tools to PATH
export PATH="/Users/steven/Library/Python/3.9/bin:$PATH"

# Array of directories to process
directories=(
    "/Users/steven/Pictures/etsy/2d-3d-cut"
    "/Users/steven/Pictures/etsy/250-funny-animal-stckers"
    "/Users/steven/Pictures/etsy/Adobe-Freebie"
    "/Users/steven/Pictures/etsy/analysis"
    "/Users/steven/Pictures/etsy/BLady"
    "/Users/steven/Pictures/etsy/CiTy-FiXeS"
    "/Users/steven/Pictures/etsy/Cookie"
    "/Users/steven/Pictures/etsy/CoverCards"
    "/Users/steven/Pictures/etsy/CoverConTactSheets"
    "/Users/steven/Pictures/etsy/cuts"
    "/Users/steven/Pictures/etsy/EpicT-CuTs"
    "/Users/steven/Pictures/etsy/etsy_store_exporter"
    "/Users/steven/Pictures/etsy/etsy-bestseller-optimizer-toolkit"
    "/Users/steven/Pictures/etsy/Funny Sarcastic SVG Bundle"
    "/Users/steven/Pictures/etsy/Funny-Raccoon-PNG-Sublimation-Bundle-100305013"
    "/Users/steven/Pictures/etsy/ideo-9-9"
    "/Users/steven/Pictures/etsy/ideo-all-top"
    "/Users/steven/Pictures/etsy/ideo-images"
    "/Users/steven/Pictures/etsy/ideo-Tshirt"
    "/Users/steven/Pictures/etsy/ideoGram 15b36221"
    "/Users/steven/Pictures/etsy/ideogram-to-sell"
    "/Users/steven/Pictures/etsy/Inspired-by-Harry-Potter-Tumbler-112322382"
    "/Users/steven/Pictures/etsy/KAMALA"
    "/Users/steven/Pictures/etsy/MyDesign-zip-cover-IMGs"
    "/Users/steven/Pictures/etsy/notion-ideo Juice"
    "/Users/steven/Pictures/etsy/PanoramicIndexJuice"
    "/Users/steven/Pictures/etsy/POPuLAR"
    "/Users/steven/Pictures/etsy/poster"
    "/Users/steven/Pictures/etsy/RetroT"
    "/Users/steven/Pictures/etsy/Tiktok-etsy"
    "/Users/steven/Pictures/etsy/to-SeLL"
    "/Users/steven/Pictures/etsy/TOP"
    "/Users/steven/Pictures/etsy/trans"
    "/Users/steven/Pictures/etsy/tShirt"
    "/Users/steven/Pictures/etsy/tumble-vid-mockup"
)

# Function to process a single directory
process_directory() {
    local dir="$1"
    echo "Processing: $dir"
    
    # Check if directory exists
    if [ ! -d "$dir" ]; then
        echo "  ❌ Directory does not exist: $dir"
        return 1
    fi
    
    # Run gallery-init -p with defaults
    echo "  Running gallery-init -p --use-defaults..."
    if gallery-init -p "$dir" --use-defaults; then
        echo "  ✅ gallery-init completed successfully"
    else
        echo "  ❌ gallery-init failed for: $dir"
        return 1
    fi
    
    # Run gallery-build -p
    echo "  Running gallery-build -p..."
    if gallery-build -p "$dir"; then
        echo "  ✅ gallery-build completed successfully"
    else
        echo "  ❌ gallery-build failed for: $dir"
        return 1
    fi
    
    echo "  ✅ Completed processing: $dir"
    echo ""
}

# Process all directories
echo "Starting batch processing of ${#directories[@]} directories..."
echo "================================================"

success_count=0
error_count=0

for dir in "${directories[@]}"; do
    if process_directory "$dir"; then
        ((success_count++))
    else
        ((error_count++))
    fi
done

echo "================================================"
echo "Batch processing completed!"
echo "✅ Successful: $success_count"
echo "❌ Failed: $error_count"
echo "Total processed: $((success_count + error_count))"
