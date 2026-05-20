#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail


# Batch Drive Analysis Script
# Run this when both drives are accessible

echo "=== BATCH DRIVE ANALYSIS SCRIPT ==="
echo "Starting analysis at: $(date)"

# Create output directory
mkdir -p "/Users/steven/drive_analysis_output"

# Function to analyze file type
analyze_file_type() {
    local drive_path="$1"
    local file_pattern="$2"
    local file_type="$3"
    local output_file="$4"
    
    echo "Analyzing $file_type files on $drive_path..."
    
    # Create CSV header
    echo "File_Path,File_Name,File_Size_Bytes,File_Size_MB,Date_Modified,Directory" > "$output_file"
    
    # Find and process files
    find "$drive_path" -name "$file_pattern" -type f -exec stat -f "%N,%z,%SB,%Sm" {} \; 2>/dev/null | while IFS=',' read -r path size size_human date; do
        filename=$(basename "$path")
        directory=$(dirname "$path")
        size_mb=$((size / 1024 / 1024))
        echo "$path,$filename,$size,$size_mb,$date,$directory" >> "$output_file"
    done
    
    echo "Completed $file_type analysis: $(wc -l < "$output_file") files"
}

# BATCH 1: ZIP Files
echo "=== BATCH 1: ZIP FILES ==="
analyze_file_type "/Volumes/2T-Xx" "*.zip" "ZIP" "/Users/steven/drive_analysis_output/2T-Xx_zip_files.csv"
analyze_file_type "/Volumes/DeVonDaTa" "*.zip" "ZIP" "/Users/steven/drive_analysis_output/DeVonDaTa_zip_files.csv"

# BATCH 2: Video Files
echo "=== BATCH 2: VIDEO FILES ==="
analyze_file_type "/Volumes/2T-Xx" "*.mp4" "MP4" "/Users/steven/drive_analysis_output/2T-Xx_mp4_files.csv"
analyze_file_type "/Volumes/DeVonDaTa" "*.mp4" "MP4" "/Users/steven/drive_analysis_output/DeVonDaTa_mp4_files.csv"

# BATCH 3: Image Files
echo "=== BATCH 3: IMAGE FILES ==="
analyze_file_type "/Volumes/2T-Xx" "*.jpg" "JPG" "/Users/steven/drive_analysis_output/2T-Xx_jpg_files.csv"
analyze_file_type "/Volumes/2T-Xx" "*.png" "PNG" "/Users/steven/drive_analysis_output/2T-Xx_png_files.csv"
analyze_file_type "/Volumes/DeVonDaTa" "*.jpg" "JPG" "/Users/steven/drive_analysis_output/DeVonDaTa_jpg_files.csv"
analyze_file_type "/Volumes/DeVonDaTa" "*.png" "PNG" "/Users/steven/drive_analysis_output/DeVonDaTa_png_files.csv"

# BATCH 4: Audio Files
echo "=== BATCH 4: AUDIO FILES ==="
analyze_file_type "/Volumes/2T-Xx" "*.mp3" "MP3" "/Users/steven/drive_analysis_output/2T-Xx_mp3_files.csv"
analyze_file_type "/Volumes/DeVonDaTa" "*.mp3" "MP3" "/Users/steven/drive_analysis_output/DeVonDaTa_mp3_files.csv"

# BATCH 5: Document Files
echo "=== BATCH 5: DOCUMENT FILES ==="
analyze_file_type "/Volumes/2T-Xx" "*.pdf" "PDF" "/Users/steven/drive_analysis_output/2T-Xx_pdf_files.csv"
analyze_file_type "/Volumes/DeVonDaTa" "*.pdf" "PDF" "/Users/steven/drive_analysis_output/DeVonDaTa_pdf_files.csv"

# BATCH 6: Design Files
echo "=== BATCH 6: DESIGN FILES ==="
analyze_file_type "/Volumes/2T-Xx" "*.psd" "PSD" "/Users/steven/drive_analysis_output/2T-Xx_psd_files.csv"
analyze_file_type "/Volumes/DeVonDaTa" "*.psd" "PSD" "/Users/steven/drive_analysis_output/DeVonDaTa_psd_files.csv"

echo "=== ANALYSIS COMPLETE ==="
echo "Results saved to: /Users/steven/drive_analysis_output/"
echo "Completed at: $(date)"

# Create summary
echo "=== SUMMARY ==="
echo "2T-Xx Drive:"
echo "  ZIP files: $(wc -l < /Users/steven/drive_analysis_output/2T-Xx_zip_files.csv 2>/dev/null || echo 0)"
echo "  MP4 files: $(wc -l < /Users/steven/drive_analysis_output/2T-Xx_mp4_files.csv 2>/dev/null || echo 0)"
echo "  JPG files: $(wc -l < /Users/steven/drive_analysis_output/2T-Xx_jpg_files.csv 2>/dev/null || echo 0)"
echo "  PNG files: $(wc -l < /Users/steven/drive_analysis_output/2T-Xx_png_files.csv 2>/dev/null || echo 0)"
echo "  MP3 files: $(wc -l < /Users/steven/drive_analysis_output/2T-Xx_mp3_files.csv 2>/dev/null || echo 0)"
echo "  PDF files: $(wc -l < /Users/steven/drive_analysis_output/2T-Xx_pdf_files.csv 2>/dev/null || echo 0)"
echo "  PSD files: $(wc -l < /Users/steven/drive_analysis_output/2T-Xx_psd_files.csv 2>/dev/null || echo 0)"

echo ""
echo "DeVonDaTa Drive:"
echo "  ZIP files: $(wc -l < /Users/steven/drive_analysis_output/DeVonDaTa_zip_files.csv 2>/dev/null || echo 0)"
echo "  MP4 files: $(wc -l < /Users/steven/drive_analysis_output/DeVonDaTa_mp4_files.csv 2>/dev/null || echo 0)"
echo "  JPG files: $(wc -l < /Users/steven/drive_analysis_output/DeVonDaTa_jpg_files.csv 2>/dev/null || echo 0)"
echo "  PNG files: $(wc -l < /Users/steven/drive_analysis_output/DeVonDaTa_png_files.csv 2>/dev/null || echo 0)"
echo "  MP3 files: $(wc -l < /Users/steven/drive_analysis_output/DeVonDaTa_mp3_files.csv 2>/dev/null || echo 0)"
echo "  PDF files: $(wc -l < /Users/steven/drive_analysis_output/DeVonDaTa_pdf_files.csv 2>/dev/null || echo 0)"
echo "  PSD files: $(wc -l < /Users/steven/drive_analysis_output/DeVonDaTa_psd_files.csv 2>/dev/null || echo 0)"
