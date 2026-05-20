#!/usr/bin/env bash

# Carbon Images Analysis & Optimization Script
# Analyzes Carbon-generated code images and creates opt-in optimization helpers.

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Directories
IMAGE_DIR="${1:-${IMAGE_DIR:-/Users/steven/Pictures/carbon-images}}"
ANALYSIS_DIR="./analysis"
REPORTS_DIR="./reports"

if [ ! -d "$IMAGE_DIR" ]; then
    echo -e "${RED}Image directory not found: $IMAGE_DIR${NC}"
    exit 1
fi

cd "$IMAGE_DIR"

# Create directories
mkdir -p "$ANALYSIS_DIR" "$REPORTS_DIR"

LOG_FILE="$REPORTS_DIR/analysis_$(date +%Y%m%d_%H%M%S).log"

# Function to log analysis
log_analysis() {
    echo -e "$1" | tee -a "$LOG_FILE"
}

file_size_bytes() {
    local file=$1

    if stat -f%z "$file" >/dev/null 2>&1; then
        stat -f%z "$file"
    else
        stat -c%s "$file"
    fi
}

humanize_bytes() {
    local bytes=$1
    awk -v bytes="$bytes" 'function human(x){
        if (x < 1024) return x " B";
        if (x < 1048576) return sprintf("%.2f KB", x/1024);
        if (x < 1073741824) return sprintf("%.2f MB", x/1048576);
        return sprintf("%.2f GB", x/1073741824);
    } BEGIN { print human(bytes); }'
}

if ! command -v identify &> /dev/null; then
    echo -e "${RED}ImageMagick 'identify' command not found. Please install ImageMagick to continue.${NC}"
    exit 1
fi

declare -a png_list=()
while IFS= read -r -d '' file; do
    file="${file#./}"
    png_list+=("$file")
done < <(find . -maxdepth 1 -type f -name '*.png' -print0)

total_images=${#png_list[@]}
if [ "$total_images" -eq 0 ]; then
    echo -e "${RED}No PNG files found in $IMAGE_DIR. Nothing to analyze.${NC}"
    exit 1
fi

echo -e "${CYAN}🔍 Carbon Images Analysis & Optimization${NC}"
echo "=============================================="
log_analysis "${BLUE}Image directory: $IMAGE_DIR${NC}"

log_analysis "${BLUE}📊 Analyzing image characteristics...${NC}"

DIMENSIONS_FILE="$ANALYSIS_DIR/dimensions.txt"
SIZE_CATEGORIES_FILE="$ANALYSIS_DIR/size_categories.txt"
SIZE_DATA_FILE="$ANALYSIS_DIR/.size_data.tsv"
LARGE_TMP="$ANALYSIS_DIR/.large.tmp"
MEDIUM_TMP="$ANALYSIS_DIR/.medium.tmp"
SMALL_TMP="$ANALYSIS_DIR/.small.tmp"

: > "$DIMENSIONS_FILE"
: > "$SIZE_DATA_FILE"
: > "$LARGE_TMP"
: > "$MEDIUM_TMP"
: > "$SMALL_TMP"

total_bytes=0
oversized_count=0
tall_count=0

for file in "${png_list[@]}"; do
    read -r width height < <(identify -format "%w %h\n" "$file")
    size_bytes=$(file_size_bytes "$file")
    human_size=$(humanize_bytes "$size_bytes")
    dimensions="${width}x${height}"

    printf "%s: %s (%s)\n" "$file" "$dimensions" "$human_size" >> "$DIMENSIONS_FILE"
    printf "%s\t%s\t%s\t%s\n" "$size_bytes" "$width" "$height" "$file" >> "$SIZE_DATA_FILE"

    if (( size_bytes > 2097152 )); then
        printf "%s (%s)\n" "$file" "$human_size" >> "$LARGE_TMP"
        oversized_count=$((oversized_count + 1))
    elif (( size_bytes >= 512000 )); then
        printf "%s (%s)\n" "$file" "$human_size" >> "$MEDIUM_TMP"
    else
        printf "%s (%s)\n" "$file" "$human_size" >> "$SMALL_TMP"
    fi

    if (( height > 10000 )); then
        tall_count=$((tall_count + 1))
    fi

    total_bytes=$((total_bytes + size_bytes))
done

log_analysis "${YELLOW}📏 Categorizing images by size:${NC}"
{
    echo "Large images (>2MB):"
    if [ -s "$LARGE_TMP" ]; then
        cat "$LARGE_TMP"
    else
        echo "None"
    fi
    echo
    echo "Medium images (500KB-2MB):"
    if [ -s "$MEDIUM_TMP" ]; then
        cat "$MEDIUM_TMP"
    else
        echo "None"
    fi
    echo
    echo "Small images (<500KB):"
    if [ -s "$SMALL_TMP" ]; then
        cat "$SMALL_TMP"
    else
        echo "None"
    fi
} > "$SIZE_CATEGORIES_FILE"

rm -f "$LARGE_TMP" "$MEDIUM_TMP" "$SMALL_TMP"

total_size_human=$(humanize_bytes "$total_bytes")
average_bytes=$(awk -v total="$total_bytes" -v count="$total_images" 'BEGIN { if (count == 0) { print 0 } else { printf "%.0f", total / count } }')
average_size_human=$(humanize_bytes "$average_bytes")

log_analysis "${BLUE}🎯 Identifying optimization opportunities...${NC}"
log_analysis "${YELLOW}Found $oversized_count oversized images (>2MB)${NC}"
log_analysis "${YELLOW}Found $tall_count very tall images (>10k pixels height)${NC}"

log_analysis "${BLUE}💡 Generating optimization recommendations...${NC}"

cat > "$REPORTS_DIR/optimization_recommendations.md" << 'EOF'
# Carbon Images Optimization Recommendations

## 🎯 Priority Optimizations

### 1. File Size Optimization
- **Issue**: Several images exceed 2MB, causing slow loading
- **Solution**: Implement lossless compression using pngquant or optipng
- **Expected Savings**: 20-40% file size reduction

### 2. Dimension Optimization
- **Issue**: Some images are extremely tall (20k+ pixels)
- **Solution**: Split long code files into logical sections
- **Benefit**: Better readability and faster loading

### 3. Format Optimization
- **Issue**: All images are PNG (good for code, but large)
- **Solution**: Consider WebP for web use, keep PNG for print
- **Expected Savings**: 25-50% file size reduction

### 4. Batch Processing
- **Issue**: Manual optimization is time-consuming
- **Solution**: Automated optimization pipeline
- **Benefit**: Consistent quality and size across all images

## 📊 Current Statistics
EOF

{
    echo "- Total images: $total_images"
    echo "- Total size: $total_size_human"
    echo "- Average size: $average_size_human"
} >> "$REPORTS_DIR/optimization_recommendations.md"

log_analysis "${BLUE}🛠️ Creating optimization scripts...${NC}"

cat > "optimize_pngs.sh" << 'EOF'
#!/usr/bin/env bash
set -euo pipefail

echo "🔧 Optimizing PNG files..."

for required_command in pngquant optipng; do
    if ! command -v "$required_command" > /dev/null 2>&1; then
        echo "Missing dependency: $required_command"
        echo "Install it first, then rerun this script."
        exit 1
    fi
done

shopt -s nullglob
png_files=( *.png )

if [ ${#png_files[@]} -eq 0 ]; then
    echo "No PNG files found. Skipping optimization."
    exit 0
fi

mkdir -p optimized

for file in "${png_files[@]}"; do
    echo "Optimizing $file..."

    if ! pngquant --quality=85-95 --ext .opt.png --force "$file"; then
        echo "  pngquant could not improve $file; copying original"
        cp "$file" "${file%.png}.opt.png"
    fi
    optipng -quiet -o7 -strip all "${file%.png}.opt.png"

    mv "${file%.png}.opt.png" "optimized/$file"

    original_size=$(du -h "$file" | awk '{print $1}')
    optimized_size=$(du -h "optimized/$file" | awk '{print $1}')
    echo "  $file: $original_size → $optimized_size"
done

echo "✅ Optimization complete! Check optimized/ directory"
EOF

chmod +x optimize_pngs.sh

cat > "convert_to_webp.sh" << 'EOF'
#!/usr/bin/env bash
set -euo pipefail

echo "🌐 Converting to WebP format..."

if ! command -v cwebp > /dev/null 2>&1; then
    echo "Missing dependency: cwebp"
    echo "Install the WebP tools first, then rerun this script."
    exit 1
fi

shopt -s nullglob
png_files=( *.png )

if [ ${#png_files[@]} -eq 0 ]; then
    echo "No PNG files found. Skipping conversion."
    exit 0
fi

mkdir -p webp

for file in "${png_files[@]}"; do
    echo "Converting $file to WebP..."
    cwebp -q 85 -m 6 "$file" -o "webp/${file%.png}.webp"

    png_size=$(du -h "$file" | awk '{print $1}')
    webp_size=$(du -h "webp/${file%.png}.webp" | awk '{print $1}')
    echo "  $file: $png_size → $webp_size"
done

echo "✅ WebP conversion complete! Check webp/ directory"
EOF

chmod +x convert_to_webp.sh

cat > "split_tall_images.sh" << 'EOF'
#!/usr/bin/env bash
set -euo pipefail

echo "✂️ Splitting tall images..."

if command -v magick > /dev/null 2>&1; then
    convert_command=(magick)
elif command -v convert > /dev/null 2>&1; then
    convert_command=(convert)
else
    echo "Missing dependency: ImageMagick"
    echo "Install ImageMagick first, then rerun this script."
    exit 1
fi

if ! command -v identify > /dev/null 2>&1; then
    echo "Missing dependency: identify"
    echo "Install ImageMagick first, then rerun this script."
    exit 1
fi

shopt -s nullglob
png_files=( *.png )

if [ ${#png_files[@]} -eq 0 ]; then
    echo "No PNG files found. Nothing to split."
    exit 0
fi

mkdir -p split

created_sections=0
for file in "${png_files[@]}"; do
    read -r width height < <(identify -format "%w %h\n" "$file")

    if (( height <= 10000 )); then
        continue
    fi

    echo "Splitting $file (height: $height pixels)..."

    sections=$(( (height + 4999) / 5000 ))
    for ((i=0; i<sections; i++)); do
        start_y=$(( i * 5000 ))
        remaining=$(( height - start_y ))
        chunk_height=$(( remaining > 5000 ? 5000 : remaining ))

        "${convert_command[@]}" "$file" -crop "${width}x${chunk_height}+0+${start_y}" "split/${file%.png}_part$((i+1)).png"
        created_sections=$((created_sections + 1))
    done

    echo "  Created $sections sections"
done

if [ "$created_sections" -eq 0 ]; then
    echo "No images exceeded the height threshold. Nothing to split."
fi

echo "✅ Image splitting complete! Check split/ directory"
EOF

chmod +x split_tall_images.sh

log_analysis "${BLUE}📈 Creating quality analysis...${NC}"

QUALITY_FILE="$ANALYSIS_DIR/quality_analysis.txt"
{
    echo "Carbon Images Quality Analysis"
    echo "============================="
    echo
    echo "Generated: $(date)"
    echo "Total Images: $total_images"
    echo "Total Size: $total_size_human"
    echo
    echo "Size Distribution (Top 10 by File Size):"
} > "$QUALITY_FILE"

size_count=0
while IFS=$'\t' read -r size_bytes width height file; do
    human=$(humanize_bytes "$size_bytes")
    printf "%s - %s (%sx%s)\n" "$human" "$file" "$width" "$height" >> "$QUALITY_FILE"
    size_count=$((size_count + 1))
done < <(sort -t $'\t' -nr -k1,1 "$SIZE_DATA_FILE" | head -10)

if [ "$size_count" -eq 0 ]; then
    echo "None" >> "$QUALITY_FILE"
fi

{
    echo
    echo "Largest Images (Top 5 by File Size):"
} >> "$QUALITY_FILE"

largest_count=0
while IFS=$'\t' read -r size_bytes width height file; do
    human=$(humanize_bytes "$size_bytes")
    printf "%s - %s (%sx%s)\n" "$human" "$file" "$width" "$height" >> "$QUALITY_FILE"
    largest_count=$((largest_count + 1))
done < <(sort -t $'\t' -nr -k1,1 "$SIZE_DATA_FILE" | head -5)

if [ "$largest_count" -eq 0 ]; then
    echo "None" >> "$QUALITY_FILE"
fi

{
    echo
    echo "Tallest Images (Top 5 by Height):"
} >> "$QUALITY_FILE"

tallest_count=0
while IFS=$'\t' read -r size_bytes width height file; do
    human=$(humanize_bytes "$size_bytes")
    printf "%s px - %s (%sx%s, %s)\n" "$height" "$file" "$width" "$height" "$human" >> "$QUALITY_FILE"
    tallest_count=$((tallest_count + 1))
done < <(sort -t $'\t' -nr -k3,3 "$SIZE_DATA_FILE" | head -5)

if [ "$tallest_count" -eq 0 ]; then
    echo "None" >> "$QUALITY_FILE"
fi

cat <<'EOF' >> "$QUALITY_FILE"

Recommendations:
1. Optimize files >2MB for web use
2. Split images >10k pixels height
3. Consider WebP format for web deployment
4. Implement automated optimization pipeline
EOF

rm -f "$SIZE_DATA_FILE"

cat > "batch_optimize.sh" << 'EOF'
#!/usr/bin/env bash
set -euo pipefail

humanize_bytes() {
    local bytes=$1
    awk -v bytes="$bytes" 'function human(x){
        if (x < 1024) return x " B";
        if (x < 1048576) return sprintf("%.2f KB", x/1024);
        if (x < 1073741824) return sprintf("%.2f MB", x/1048576);
        return sprintf("%.2f GB", x/1073741824);
    } BEGIN { print human(bytes); }'
}

sum_sizes() {
    local total=0
    local file size
    for file in "$@"; do
        if [ -f "$file" ]; then
            if stat -f%z "$file" > /dev/null 2>&1; then
                size=$(stat -f%z "$file")
            else
                size=$(stat -c%s "$file")
            fi
            total=$((total + size))
        fi
    done
    printf "%s" "$total"
}

echo "🚀 Starting batch optimization process..."

./optimize_pngs.sh
./convert_to_webp.sh
./split_tall_images.sh

echo "📊 Generating final optimization report..."

shopt -s nullglob
png_files=( *.png )
optimized_files=( optimized/*.png )
webp_files=( webp/*.webp )
split_files=( split/*.png )

original_size_bytes=$(sum_sizes "${png_files[@]}")
optimized_size_bytes=$(sum_sizes "${optimized_files[@]}")
webp_size_bytes=$(sum_sizes "${webp_files[@]}")

original_size_human=$(humanize_bytes "$original_size_bytes")
optimized_size_human=$(humanize_bytes "$optimized_size_bytes")
webp_size_human=$(humanize_bytes "$webp_size_bytes")

cat > "optimization_report.md" <<REPORT
# Carbon Images Optimization Report

## Summary
- Original images: ${#png_files[@]} files, ${original_size_human} total
- Optimized PNGs: ${#optimized_files[@]} files, ${optimized_size_human} total
- WebP versions: ${#webp_files[@]} files, ${webp_size_human} total
- Split images: ${#split_files[@]} files

## File Size Comparison
REPORT

{
    echo "| Format | Count | Total Size |"
    echo "|--------|-------|------------|"
    echo "| Original PNG | ${#png_files[@]} | ${original_size_human} |"
    if [ "${#optimized_files[@]}" -gt 0 ]; then
        echo "| Optimized PNG | ${#optimized_files[@]} | ${optimized_size_human} |"
    fi
    if [ "${#webp_files[@]}" -gt 0 ]; then
        echo "| WebP | ${#webp_files[@]} | ${webp_size_human} |"
    fi
} >> optimization_report.md

echo "✅ Batch optimization complete!"
echo "📁 Check the following directories:"
echo "   - optimized/ (optimized PNG files)"
echo "   - webp/ (WebP format files)"
echo "   - split/ (split tall images)"
echo "   - optimization_report.md (detailed report)"
EOF

chmod +x batch_optimize.sh

log_analysis "${GREEN}✅ Analysis complete!${NC}"
log_analysis "${CYAN}📁 Generated files:${NC}"
log_analysis "   - analysis/ (detailed analysis files)"
log_analysis "   - reports/ (optimization recommendations)"
log_analysis "   - optimize_pngs.sh (PNG optimization script)"
log_analysis "   - convert_to_webp.sh (WebP conversion script)"
log_analysis "   - split_tall_images.sh (image splitting script)"
log_analysis "   - batch_optimize.sh (master optimization script)"

log_analysis "${YELLOW}🎯 Key Findings:${NC}"
log_analysis "   - $oversized_count oversized images need optimization"
log_analysis "   - $tall_count very tall images could be split"
log_analysis "   - Total size: $total_size_human across $total_images images"
log_analysis "   - Potential 20-50% size reduction with optimization"

log_analysis "${BLUE}🚀 Next Steps:${NC}"
log_analysis "   1. Run: ./batch_optimize.sh (runs all optimizations)"
log_analysis "   2. Or run individual scripts for specific optimizations"
log_analysis "   3. Check optimization_report.md for detailed results"

echo -e "${GREEN}🎉 Carbon Images Analysis & Optimization Setup Complete!${NC}"
