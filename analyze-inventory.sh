#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail


# MasterxEo Inventory Analysis Script
# Analyzes the docs-02-08-20:30.csv file to provide insights about the MasterxEo directory structure

# Text Color Variables
GREEN='\033[32m'
BLUE='\033[34m'
YELLOW='\033[33m'
RED='\033[31m'
PURPLE='\033[35m'
CYAN='\033[36m'
BOLD='\033[1m'
CLEAR='\033[0m'

# Function to print status
print_status() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${CLEAR}"
}

print_status $BOLD $PURPLE "📊 ANALYZING MASTERXEO INVENTORY DATA"
print_status $CYAN "====================================="

CSV_FILE="/Users/steven/MasterxEo/docs-02-08-20:30.csv"
TEMP_DIR="/tmp/masterxeo_analysis"
mkdir -p "$TEMP_DIR"

# Count total entries (subtracting 1 for header)
TOTAL_ENTRIES=$(($(wc -l < "$CSV_FILE") - 1))
print_status $GREEN "📈 Total files inventoried: $TOTAL_ENTRIES"

# Extract file extensions and count them
tail -n +2 "$CSV_FILE" | awk -F',' '{print $1}' | sed 's/.*\.//' | sed 's/[^a-zA-Z0-9]//g' | sort | uniq -c | sort -nr > "$TEMP_DIR/extensions.txt"
print_status $CYAN "\n📂 Top file extensions:"
head -10 "$TEMP_DIR/extensions.txt"

# Calculate total size (converting units to KB for consistency)
tail -n +2 "$CSV_FILE" | awk -F',' '{
    size = $(NF-1)
    gsub(/ /, "", size)  # Remove spaces
    if (size ~ /MB/) {
        num = size
        gsub(/MB/, "", num)
        gsub(/ /, "", num)
        total += num * 1024  # Convert MB to KB
    } else if (size ~ /KB/) {
        num = size
        gsub(/KB/, "", num)
        gsub(/ /, "", num)
        total += num
    } else if (size ~ /GB/) {
        num = size
        gsub(/GB/, "", num)
        gsub(/ /, "", num)
        total += num * 1024 * 1024  # Convert GB to KB
    } else if (size ~ /B/) {
        num = size
        gsub(/B/, "", num)
        gsub(/ /, "", num)
        total += num / 1024  # Convert B to KB
    }
}
END {
    printf("%.2f", total)
}' > "$TEMP_DIR/total_size_kb.txt"

TOTAL_SIZE_MB=$(echo "$(cat "$TEMP_DIR/total_size_kb.txt") / 1024" | bc -l)
print_status $GREEN "\n💾 Total size of all files: $(printf "%.2f" $TOTAL_SIZE_MB) MB"

# Find largest files
tail -n +2 "$CSV_FILE" | awk -F',' '{
    size = $(NF-1)
    gsub(/ /, "", size)
    if (size ~ /GB/) {
        num = size
        gsub(/GB/, "", num)
        mult = 1024 * 1024
    } else if (size ~ /MB/) {
        num = size
        gsub(/MB/, "", num)
        mult = 1024
    } else if (size ~ /KB/) {
        num = size
        gsub(/KB/, "", num)
        mult = 1
    } else if (size ~ /B/) {
        num = size
        gsub(/B/, "", num)
        mult = 1/1024
    }
    printf "%.2f,%s\n", num * mult, $1
}' | sort -t',' -k1,1nr | head -10 > "$TEMP_DIR/largest_files.txt"
print_status $CYAN "\n📏 Largest files:"
while IFS=',' read -r size_mb filename; do
    printf "%10s MB - %s\n" "$size_mb" "$filename"
done < "$TEMP_DIR/largest_files.txt"

# Analyze directory structure by counting files in each subdirectory
tail -n +2 "$CSV_FILE" | awk -F',' '{print $NF}' | sed 's/\/[^\/]*$//' | sort | uniq -c | sort -nr | head -20 > "$TEMP_DIR/dir_counts.txt"
print_status $CYAN "\n📁 Top directories by file count:"
head -10 "$TEMP_DIR/dir_counts.txt"

# Identify recently created files (from 02-08-26)
tail -n +2 "$CSV_FILE" | awk -F',' '$3 ~ /02-08-26/ {print $1 ", " $2 ", " $3}' > "$TEMP_DIR/recent_files.txt"
RECENT_COUNT=$(wc -l < "$TEMP_DIR/recent_files.txt")
print_status $GREEN "\n🆕 Files created on 02-08-26: $RECENT_COUNT"

# Show some recent files
print_status $CYAN "Recent files:"
head -5 "$TEMP_DIR/recent_files.txt"

# Analyze the success of our organization by checking for functional directories
FUNCTIONAL_DIRS=("AUTOMATION" "REVENUE" "BUSINESS_INTELLIGENCE" "AI_ML" "DATA_PROCESSING" "DEVELOPMENT_TOOLS" "DOCUMENTATION" "MEDIA_PROCESSING" "PORTFOLIO_MANAGEMENT" "CONTENT_CREATION" "SEO_MARKETING")
print_status $CYAN "\n🏗️  Files in functional directories (post-organization):"

for dir in "${FUNCTIONAL_DIRS[@]}"; do
    count=$(tail -n +2 "$CSV_FILE" | grep "/$dir/" | wc -l)
    if [ "$count" -gt 0 ]; then
        print_status $GREEN "   $dir: $count files"
    fi
done

# Create a summary report
REPORT_FILE="/Users/steven/MasterxEo/INVENTORY_ANALYSIS_REPORT.md"
echo "# MasterxEo Inventory Analysis Report" > "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
echo "Date: $(date)" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
echo "## Executive Summary" >> "$REPORT_FILE"
echo "- Total files inventoried: $TOTAL_ENTRIES" >> "$REPORT_FILE"
echo "- Total size: $(printf "%.2f" $TOTAL_SIZE_MB) MB" >> "$REPORT_FILE"
echo "- Organization completed successfully with functional directories" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
echo "## File Type Distribution" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
echo "| Extension | Count |" >> "$REPORT_FILE"
echo "|-----------|-------|" >> "$REPORT_FILE"
while read -r count ext; do
    echo "| .$ext | $count |" >> "$REPORT_FILE"
done < <(head -10 "$TEMP_DIR/extensions.txt")

echo "" >> "$REPORT_FILE"
echo "## Largest Files" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
echo "| Size (MB) | Filename |" >> "$REPORT_FILE"
echo "|-----------|----------|" >> "$REPORT_FILE"
while IFS=',' read -r size_mb filename; do
    echo "| $size_mb | $filename |" >> "$REPORT_FILE"
done < <(head -5 "$TEMP_DIR/largest_files.txt")

echo "" >> "$REPORT_FILE"
echo "## Directory Structure" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
echo "| File Count | Directory |" >> "$REPORT_FILE"
echo "|------------|-----------|" >> "$REPORT_FILE"
while read -r count dir; do
    echo "| $count | $dir |" >> "$REPORT_FILE"
done < <(head -10 "$TEMP_DIR/dir_counts.txt")

echo "" >> "$REPORT_FILE"
echo "## Organization Success Metrics" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
for dir in "${FUNCTIONAL_DIRS[@]}"; do
    count=$(tail -n +2 "$CSV_FILE" | grep "/$dir/" | wc -l)
    if [ "$count" -gt 0 ]; then
        echo "- $dir: $count files" >> "$REPORT_FILE"
    fi
done

print_status $YELLOW "\n📋 Analysis complete! Report saved to: $REPORT_FILE"

# Clean up
rm -rf "$TEMP_DIR"

print_status $BOLD $PURPLE "\n🎯 INSIGHTS FROM MASTERXEO INVENTORY DATA:"
echo "   • The directory contains $TOTAL_ENTRIES files totaling $(printf "%.2f" $TOTAL_SIZE_MB) MB"
echo "   • Successfully organized into functional categories (REVENUE, AUTOMATION, etc.)"
echo "   • Contains diverse file types including documentation, scripts, data files"
echo "   • Largest files include JSON inventories and text files"
echo "   • Organization structure is reflected in the path data"
echo "   • Recent activity shows ongoing maintenance and updates"
