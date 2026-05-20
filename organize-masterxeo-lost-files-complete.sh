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

# Use the properly formatted file
FORMATTED_FILE="/tmp/formatted_lost_files.txt"

# Count total lost files
TOTAL_LOST=$(wc -l < "$FORMATTED_FILE")
print_status $GREEN "📋 Total lost files identified: $TOTAL_LOST"

# Create organized directory structure in a temporary location first
ORG_ROOT="/tmp/masterxeo_organized"
mkdir -p "$ORG_ROOT"

# Create functional directories based on content type
mkdir -p "$ORG_ROOT"/{AUTOMATION,REVENUE,BUSINESS_INTELLIGENCE,AI_ML,DATA_PROCESSING,API_INTEGRATION,DEVELOPMENT_TOOLS,DOCUMENTATION,MEDIA_PROCESSING,PORTFOLIO_MANAGEMENT,CONTENT_CREATION,SEO_MARKETING,ARCHIVES,UTILITIES,CONFIGURATIONS,MISCELLANEOUS,CODASTER,GUMROAD,ETSY,SELLFY,PAYHIP,LEMONSQUEEZY}

print_status $CYAN "📁 Creating organized directory structure..."

# Function to categorize and move files based on extension/type
categorize_file() {
    local file_path=$1
    local filename=$(basename "$file_path")
    local dirname=$(dirname "$file_path")
    local ext="${filename##*.}"
    
    # Skip if it's a directory
    if [ -d "$file_path" ]; then
        # Move directories based on their names/contents
        if [[ "$file_path" == *"codester"* ]] || [[ "$file_path" == *"Codester"* ]]; then
            mkdir -p "$ORG_ROOT/CODASTER/$(basename "$dirname")"
            mv "$file_path" "$ORG_ROOT/CODASTER/$(basename "$dirname")/" 2>/dev/null || true
        elif [[ "$file_path" == *"gumroad"* ]] || [[ "$file_path" == *"Gumroad"* ]]; then
            mkdir -p "$ORG_ROOT/GUMROAD/$(basename "$dirname")"
            mv "$file_path" "$ORG_ROOT/GUMROAD/$(basename "$dirname")/" 2>/dev/null || true
        elif [[ "$file_path" == *"etsy"* ]] || [[ "$file_path" == *"Etsy"* ]]; then
            mkdir -p "$ORG_ROOT/ETSY/$(basename "$dirname")"
            mv "$file_path" "$ORG_ROOT/ETSY/$(basename "$dirname")/" 2>/dev/null || true
        elif [[ "$file_path" == *"sellfy"* ]] || [[ "$file_path" == *"Sellfy"* ]]; then
            mkdir -p "$ORG_ROOT/SELLFY/$(basename "$dirname")"
            mv "$file_path" "$ORG_ROOT/SELLFY/$(basename "$dirname")/" 2>/dev/null || true
        elif [[ "$file_path" == *"payhip"* ]] || [[ "$file_path" == *"Payhip"* ]]; then
            mkdir -p "$ORG_ROOT/PAYHIP/$(basename "$dirname")"
            mv "$file_path" "$ORG_ROOT/PAYHIP/$(basename "$dirname")/" 2>/dev/null || true
        elif [[ "$file_path" == *"lemonsqueezy"* ]] || [[ "$file_path" == *"LemonSqueezy"* ]]; then
            mkdir -p "$ORG_ROOT/LEMONSQUEEZY/$(basename "$dirname")"
            mv "$file_path" "$ORG_ROOT/LEMONSQUEEZY/$(basename "$dirname")/" 2>/dev/null || true
        elif [[ "$file_path" == *"revenue"* ]] || [[ "$file_path" == *"Revenue"* ]]; then
            mkdir -p "$ORG_ROOT/REVENUE/$(basename "$dirname")"
            mv "$file_path" "$ORG_ROOT/REVENUE/$(basename "$dirname")/" 2>/dev/null || true
        elif [[ "$file_path" == *"automation"* ]] || [[ "$file_path" == *"Automation"* ]]; then
            mkdir -p "$ORG_ROOT/AUTOMATION/$(basename "$dirname")"
            mv "$file_path" "$ORG_ROOT/AUTOMATION/$(basename "$dirname")/" 2>/dev/null || true
        elif [[ "$file_path" == *"ai_"* ]] || [[ "$file_path" == *"AI_"* ]] || [[ "$file_path" == *"ai-"* ]] || [[ "$file_path" == *"AI-"* ]]; then
            mkdir -p "$ORG_ROOT/AI_ML/$(basename "$dirname")"
            mv "$file_path" "$ORG_ROOT/AI_ML/$(basename "$dirname")/" 2>/dev/null || true
        elif [[ "$file_path" == *"seo"* ]] || [[ "$file_path" == *"SEO"* ]]; then
            mkdir -p "$ORG_ROOT/SEO_MARKETING/$(basename "$dirname")"
            mv "$file_path" "$ORG_ROOT/SEO_MARKETING/$(basename "$dirname")/" 2>/dev/null || true
        else
            # For directories without clear category, just move to miscellaneous
            mkdir -p "$ORG_ROOT/MISCELLANEOUS/$(basename "$dirname")"
            mv "$file_path" "$ORG_ROOT/MISCELLANEOUS/$(basename "$dirname")/" 2>/dev/null || true
        fi
        return
    fi
    
    # Determine category based on file extension or content
    case "$ext" in
        py|sh|js|ts|json|yaml|yml)
            cp "$file_path" "$ORG_ROOT/DEVELOPMENT_TOOLS/" 2>/dev/null || true
            ;;
        md|txt|html|csv)
            cp "$file_path" "$ORG_ROOT/DOCUMENTATION/" 2>/dev/null || true
            ;;
        csv|db|json|yaml|yml)
            cp "$file_path" "$ORG_ROOT/DATA_PROCESSING/" 2>/dev/null || true
            ;;
        png|jpg|jpeg|gif|svg|bmp|webp)
            cp "$file_path" "$ORG_ROOT/MEDIA_PROCESSING/" 2>/dev/null || true
            ;;
        mp3|wav|m4a|flac)
            cp "$file_path" "$ORG_ROOT/MEDIA_PROCESSING/" 2>/dev/null || true
            ;;
        mp4|mov|avi|mkv)
            cp "$file_path" "$ORG_ROOT/MEDIA_PROCESSING/" 2>/dev/null || true
            ;;
        ai|psd|sketch|xlsx|pdf)
            cp "$file_path" "$ORG_ROOT/CONTENT_CREATION/" 2>/dev/null || true
            ;;
        *)
            # For files without clear extension, determine by path
            if [[ "$file_path" == *"codester"* ]] || [[ "$file_path" == *"Codester"* ]]; then
                cp "$file_path" "$ORG_ROOT/CODASTER/" 2>/dev/null || true
            elif [[ "$file_path" == *"gumroad"* ]] || [[ "$file_path" == *"Gumroad"* ]]; then
                cp "$file_path" "$ORG_ROOT/GUMROAD/" 2>/dev/null || true
            elif [[ "$file_path" == *"etsy"* ]] || [[ "$file_path" == *"Etsy"* ]]; then
                cp "$file_path" "$ORG_ROOT/ETSY/" 2>/dev/null || true
            elif [[ "$file_path" == *"sellfy"* ]] || [[ "$file_path" == *"Sellfy"* ]]; then
                cp "$file_path" "$ORG_ROOT/SELLFY/" 2>/dev/null || true
            elif [[ "$file_path" == *"payhip"* ]] || [[ "$file_path" == *"Payhip"* ]]; then
                cp "$file_path" "$ORG_ROOT/PAYHIP/" 2>/dev/null || true
            elif [[ "$file_path" == *"lemonsqueezy"* ]] || [[ "$file_path" == *"LemonSqueezy"* ]]; then
                cp "$file_path" "$ORG_ROOT/LEMONSQUEEZY/" 2>/dev/null || true
            elif [[ "$file_path" == *"revenue"* ]] || [[ "$file_path" == *"Revenue"* ]]; then
                cp "$file_path" "$ORG_ROOT/REVENUE/" 2>/dev/null || true
            elif [[ "$file_path" == *"automation"* ]] || [[ "$file_path" == *"Automation"* ]]; then
                cp "$file_path" "$ORG_ROOT/AUTOMATION/" 2>/dev/null || true
            elif [[ "$file_path" == *"ai_"* ]] || [[ "$file_path" == *"AI_"* ]] || [[ "$file_path" == *"ai-"* ]] || [[ "$file_path" == *"AI-"* ]]; then
                cp "$file_path" "$ORG_ROOT/AI_ML/" 2>/dev/null || true
            elif [[ "$file_path" == *"seo"* ]] || [[ "$file_path" == *"SEO"* ]]; then
                cp "$file_path" "$ORG_ROOT/SEO_MARKETING/" 2>/dev/null || true
            else
                cp "$file_path" "$ORG_ROOT/MISCELLANEOUS/" 2>/dev/null || true
            fi
            ;;
    esac
}

# Counter for processed files
PROCESSED=0
TOTAL=$(wc -l < "$FORMATTED_FILE")

# Read the lost files and process them
while IFS= read -r file_path; do
    # Skip empty lines
    if [ -z "$file_path" ]; then
        continue
    fi
    
    # Only process if the file actually exists
    if [ -e "$file_path" ]; then
        categorize_file "$file_path"
        PROCESSED=$((PROCESSED + 1))
        
        # Show progress every 100 files
        if [ $((PROCESSED % 100)) -eq 0 ]; then
            echo "   Processed $PROCESSED of $TOTAL files..."
        fi
    fi
done < "$FORMATTED_FILE"

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
CODASTER_COUNT=$(find "$ORG_ROOT/CODASTER" -type f 2>/dev/null | wc -l)
GUMROAD_COUNT=$(find "$ORG_ROOT/GUMROAD" -type f 2>/dev/null | wc -l)

print_status $GREEN "✅ Organization completed! Files sorted into functional categories:"
echo "   • Automation: $AUTOMATION_COUNT files"
echo "   • Revenue: $REVENUE_COUNT files"
echo "   • Documentation: $DOC_COUNT files"
echo "   • Data Processing: $DATA_COUNT files"
echo "   • Development Tools: $DEV_COUNT files"
echo "   • Media Processing: $MEDIA_COUNT files"
echo "   • Content Creation: $CONTENT_COUNT files"
echo "   • SEO Marketing: $SEO_COUNT files"
echo "   • Codester: $CODASTER_COUNT files"
echo "   • Gumroad: $GUMROAD_COUNT files"
echo "   • Miscellaneous: $MISC_COUNT files"

print_status $YELLOW "💡 Next steps:"
echo "   1. Review the organized files in $ORG_ROOT"
echo "   2. Once verified, move them to the permanent location in MasterxEo"
echo "   3. Update any hardcoded paths in your scripts"
echo "   4. Delete the original scattered files once migration is verified"

print_status $BOLD $PURPLE "🎯 LOST FILE RESOLUTION COMPLETE"
print_status $CYAN "Processed $PROCESSED files out of $TOTAL identified"
