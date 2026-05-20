#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail


# Create comprehensive CSV file for disk cleanup analysis

echo "File_Path,File_Size,Last_Modified,File_Type,Category,Priority,Reason_for_Removal,Estimated_Savings" > /Users/steven/disk_cleanup_analysis.csv

echo "Creating CSV entries for large log files..."
find ~/ -name "*.log" -size +1M -exec ls -lh {} \; | while read -r line; do
    path=$(echo "$line" | awk '{print $9}')
    size=$(echo "$line" | awk '{print $5}')
    date=$(echo "$line" | awk '{print $6 " " $7 " " $8}')
    echo "$path,$size,$date,LOG,High Priority,CRITICAL,Large log file consuming significant space,$size" >> /Users/steven/disk_cleanup_analysis.csv
done

echo "Creating CSV entries for duplicate zip files..."
find ~/ -name "backup.zip" -not -path '*/node_modules/*' -exec ls -lh {} \; | while read -r line; do
    path=$(echo "$line" | awk '{print $9}')
    size=$(echo "$line" | awk '{print $5}')
    date=$(echo "$line" | awk '{print $6 " " $7 " " $8}')
    echo "$path,$size,$date,ZIP,Medium Priority,HIGH,Duplicate backup file,$size" >> /Users/steven/disk_cleanup_analysis.csv
done

find ~/ -name "Archive.zip" -not -path '*/node_modules/*' -exec ls -lh {} \; | while read -r line; do
    path=$(echo "$line" | awk '{print $9}')
    size=$(echo "$line" | awk '{print $5}')
    date=$(echo "$line" | awk '{print $6 " " $7 " " $8}')
    echo "$path,$size,$date,ZIP,Medium Priority,HIGH,Duplicate archive file,$size" >> /Users/steven/disk_cleanup_analysis.csv
done

echo "Creating CSV entries for Python cache directories..."
find ~/ -name "__pycache__" -type d -exec du -sh {} \; | sort -hr | head -20 | while read -r line; do
    size=$(echo "$line" | awk '{print $1}')
    path=$(echo "$line" | awk '{print $2}')
    echo "$path,$size,N/A,PYCACHE,High Priority,HIGH,Python cache directory,$size" >> /Users/steven/disk_cleanup_analysis.csv
done

echo "Creating CSV entries for node_modules directories..."
find ~/ -name "node_modules" -type d -exec du -sh {} \; | sort -hr | while read -r line; do
    size=$(echo "$line" | awk '{print $1}')
    path=$(echo "$line" | awk '{print $2}')
    echo "$path,$size,N/A,NODE_MODULES,Medium Priority,MEDIUM,Node.js dependencies directory,$size" >> /Users/steven/disk_cleanup_analysis.csv
done

echo "Creating CSV entries for temporary files..."
find ~/ -name "*.tmp" -o -name "*.temp" -o -name "*~" -exec ls -lh {} \; | while read -r line; do
    path=$(echo "$line" | awk '{print $9}')
    size=$(echo "$line" | awk '{print $5}')
    date=$(echo "$line" | awk '{print $6 " " $7 " " $8}')
    echo "$path,$size,$date,TEMP,Low Priority,LOW,Temporary file,$size" >> /Users/steven/disk_cleanup_analysis.csv
done

echo "Creating CSV entries for large files (>100MB)..."
find ~/ -type f -size +100M -exec ls -lh {} \; | while read -r line; do
    path=$(echo "$line" | awk '{print $9}')
    size=$(echo "$line" | awk '{print $5}')
    date=$(echo "$line" | awk '{print $6 " " $7 " " $8}')
    
    # Determine category based on file type
    if [[ "$path" == *".log" ]]; then
        category="LOG"
        priority="CRITICAL"
        reason="Large log file"
    elif [[ "$path" == *".zip" ]]; then
        category="ZIP"
        priority="MEDIUM"
        reason="Large zip file"
    elif [[ "$path" == *".pdf" ]]; then
        category="PDF"
        priority="LOW"
        reason="Large PDF file"
    elif [[ "$path" == *".mp4" ]] || [[ "$path" == *".mov" ]]; then
        category="VIDEO"
        priority="LOW"
        reason="Large video file"
    else
        category="OTHER"
        priority="LOW"
        reason="Large file"
    fi
    
    echo "$path,$size,$date,LARGE_FILE,$category,$priority,$reason,$size" >> /Users/steven/disk_cleanup_analysis.csv
done

echo "Creating CSV entries for DMG files..."
find ~/ -name "*.dmg" -exec ls -lh {} \; | while read -r line; do
    path=$(echo "$line" | awk '{print $9}')
    size=$(echo "$line" | awk '{print $5}')
    date=$(echo "$line" | awk '{print $6 " " $7 " " $8}')
    echo "$path,$size,$date,DMG,Medium Priority,MEDIUM,Installation disk image,$size" >> /Users/steven/disk_cleanup_analysis.csv
done

echo "Creating CSV entries for backup files..."
find ~/ -name "*.backup" -o -name "*.bak" -exec ls -lh {} \; | while read -r line; do
    path=$(echo "$line" | awk '{print $9}')
    size=$(echo "$line" | awk '{print $5}')
    date=$(echo "$line" | awk '{print $6 " " $7 " " $8}')
    echo "$path,$size,$date,BACKUP,Low Priority,LOW,Backup file,$size" >> /Users/steven/disk_cleanup_analysis.csv
done

echo "CSV file created: /Users/steven/disk_cleanup_analysis.csv"
echo "Total entries: $(wc -l < /Users/steven/disk_cleanup_analysis.csv)"
