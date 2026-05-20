#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail


# Clean Directory Analysis and Integration Script
# Analyzes the ~/clean directory system and integrates it with MasterxEo

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

print_status $BOLD $PURPLE "🔍 ANALYZING CLEAN DIRECTORY SYSTEM"
print_status $CYAN "=================================="

CLEAN_DIR="/Users/steven/clean"
MASTERXEO_ROOT="/Users/steven/MasterxEo"

# Analyze the clean directory structure
print_status $CYAN "📁 Analyzing clean directory structure..."

AUDIO_COUNT=$(find "$CLEAN_DIR/audio" -type f 2>/dev/null | wc -l)
DOCS_COUNT=$(find "$CLEAN_DIR/docs" -type f 2>/dev/null | wc -l)
IMG_COUNT=$(find "$CLEAN_DIR/img" -type f 2>/dev/null | wc -l)
VIDS_COUNT=$(find "$CLEAN_DIR/vids" -type f 2>/dev/null | wc -l)
OTHER_COUNT=$(find "$CLEAN_DIR/other" -type f 2>/dev/null | wc -l)

print_status $GREEN "📊 File counts in clean categories:"
echo "   • Audio files: $AUDIO_COUNT"
echo "   • Document files: $DOCS_COUNT"
echo "   • Image files: $IMG_COUNT"
echo "   • Video files: $VIDS_COUNT"
echo "   • Other files: $OTHER_COUNT"

# Check for recent CSV outputs
print_status $CYAN "\n📅 Checking recent CSV outputs..."
RECENT_CSVS=$(find "$CLEAN_DIR" -name "*.csv" -type f -newer "$CLEAN_DIR/docs-02-08-19:40.csv" 2>/dev/null | wc -l)
echo "   • Recent CSV outputs: $RECENT_CSVS"

# Show recent CSV files
find "$CLEAN_DIR" -name "*.csv" -type f -newer "$CLEAN_DIR/docs-02-08-19:40.csv" 2>/dev/null | head -5 | while read csv_file; do
    echo "   • $(basename "$csv_file") ($(stat -f%z "$csv_file" 2>/dev/null | awk '{printf "%.2f KB", $1/1024}'))"
done

# Analyze the scripts
print_status $GREEN "\n📝 Script analysis:"
echo "   • audio.py - Scans for audio files (.mp3, .wav, .flac, .aac, .m4a)"
echo "   • docs.py - Scans for document files (.pdf, .doc, .txt, .py, .html, etc.)"
echo "   • img.py - Scans for image files (.jpg, .png, .gif, .tiff, etc.)"
echo "   • vids.py - Scans for video files (.mp4, .mkv, .mov, .avi, etc.)"
echo "   • other.py - Scans for other file types (fonts, scripts, archives, etc.)"
echo "   • all.py - Comprehensive scanner combining all categories"
echo "   • cleanup_and_organize.py - Cleans up duplicate and backup files"
echo "   • batch-info.py - Processes files in batches with AI categorization"

# Check for integration with AutoTagger
if [ -d "/Users/steven/AutoTagger/current" ]; then
    print_status $GREEN "\n🤖 AutoTagger integration detected"
    echo "   • AutoTagger available for advanced categorization"
else
    print_status $YELLOW "\n⚠️  AutoTagger integration not detected"
    echo "   • AutoTagger not available in /Users/steven/AutoTagger/current"
fi

# Check for API key configuration
if [ -d "/Users/steven/.env.d" ]; then
    API_KEYS=$(find "/Users/steven/.env.d" -name "*.env" -exec grep -l "API_KEY" {} \; 2>/dev/null | wc -l)
    print_status $GREEN "\n🔑 API configuration:"
    echo "   • $API_KEYS API key files found in ~/.env.d/"
else
    print_status $YELLOW "\n⚠️  No API configuration found in ~/.env.d/"
fi

# Create integration with MasterxEo
print_status $CYAN "\n🔗 Creating integration with MasterxEo..."

# Create a link to the clean directory in MasterxEo
mkdir -p "$MASTERXEO_ROOT/INTEGRATION_TOOLS/CLEAN_SYSTEM"
ln -sf "$CLEAN_DIR" "$MASTERXEO_ROOT/INTEGRATION_TOOLS/CLEAN_SYSTEM/clean_link" 2>/dev/null || true

# Create a specialized runner for clean operations
CLEAN_RUNNER="$MASTERXEO_ROOT/INTEGRATION_TOOLS/CLEAN_SYSTEM/run_clean_operations.sh"
cat > "$CLEAN_RUNNER" << 'EOF'
#!/bin/bash

# Clean Operations Runner
# Specialized runner for clean directory operations integrated with MasterxEo

echo "🚀 Running Clean Directory Operations"
echo "====================================="

# Navigate to clean directory
cd /Users/steven/clean

# Function to run a clean operation
run_operation() {
    local operation=$1
    local description=$2
    echo ""
    echo "▶️  $description"
    case $operation in
        "audio")
            python3 audio.py
            ;;
        "docs")
            python3 docs.py
            ;;
        "img")
            python3 img.py
            ;;
        "vids")
            python3 vids.py
            ;;
        "other")
            python3 other.py
            ;;
        "all")
            python3 all.py
            ;;
        "cleanup")
            python3 cleanup_and_organize.py
            ;;
        *)
            echo "Unknown operation: $operation"
            return 1
            ;;
    esac
    if [ $? -eq 0 ]; then
        echo "✅ $description completed successfully"
    else
        echo "❌ $description failed"
    fi
}

# Show menu
echo "Select an operation:"
echo "1) Scan audio files"
echo "2) Scan document files"
echo "3) Scan image files"
echo "4) Scan video files"
echo "5) Scan other files"
echo "6) Scan all file types"
echo "7) Run cleanup and organization"
echo "8) Run all scans sequentially"
echo "9) Exit"
echo ""

read -p "Enter your choice (1-9): " choice

case $choice in
    1)
        run_operation "audio" "Audio file scan"
        ;;
    2)
        run_operation "docs" "Document file scan"
        ;;
    3)
        run_operation "img" "Image file scan"
        ;;
    4)
        run_operation "vids" "Video file scan"
        ;;
    5)
        run_operation "other" "Other file scan"
        ;;
    6)
        run_operation "all" "All file types scan"
        ;;
    7)
        run_operation "cleanup" "Cleanup and organization"
        ;;
    8)
        echo "Running all scans sequentially..."
        run_operation "audio" "Audio file scan"
        run_operation "docs" "Document file scan"
        run_operation "img" "Image file scan"
        run_operation "vids" "Video file scan"
        run_operation "other" "Other file scan"
        echo "✅ All scans completed"
        ;;
    9)
        echo "Exiting..."
        exit 0
        ;;
    *)
        echo "Invalid choice. Exiting..."
        ;;
esac
EOF

chmod +x "$CLEAN_RUNNER"
print_status $GREEN "✅ Created clean operations runner: $CLEAN_RUNNER"

# Create a report on clean directory capabilities
REPORT_FILE="$MASTERXEO_ROOT/INTEGRATION_TOOLS/CLEAN_SYSTEM/CLEAN_SYSTEM_REPORT.md"
cat > "$REPORT_FILE" << EOF
# Clean Directory System Report

## Overview
The clean directory system provides comprehensive file scanning, organization, and cleanup capabilities for the MasterxEo ecosystem.

## Capabilities

### File Scanning
- **Audio files**: MP3, WAV, FLAC, AAC, M4A with duration and metadata
- **Document files**: PDF, DOC, TXT, PY, HTML, JSON with size and creation date
- **Image files**: JPG, PNG, GIF, TIFF with dimensions, DPI, and metadata
- **Video files**: MP4, MKV, MOV, AVI with duration and metadata
- **Other files**: Fonts, scripts, archives, and miscellaneous files

### Advanced Features
- **Batch processing**: Processes files in configurable batch sizes
- **AI categorization**: Uses OpenAI API for intelligent file categorization
- **AutoTagger integration**: Connects with AutoTagger for advanced tagging
- **Duplicate detection**: Identifies and removes duplicate files
- **CSV reporting**: Generates detailed reports in CSV format
- **Configurable scanning**: Excludes system directories and virtual environments

### Integration Points
- **API key management**: Loads from ~/.env.d/ directory
- **AutoTagger system**: Advanced categorization and business value prediction
- **MasterxEo integration**: Direct linking and operation runners

## Usage
Run clean operations through the integrated runner:
\`\`\`bash
bash $CLEAN_RUNNER
\`\`\`

Or run individual scanners:
\`\`\`bash
cd /Users/steven/clean
python3 audio.py      # Scan audio files
python3 docs.py       # Scan documents
python3 img.py        # Scan images
python3 vids.py       # Scan videos
python3 all.py        # Scan all types
python3 cleanup_and_organize.py  # Cleanup operations
\`\`\`

## Output
All operations generate timestamped CSV files with detailed file metadata:
- File names, sizes, creation dates
- Dimensions for images, duration for audio/video
- Original paths for reference
- Categorization information

## Benefits for MasterxEo
- Enhanced file discovery and organization
- Automated categorization with business value assessment
- Duplicate file elimination
- Comprehensive inventory reporting
- Integration with AutoTagger for intelligent tagging
EOF

print_status $GREEN "✅ Created clean system report: $REPORT_FILE"

print_status $YELLOW "\n💡 Integration benefits:"
echo "   • File scanning capabilities integrated with MasterxEo"
echo "   • Advanced categorization with AutoTagger integration"
echo "   • AI-powered file analysis and tagging"
echo "   • Comprehensive reporting through CSV outputs"
echo "   • Specialized runner for clean operations"
echo "   • Direct linking between systems"

print_status $BOLD $PURPLE "\n🎯 CLEAN DIRECTORY INTEGRATION COMPLETE!"
print_status $CYAN "The clean directory system is now integrated with MasterxEo."
