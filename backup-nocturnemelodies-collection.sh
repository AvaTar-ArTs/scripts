#!/bin/bash
set -euo pipefail
# Wrapper script for NocturneMelodies Collection Backup

echo "NocturneMelodies Collection Backup Script"
echo "========================================="

# Set default values for the most common use case
SOURCE_DIR="/Users/steven/Music/nocTurneMeLoDieS/MUSIC_ORGANIZED"
DESTINATION_DIR="/Users/steven/Music/nocTurneMeLoDieS/MUSIC_ORGANIZED_BACKUP"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
CSV_FILE="/Users/steven/Music/nocTurneMeLoDieS/backups/nocturnemelodies_backup_${TIMESTAMP}.csv"

echo "Default settings:"
echo "  Source: $SOURCE_DIR"
echo "  Destination: $DESTINATION_DIR"
echo "  CSV Output: $CSV_FILE"
echo ""

# Ask user if they want to use defaults or customize
read -p "Use default settings? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Creating backup with default settings..."
    python3 /Users/steven/Music/nocTurneMeLoDieS/nocturnemelodies_collection_backup.py --action backup \
        --source "$SOURCE_DIR" \
        --destination "$DESTINATION_DIR" \
        --csv "$CSV_FILE"
else
    echo ""
    read -p "Enter source directory (current: $SOURCE_DIR): " input_source
    SOURCE_DIR=${input_source:-$SOURCE_DIR}
    
    read -p "Enter destination directory (current: $DESTINATION_DIR): " input_dest
    DESTINATION_DIR=${input_dest:-$DESTINATION_DIR}
    
    read -p "Enter CSV output path (current: $CSV_FILE): " input_csv
    CSV_FILE=${input_csv:-$CSV_FILE}
    
    echo "Creating backup with custom settings..."
    python3 /Users/steven/Music/nocTurneMeLoDieS/nocturnemelodies_collection_backup.py --action backup \
        --source "$SOURCE_DIR" \
        --destination "$DESTINATION_DIR" \
        --csv "$CSV_FILE"
fi

echo ""
echo "Backup process completed!"
echo "Remember to check the CSV file at: $CSV_FILE"
