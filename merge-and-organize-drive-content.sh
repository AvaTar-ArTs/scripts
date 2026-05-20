#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail


# Comprehensive Drive Merge and Organization Script
# Merges DeVonDaTa into 2T-Xx with proper organization

echo "=== DRIVE MERGE AND ORGANIZATION SCRIPT ==="
echo "Starting merge at: $(date)"

# Create comprehensive organized structure
echo "Creating organized directory structure..."

# Main organized directory
mkdir -p "/Volumes/2T-Xx/Organized"

# Music organization
mkdir -p "/Volumes/2T-Xx/Organized/Music/Audio_Files"
mkdir -p "/Volumes/2T-Xx/Organized/Music/Music_Archives"
mkdir -p "/Volumes/2T-Xx/Organized/Music/Covers"
mkdir -p "/Volumes/2T-Xx/Organized/Music/Projects"

# Video organization
mkdir -p "/Volumes/2T-Xx/Organized/Videos/AI_Generated"
mkdir -p "/Volumes/2T-Xx/Organized/Videos/Projects"
mkdir -p "/Volumes/2T-Xx/Organized/Videos/Archives"
mkdir -p "/Volumes/2T-Xx/Organized/Videos/MP4_Files"

# Image organization
mkdir -p "/Volumes/2T-Xx/Organized/Images/Photos"
mkdir -p "/Volumes/2T-Xx/Organized/Images/Graphics"
mkdir -p "/Volumes/2T-Xx/Organized/Images/AI_Art"
mkdir -p "/Volumes/2T-Xx/Organized/Images/Covers"
mkdir -p "/Volumes/2T-Xx/Organized/Images/Projects"

# Archive organization
mkdir -p "/Volumes/2T-Xx/Organized/Archives/ZIP_Files"
mkdir -p "/Volumes/2T-Xx/Organized/Archives/Project_Backups"
mkdir -p "/Volumes/2T-Xx/Organized/Archives/Compressed"
mkdir -p "/Volumes/2T-Xx/Organized/Archives/Canva_Exports"
mkdir -p "/Volumes/2T-Xx/Organized/Archives/Etsy_Assets"

# Document organization
mkdir -p "/Volumes/2T-Xx/Organized/Documents/PDFs"
mkdir -p "/Volumes/2T-Xx/Organized/Documents/Projects"
mkdir -p "/Volumes/2T-Xx/Organized/Documents/References"
mkdir -p "/Volumes/2T-Xx/Organized/Documents/Text_Files"

# Design files organization
mkdir -p "/Volumes/2T-Xx/Organized/Design_Files/Photoshop"
mkdir -p "/Volumes/2T-Xx/Organized/Design_Files/Canva_Exports"
mkdir -p "/Volumes/2T-Xx/Organized/Design_Files/Templates"
mkdir -p "/Volumes/2T-Xx/Organized/Design_Files/PSD_Files"

# Website and project organization
mkdir -p "/Volumes/2T-Xx/Organized/Projects/Websites"
mkdir -p "/Volumes/2T-Xx/Organized/Projects/AI_Projects"
mkdir -p "/Volumes/2T-Xx/Organized/Projects/Completed"
mkdir -p "/Volumes/2T-Xx/Organized/Projects/Active"

echo "Directory structure created successfully"

# Function to safely move files with duplicate handling
move_files_safely() {
    local source_pattern="$1"
    local dest_dir="$2"
    local file_type="$3"
    
    echo "Processing $file_type files..."
    
    # Find files matching pattern
    find "/Volumes/2T-Xx" -name "$source_pattern" -type f 2>/dev/null | while read -r file; do
        if [ -f "$file" ]; then
            filename=$(basename "$file")
            dest_path="$dest_dir/$filename"
            
            # Check if destination file exists
            if [ -f "$dest_path" ]; then
                # Compare file sizes
                source_size=$(stat -f%z "$file" 2>/dev/null)
                dest_size=$(stat -f%z "$dest_path" 2>/dev/null)
                
                if [ "$source_size" -gt "$dest_size" ]; then
                    echo "  Replacing smaller file: $filename"
                    mv "$file" "$dest_path"
                else
                    echo "  Keeping existing file: $filename"
                    rm "$file"
                fi
            else
                echo "  Moving: $filename"
                mv "$file" "$dest_path"
            fi
        fi
    done
}

# Function to move files from DeVonDaTa when available
move_from_devon() {
    local source_pattern="$1"
    local dest_dir="$2"
    local file_type="$3"
    
    if [ -d "/Volumes/DeVonDaTa" ]; then
        echo "Processing $file_type files from DeVonDaTa..."
        
        find "/Volumes/DeVonDaTa" -name "$source_pattern" -type f 2>/dev/null | while read -r file; do
            if [ -f "$file" ]; then
                filename=$(basename "$file")
                dest_path="$dest_dir/$filename"
                
                # Check if destination file exists
                if [ -f "$dest_path" ]; then
                    # Compare file sizes
                    source_size=$(stat -f%z "$file" 2>/dev/null)
                    dest_size=$(stat -f%z "$dest_path" 2>/dev/null)
                    
                    if [ "$source_size" -gt "$dest_size" ]; then
                        echo "  Replacing smaller file: $filename"
                        cp "$file" "$dest_path"
                    else
                        echo "  Keeping existing file: $filename"
                    fi
                else
                    echo "  Copying: $filename"
                    cp "$file" "$dest_path"
                fi
            fi
        done
    else
        echo "DeVonDaTa not accessible, skipping $file_type files"
    fi
}

# Start organizing files
echo ""
echo "=== ORGANIZING EXISTING FILES ON 2T-Xx ==="

# Organize ZIP files
move_files_safely "*.zip" "/Volumes/2T-Xx/Organized/Archives/ZIP_Files" "ZIP"

# Organize MP4 files
move_files_safely "*.mp4" "/Volumes/2T-Xx/Organized/Videos/MP4_Files" "MP4"

# Organize image files
move_files_safely "*.jpg" "/Volumes/2T-Xx/Organized/Images/Photos" "JPG"
move_files_safely "*.jpeg" "/Volumes/2T-Xx/Organized/Images/Photos" "JPEG"
move_files_safely "*.png" "/Volumes/2T-Xx/Organized/Images/Graphics" "PNG"
move_files_safely "*.gif" "/Volumes/2T-Xx/Organized/Images/Graphics" "GIF"

# Organize audio files
move_files_safely "*.mp3" "/Volumes/2T-Xx/Organized/Music/Audio_Files" "MP3"
move_files_safely "*.wav" "/Volumes/2T-Xx/Organized/Music/Audio_Files" "WAV"
move_files_safely "*.flac" "/Volumes/2T-Xx/Organized/Music/Audio_Files" "FLAC"

# Organize document files
move_files_safely "*.pdf" "/Volumes/2T-Xx/Organized/Documents/PDFs" "PDF"
move_files_safely "*.txt" "/Volumes/2T-Xx/Organized/Documents/Text_Files" "TXT"

# Organize design files
move_files_safely "*.psd" "/Volumes/2T-Xx/Organized/Design_Files/PSD_Files" "PSD"

echo ""
echo "=== MERGING FILES FROM DEVON DATA (if accessible) ==="

# Merge from DeVonDaTa
move_from_devon "*.zip" "/Volumes/2T-Xx/Organized/Archives/ZIP_Files" "ZIP"
move_from_devon "*.mp4" "/Volumes/2T-Xx/Organized/Videos/MP4_Files" "MP4"
move_from_devon "*.jpg" "/Volumes/2T-Xx/Organized/Images/Photos" "JPG"
move_from_devon "*.jpeg" "/Volumes/2T-Xx/Organized/Images/Photos" "JPEG"
move_from_devon "*.png" "/Volumes/2T-Xx/Organized/Images/Graphics" "PNG"
move_from_devon "*.gif" "/Volumes/2T-Xx/Organized/Images/Graphics" "GIF"
move_from_devon "*.mp3" "/Volumes/2T-Xx/Organized/Music/Audio_Files" "MP3"
move_from_devon "*.wav" "/Volumes/2T-Xx/Organized/Music/Audio_Files" "WAV"
move_from_devon "*.flac" "/Volumes/2T-Xx/Organized/Music/Audio_Files" "FLAC"
move_from_devon "*.pdf" "/Volumes/2T-Xx/Organized/Documents/PDFs" "PDF"
move_from_devon "*.txt" "/Volumes/2T-Xx/Organized/Documents/Text_Files" "TXT"
move_from_devon "*.psd" "/Volumes/2T-Xx/Organized/Design_Files/PSD_Files" "PSD"

# Move specific project directories
echo ""
echo "=== ORGANIZING PROJECT DIRECTORIES ==="

# Move steven directory contents
if [ -d "/Volumes/2T-Xx/steven" ]; then
    echo "Organizing steven directory..."
    mv "/Volumes/2T-Xx/steven/Music"/* "/Volumes/2T-Xx/Organized/Music/" 2>/dev/null || true
    mv "/Volumes/2T-Xx/steven/Pictures"/* "/Volumes/2T-Xx/Organized/Images/" 2>/dev/null || true
    mv "/Volumes/2T-Xx/steven/Documents"/* "/Volumes/2T-Xx/Organized/Documents/" 2>/dev/null || true
fi

# Move AvaTarArTs
if [ -d "/Volumes/2T-Xx/AvaTarArTs" ]; then
    echo "Organizing AvaTarArTs..."
    mv "/Volumes/2T-Xx/AvaTarArTs" "/Volumes/2T-Xx/Organized/Projects/AI_Projects/"
fi

# Move Ai-Art-Mp4
if [ -d "/Volumes/2T-Xx/Ai-Art-Mp4" ]; then
    echo "Organizing Ai-Art-Mp4..."
    mv "/Volumes/2T-Xx/Ai-Art-Mp4" "/Volumes/2T-Xx/Organized/Videos/AI_Generated/"
fi

# Move etsy directory
if [ -d "/Volumes/2T-Xx/etsy" ]; then
    echo "Organizing etsy directory..."
    mv "/Volumes/2T-Xx/etsy" "/Volumes/2T-Xx/Organized/Projects/Websites/"
fi

# Move zip directory
if [ -d "/Volumes/2T-Xx/zip" ]; then
    echo "Organizing zip directory..."
    mv "/Volumes/2T-Xx/zip"/* "/Volumes/2T-Xx/Organized/Archives/ZIP_Files/" 2>/dev/null || true
fi

# Move pics directory
if [ -d "/Volumes/2T-Xx/pics" ]; then
    echo "Organizing pics directory..."
    mv "/Volumes/2T-Xx/pics"/* "/Volumes/2T-Xx/Organized/Images/Photos/" 2>/dev/null || true
fi

# Move mp3 directory
if [ -d "/Volumes/2T-Xx/mp3" ]; then
    echo "Organizing mp3 directory..."
    mv "/Volumes/2T-Xx/mp3"/* "/Volumes/2T-Xx/Organized/Music/Audio_Files/" 2>/dev/null || true
fi

# Create summary report
echo ""
echo "=== CREATING SUMMARY REPORT ==="

# Count files in organized structure
echo "File counts in organized structure:" > "/Volumes/2T-Xx/Organized/merge_summary.txt"
echo "=================================" >> "/Volumes/2T-Xx/Organized/merge_summary.txt"
echo "" >> "/Volumes/2T-Xx/Organized/merge_summary.txt"

echo "Music files:" >> "/Volumes/2T-Xx/Organized/merge_summary.txt"
find "/Volumes/2T-Xx/Organized/Music" -type f | wc -l >> "/Volumes/2T-Xx/Organized/merge_summary.txt"

echo "Video files:" >> "/Volumes/2T-Xx/Organized/merge_summary.txt"
find "/Volumes/2T-Xx/Organized/Videos" -type f | wc -l >> "/Volumes/2T-Xx/Organized/merge_summary.txt"

echo "Image files:" >> "/Volumes/2T-Xx/Organized/merge_summary.txt"
find "/Volumes/2T-Xx/Organized/Images" -type f | wc -l >> "/Volumes/2T-Xx/Organized/merge_summary.txt"

echo "Archive files:" >> "/Volumes/2T-Xx/Organized/merge_summary.txt"
find "/Volumes/2T-Xx/Organized/Archives" -type f | wc -l >> "/Volumes/2T-Xx/Organized/merge_summary.txt"

echo "Document files:" >> "/Volumes/2T-Xx/Organized/merge_summary.txt"
find "/Volumes/2T-Xx/Organized/Documents" -type f | wc -l >> "/Volumes/2T-Xx/Organized/merge_summary.txt"

echo "Design files:" >> "/Volumes/2T-Xx/Organized/merge_summary.txt"
find "/Volumes/2T-Xx/Organized/Design_Files" -type f | wc -l >> "/Volumes/2T-Xx/Organized/merge_summary.txt"

echo "Project files:" >> "/Volumes/2T-Xx/Organized/merge_summary.txt"
find "/Volumes/2T-Xx/Organized/Projects" -type f | wc -l >> "/Volumes/2T-Xx/Organized/merge_summary.txt"

echo ""
echo "=== MERGE COMPLETE ==="
echo "Organized structure created at: /Volumes/2T-Xx/Organized/"
echo "Summary report: /Volumes/2T-Xx/Organized/merge_summary.txt"
echo "Completed at: $(date)"
