#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail


# Content-Aware Drive Analysis Script
# Analyzes actual content and structure before making changes

echo "=== CONTENT-AWARE DRIVE ANALYSIS ==="
echo "Starting analysis at: $(date)"

# Create analysis output directory
mkdir -p "/Users/steven/drive_content_analysis"

# Function to analyze directory structure
analyze_directory_structure() {
    local drive_path="$1"
    local drive_name="$2"
    local output_file="$3"
    
    echo "Analyzing directory structure for $drive_name..."
    
    # Create header
    echo "Directory_Path,Depth,File_Count,Total_Size_MB,Last_Modified" > "$output_file"
    
    # Find all directories and analyze them
    find "$drive_path" -type d -maxdepth 3 2>/dev/null | while read -r dir; do
        if [ -d "$dir" ]; then
            # Count files in directory
            file_count=$(find "$dir" -maxdepth 1 -type f 2>/dev/null | wc -l)
            
            # Calculate total size
            total_size=$(du -sm "$dir" 2>/dev/null | cut -f1)
            
            # Get last modified date
            last_modified=$(stat -f "%Sm" -t "%Y-%m-%d %H:%M:%S" "$dir" 2>/dev/null)
            
            # Calculate depth
            depth=$(echo "$dir" | tr -cd '/' | wc -c)
            
            echo "$dir,$depth,$file_count,$total_size,$last_modified" >> "$output_file"
        fi
    done
}

# Function to analyze file types in detail
analyze_file_types() {
    local drive_path="$1"
    local drive_name="$2"
    local output_file="$3"
    
    echo "Analyzing file types for $drive_name..."
    
    # Create header
    echo "File_Type,Count,Total_Size_MB,Average_Size_KB,Min_Size_KB,Max_Size_KB" > "$output_file"
    
    # Define file types to analyze
    declare -A file_types=(
        ["ZIP"]="*.zip"
        ["MP4"]="*.mp4"
        ["JPG"]="*.jpg"
        ["JPEG"]="*.jpeg"
        ["PNG"]="*.png"
        ["GIF"]="*.gif"
        ["PDF"]="*.pdf"
        ["MP3"]="*.mp3"
        ["WAV"]="*.wav"
        ["FLAC"]="*.flac"
        ["PSD"]="*.psd"
        ["TXT"]="*.txt"
        ["HTML"]="*.html"
        ["CSS"]="*.css"
        ["JS"]="*.js"
        ["JSON"]="*.json"
        ["XML"]="*.xml"
        ["DOC"]="*.doc"
        ["DOCX"]="*.docx"
        ["XLS"]="*.xls"
        ["XLSX"]="*.xlsx"
        ["PPT"]="*.ppt"
        ["PPTX"]="*.pptx"
    )
    
    for file_type in "${!file_types[@]}"; do
        pattern="${file_types[$file_type]}"
        
        echo "  Analyzing $file_type files..."
        
        # Find files and calculate stats
        find "$drive_path" -name "$pattern" -type f 2>/dev/null | while read -r file; do
            if [ -f "$file" ]; then
                size=$(stat -f%z "$file" 2>/dev/null)
                echo "$file_type,$size"
            fi
        done > "/tmp/${drive_name}_${file_type}_temp.csv"
        
        # Process the temp file
        if [ -f "/tmp/${drive_name}_${file_type}_temp.csv" ]; then
            count=$(wc -l < "/tmp/${drive_name}_${file_type}_temp.csv")
            if [ "$count" -gt 0 ]; then
                total_size=$(awk -F',' '{sum+=$2} END {print sum}' "/tmp/${drive_name}_${file_type}_temp.csv")
                avg_size=$((total_size / count / 1024))
                min_size=$(awk -F',' 'BEGIN{min=999999999} {if($2<min) min=$2} END {print min/1024}' "/tmp/${drive_name}_${file_type}_temp.csv")
                max_size=$(awk -F',' 'BEGIN{max=0} {if($2>max) max=$2} END {print max/1024}' "/tmp/${drive_name}_${file_type}_temp.csv")
                total_size_mb=$((total_size / 1024 / 1024))
                
                echo "$file_type,$count,$total_size_mb,$avg_size,$min_size,$max_size" >> "$output_file"
            fi
            rm "/tmp/${drive_name}_${file_type}_temp.csv" 2>/dev/null
        fi
    done
}

# Function to find large files
find_large_files() {
    local drive_path="$1"
    local drive_name="$2"
    local output_file="$3"
    
    echo "Finding large files for $drive_name..."
    
    # Create header
    echo "File_Path,File_Name,Size_MB,Directory,Last_Modified" > "$output_file"
    
    # Find files larger than 100MB
    find "$drive_path" -type f -size +100M 2>/dev/null | while read -r file; do
        if [ -f "$file" ]; then
            filename=$(basename "$file")
            directory=$(dirname "$file")
            size_mb=$(stat -f%z "$file" 2>/dev/null)
            size_mb=$((size_mb / 1024 / 1024))
            last_modified=$(stat -f "%Sm" -t "%Y-%m-%d %H:%M:%S" "$file" 2>/dev/null)
            
            echo "$file,$filename,$size_mb,$directory,$last_modified" >> "$output_file"
        fi
    done
}

# Function to find duplicate files
find_duplicates() {
    local drive_path="$1"
    local drive_name="$2"
    local output_file="$3"
    
    echo "Finding potential duplicates for $drive_name..."
    
    # Create header
    echo "File_Name,Size_Bytes,Count,File_Paths" > "$output_file"
    
    # Find files with same name and size
    find "$drive_path" -type f 2>/dev/null | while read -r file; do
        if [ -f "$file" ]; then
            filename=$(basename "$file")
            size=$(stat -f%z "$file" 2>/dev/null)
            echo "$filename,$size,$file"
        fi
    done | sort | uniq -c | while read -r count filename size path; do
        if [ "$count" -gt 1 ]; then
            echo "$filename,$size,$count,$path" >> "$output_file"
        fi
    done
}

# Function to analyze project directories
analyze_projects() {
    local drive_path="$1"
    local drive_name="$2"
    local output_file="$3"
    
    echo "Analyzing project directories for $drive_name..."
    
    # Create header
    echo "Project_Name,Path,File_Count,Total_Size_MB,Last_Modified,Description" > "$output_file"
    
    # Look for common project indicators
    find "$drive_path" -type d -name "*project*" -o -name "*Project*" -o -name "*PROJECT*" 2>/dev/null | while read -r dir; do
        if [ -d "$dir" ]; then
            project_name=$(basename "$dir")
            file_count=$(find "$dir" -type f 2>/dev/null | wc -l)
            total_size=$(du -sm "$dir" 2>/dev/null | cut -f1)
            last_modified=$(stat -f "%Sm" -t "%Y-%m-%d %H:%M:%S" "$dir" 2>/dev/null)
            
            # Try to determine project type
            if find "$dir" -name "*.html" -o -name "*.css" -o -name "*.js" 2>/dev/null | grep -q .; then
                description="Web Project"
            elif find "$dir" -name "*.psd" -o -name "*.ai" 2>/dev/null | grep -q .; then
                description="Design Project"
            elif find "$dir" -name "*.mp4" -o -name "*.mov" 2>/dev/null | grep -q .; then
                description="Video Project"
            elif find "$dir" -name "*.mp3" -o -name "*.wav" 2>/dev/null | grep -q .; then
                description="Audio Project"
            else
                description="General Project"
            fi
            
            echo "$project_name,$dir,$file_count,$total_size,$last_modified,$description" >> "$output_file"
        fi
    done
}

# Check if drives are accessible
echo "Checking drive accessibility..."

if [ -d "/Volumes/2T-Xx" ]; then
    echo "✓ 2T-Xx drive is accessible"
    analyze_2t=true
else
    echo "✗ 2T-Xx drive is not accessible"
    analyze_2t=false
fi

if [ -d "/Volumes/DeVonDaTa" ]; then
    echo "✓ DeVonDaTa drive is accessible"
    analyze_devon=true
else
    echo "✗ DeVonDaTa drive is not accessible"
    analyze_devon=false
fi

# Analyze 2T-Xx if accessible
if [ "$analyze_2t" = true ]; then
    echo ""
    echo "=== ANALYZING 2T-Xx DRIVE ==="
    
    # Get basic info
    echo "Drive size: $(df -h /Volumes/2T-Xx | tail -1 | awk '{print $2}')"
    echo "Used space: $(df -h /Volumes/2T-Xx | tail -1 | awk '{print $3}')"
    echo "Available space: $(df -h /Volumes/2T-Xx | tail -1 | awk '{print $4}')"
    
    # Run analyses
    analyze_directory_structure "/Volumes/2T-Xx" "2T-Xx" "/Users/steven/drive_content_analysis/2T-Xx_directory_structure.csv"
    analyze_file_types "/Volumes/2T-Xx" "2T-Xx" "/Users/steven/drive_content_analysis/2T-Xx_file_types.csv"
    find_large_files "/Volumes/2T-Xx" "2T-Xx" "/Users/steven/drive_content_analysis/2T-Xx_large_files.csv"
    find_duplicates "/Volumes/2T-Xx" "2T-Xx" "/Users/steven/drive_content_analysis/2T-Xx_duplicates.csv"
    analyze_projects "/Volumes/2T-Xx" "2T-Xx" "/Users/steven/drive_content_analysis/2T-Xx_projects.csv"
fi

# Analyze DeVonDaTa if accessible
if [ "$analyze_devon" = true ]; then
    echo ""
    echo "=== ANALYZING DEVON DATA DRIVE ==="
    
    # Get basic info
    echo "Drive size: $(df -h /Volumes/DeVonDaTa | tail -1 | awk '{print $2}')"
    echo "Used space: $(df -h /Volumes/DeVonDaTa | tail -1 | awk '{print $3}')"
    echo "Available space: $(df -h /Volumes/DeVonDaTa | tail -1 | awk '{print $4}')"
    
    # Run analyses
    analyze_directory_structure "/Volumes/DeVonDaTa" "DeVonDaTa" "/Users/steven/drive_content_analysis/DeVonDaTa_directory_structure.csv"
    analyze_file_types "/Volumes/DeVonDaTa" "DeVonDaTa" "/Users/steven/drive_content_analysis/DeVonDaTa_file_types.csv"
    find_large_files "/Volumes/DeVonDaTa" "DeVonDaTa" "/Users/steven/drive_content_analysis/DeVonDaTa_large_files.csv"
    find_duplicates "/Volumes/DeVonDaTa" "DeVonDaTa" "/Users/steven/drive_content_analysis/DeVonDaTa_duplicates.csv"
    analyze_projects "/Volumes/DeVonDaTa" "DeVonDaTa" "/Users/steven/drive_content_analysis/DeVonDaTa_projects.csv"
fi

# Create summary report
echo ""
echo "=== CREATING SUMMARY REPORT ==="

cat > "/Users/steven/drive_content_analysis/ANALYSIS_SUMMARY.md" << EOF
# Drive Content Analysis Summary

**Analysis Date:** $(date)
**Analyst:** Content-Aware Analysis Script

## Drive Status
- **2T-Xx:** $([ "$analyze_2t" = true ] && echo "✓ Accessible" || echo "✗ Not Accessible")
- **DeVonDaTa:** $([ "$analyze_devon" = true ] && echo "✓ Accessible" || echo "✗ Not Accessible")

## Analysis Files Created
- Directory structure analysis
- File type distribution
- Large files identification
- Duplicate files detection
- Project directory analysis

## Next Steps
1. Review the CSV files in this directory
2. Understand the content structure
3. Plan merge strategy based on actual content
4. Execute merge with content awareness

## Files Generated
$(ls -la /Users/steven/drive_content_analysis/*.csv 2>/dev/null | wc -l) CSV analysis files
$(ls -la /Users/steven/drive_content_analysis/*.md 2>/dev/null | wc -l) Summary files
EOF

echo ""
echo "=== ANALYSIS COMPLETE ==="
echo "Results saved to: /Users/steven/drive_content_analysis/"
echo "Summary report: /Users/steven/drive_content_analysis/ANALYSIS_SUMMARY.md"
echo "Completed at: $(date)"
