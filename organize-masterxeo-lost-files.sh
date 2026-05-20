#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail


# Resolve Lost Files in MasterxEo
# This script organizes the scattered files identified in too-many-lost.txt
# into a logical, functional directory structure

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

print_status $BOLD $PURPLE "🔍 ANALYZING LOST FILES IN MASTERXEO"
print_status $CYAN "====================================="

# Create a temporary file to process the lost files
TEMP_LOST_FILE="/tmp/processed_lost_files.txt"
cp /Users/steven/MasterxEo/too-many-lost.txt "$TEMP_LOST_FILE"

# Normalize the file paths (remove quotes and extra spaces)
sed -i '' "s/'//g" "$TEMP_LOST_FILE"
sed -i '' 's/^ *//;s/ *$//' "$TEMP_LOST_FILE"

# Count total lost files
TOTAL_LOST=$(wc -l < "$TEMP_LOST_FILE")
print_status $GREEN "📋 Total lost files identified: $TOTAL_LOST"

# Create organized directory structure in a temporary location first
ORG_ROOT="/tmp/masterxeo_organized"
mkdir -p "$ORG_ROOT"

# Create functional directories based on content type
mkdir -p "$ORG_ROOT"/{AUTOMATION,REVENUE,BUSINESS_INTELLIGENCE,AI_ML,DATA_PROCESSING,API_INTEGRATION,DEVELOPMENT_TOOLS,DOCUMENTATION,MEDIA_PROCESSING,PORTFOLIO_MANAGEMENT,CONTENT_CREATION,SEO_MARKETING,ARCHIVES,UTILITIES,CONFIGURATIONS,MISCELLANEOUS}

print_status $CYAN "📁 Creating organized directory structure..."

# Function to categorize and move files based on extension/type
categorize_file() {
    local file_path=$1
    local filename=$(basename "$file_path")
    local dirname=$(dirname "$file_path")
    local ext="${filename##*.}"
    
    # Skip if it's a directory
    if [ -d "$file_path" ]; then
        return
    fi
    
    # Determine category based on file extension or content
    case "$ext" in
        py|sh|js|ts|json|yaml|yml)
            mv "$file_path" "$ORG_ROOT/DEVELOPMENT_TOOLS/" 2>/dev/null || true
            ;;
        md|txt|html|csv)
            mv "$file_path" "$ORG_ROOT/DOCUMENTATION/" 2>/dev/null || true
            ;;
        csv|db|json|yaml|yml)
            mv "$file_path" "$ORG_ROOT/DATA_PROCESSING/" 2>/dev/null || true
            ;;
        png|jpg|jpeg|gif|svg|bmp|webp)
            mv "$file_path" "$ORG_ROOT/MEDIA_PROCESSING/" 2>/dev/null || true
            ;;
        mp3|wav|m4a|flac)
            mv "$file_path" "$ORG_ROOT/MEDIA_PROCESSING/" 2>/dev/null || true
            ;;
        mp4|mov|avi|mkv)
            mv "$file_path" "$ORG_ROOT/MEDIA_PROCESSING/" 2>/dev/null || true
            ;;
        ai|psd|sketch|xlsx|pdf)
            mv "$file_path" "$ORG_ROOT/CONTENT_CREATION/" 2>/dev/null || true
            ;;
        *)
            # For files without clear extension, determine by path
            if [[ "$file_path" == *"codester"* ]] || [[ "$file_path" == *"Codester"* ]]; then
                mv "$file_path" "$ORG_ROOT/REVENUE/" 2>/dev/null || true
            elif [[ "$file_path" == *"gumroad"* ]] || [[ "$file_path" == *"Gumroad"* ]]; then
                mv "$file_path" "$ORG_ROOT/REVENUE/" 2>/dev/null || true
            elif [[ "$file_path" == *"revenue"* ]] || [[ "$file_path" == *"Revenue"* ]]; then
                mv "$file_path" "$ORG_ROOT/REVENUE/" 2>/dev/null || true
            elif [[ "$file_path" == *"automation"* ]] || [[ "$file_path" == *"Automation"* ]]; then
                mv "$file_path" "$ORG_ROOT/AUTOMATION/" 2>/dev/null || true
            elif [[ "$file_path" == *"ai_"* ]] || [[ "$file_path" == *"AI_"* ]] || [[ "$file_path" == *"ai-"* ]] || [[ "$file_path" == *"AI-"* ]]; then
                mv "$file_path" "$ORG_ROOT/AI_ML/" 2>/dev/null || true
            elif [[ "$file_path" == *"seo"* ]] || [[ "$file_path" == *"SEO"* ]]; then
                mv "$file_path" "$ORG_ROOT/SEO_MARKETING/" 2>/dev/null || true
            else
                mv "$file_path" "$ORG_ROOT/MISCELLANEOUS/" 2>/dev/null || true
            fi
            ;;
    esac
}

# Read the lost files and process them
while IFS= read -r file_path; do
    # Skip empty lines
    if [ -z "$file_path" ]; then
        continue
    fi
    
    # Only process if the file actually exists
    if [ -e "$file_path" ]; then
        categorize_file "$file_path"
    fi
done < "$TEMP_LOST_FILE"

# Count how many files were moved to each category
AUTOMATION_COUNT=$(find "$ORG_ROOT/AUTOMATION" -type f 2>/dev/null | wc -l)
REVENUE_COUNT=$(find "$ORG_ROOT/REVENUE" -type f 2>/dev/null | wc -l)
DOC_COUNT=$(find "$ORG_ROOT/DOCUMENTATION" -type f 2>/dev/null | wc -l)
DATA_COUNT=$(find "$ORG_ROOT/DATA_PROCESSING" -type f 2>/dev/null | wc -l)
DEV_COUNT=$(find "$ORG_ROOT/DEVELOPMENT_TOOLS" -type f 2>/dev/null | wc -l)
MEDIA_COUNT=$(find "$ORG_ROOT/MEDIA_PROCESSING" -type f 2>/dev/null | wc -l)
CONTENT_COUNT=$(find "$ORG_ROOT/CONTENT_CREATION" -type f 2>/dev/null | wc -l)
SEO_COUNT=$(find "$ORG_ROOT/SEO_MARKETING" -type f 2>/dev/null | wc -l)
MISC_COUNT=$(find "$ORG_ROOT/MISCELLANEOUS" -type f 2>/dev/null | wc -l)

print_status $GREEN "✅ Organization completed! Files sorted into functional categories:"
echo "   • Automation: $AUTOMATION_COUNT files"
echo "   • Revenue: $REVENUE_COUNT files"
echo "   • Documentation: $DOC_COUNT files"
echo "   • Data Processing: $DATA_COUNT files"
echo "   • Development Tools: $DEV_COUNT files"
echo "   • Media Processing: $MEDIA_COUNT files"
echo "   • Content Creation: $CONTENT_COUNT files"
echo "   • SEO Marketing: $SEO_COUNT files"
echo "   • Miscellaneous: $MISC_COUNT files"

print_status $YELLOW "💡 Next steps:"
echo "   1. Review the organized files in $ORG_ROOT"
echo "   2. Once verified, move them to the permanent location"
echo "   3. Update any hardcoded paths in your scripts"

print_status $BOLD $PURPLE "🎯 LOST FILE RESOLUTION COMPLETE"
