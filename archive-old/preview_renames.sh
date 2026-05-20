#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail


# Preview Rename Operations Script
# Shows what directories will be renamed without actually renaming them

BASE_PATH="/Users/steven/AvaTarArTs/02_Content_Aware_Analysis/01_Projects"

echo "🔍 PREVIEW: Directory Rename Operations"
echo "========================================"
echo "📁 Base path: $BASE_PATH"
echo ""

# Function to clean directory names (same as in the main script)
clean_name() {
    local name="$1"
    
    # Remove emojis and special characters
    name=$(echo "$name" | sed 's/[🎯📁📊🚀🛠💰✅🌐🐍🎉✨🌟🏆🧪📋🔮📝🗺️💻📜💾]//g')
    
    # Remove HTML entities
    name=$(echo "$name" | sed 's/&amp;/and/g; s/&quot;/"/g; s/&lt;/</g; s/&gt;/>/g; s/&nbsp;/ /g')
    
    # Remove multiple underscores and replace with single underscore
    name=$(echo "$name" | sed 's/__*/_/g')
    
    # Remove leading/trailing underscores
    name=$(echo "$name" | sed 's/^_*//; s/_*$//')
    
    # Remove special characters that cause issues
    name=$(echo "$name" | sed 's/[<>"'"'"'&]//g')
    
    # Replace spaces with underscores
    name=$(echo "$name" | sed 's/ /_/g')
    
    # Remove multiple underscores again
    name=$(echo "$name" | sed 's/__*/_/g')
    
    # Remove leading/trailing underscores again
    name=$(echo "$name" | sed 's/^_*//; s/_*$//')
    
    # If name is empty or too short, use a default
    if [ -z "$name" ] || [ ${#name} -lt 3 ]; then
        name="project_$(date +%s)_$RANDOM"
    fi
    
    # Ensure name starts with letter or number
    if [[ ! "$name" =~ ^[A-Za-z0-9] ]]; then
        name="project_$name"
    fi
    
    # Limit length to 100 characters
    if [ ${#name} -gt 100 ]; then
        name="${name:0:100}"
    fi
    
    echo "$name"
}

echo "📊 Analyzing directories to be renamed..."
echo ""

# Count different types of problematic names
emoji_count=$(grep -o "'/Users/steven/AvaTarArTs/02_Content_Aware_Analysis/01_Projects/[^']*'" /Users/steven/properly-rename | sed "s|'/Users/steven/AvaTarArTs/02_Content_Aware_Analysis/01_Projects/||g" | sed "s|'||g" | grep -E "^[🎯📁📊🚀🛠💰✅🌐🐍🎉✨🌟🏆🧪📋🔮📝🗺️💻📜💾]" | wc -l)

special_char_count=$(grep -o "'/Users/steven/AvaTarArTs/02_Content_Aware_Analysis/01_Projects/[^']*'" /Users/steven/properly-rename | sed "s|'/Users/steven/AvaTarArTs/02_Content_Aware_Analysis/01_Projects/||g" | sed "s|'||g" | grep -E "[<>\"'&]" | wc -l)

underscore_count=$(grep -o "'/Users/steven/AvaTarArTs/02_Content_Aware_Analysis/01_Projects/[^']*'" /Users/steven/properly-rename | sed "s|'/Users/steven/AvaTarArTs/02_Content_Aware_Analysis/01_Projects/||g" | sed "s|'||g" | grep -E "_{3,}" | wc -l)

echo "📈 Summary of problematic directories:"
echo "   🎨 Emoji-based names: $emoji_count"
echo "   ⚠️  Special characters: $special_char_count"
echo "   📏 Multiple underscores: $underscore_count"
echo ""

echo "🔄 Sample rename operations (first 20):"
echo "========================================"

# Show sample rename operations
grep -o "'/Users/steven/AvaTarArTs/02_Content_Aware_Analysis/01_Projects/[^']*'" /Users/steven/properly-rename | \
sed "s|'/Users/steven/AvaTarArTs/02_Content_Aware_Analysis/01_Projects/||g" | \
sed "s|'||g" | \
head -20 | \
while read -r old_name; do
    if [ -n "$old_name" ]; then
        new_name=$(clean_name "$old_name")
        if [ "$old_name" != "$new_name" ]; then
            echo "OLD: $old_name"
            echo "NEW: $new_name"
            echo "---"
        fi
    fi
done

echo ""
echo "💡 To execute the actual renaming, run:"
echo "   ./clean_directory_names.sh"
echo ""
echo "🏁 Preview completed"
