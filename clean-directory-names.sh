#!/usr/bin/env bash

set -euo pipefail

# Clean Directory Names Script
# Converts emoji and special character directory names to simple, clean names

BASE_PATH="/Users/steven/AvaTarArTs/02_Content_Aware_Analysis/01_Projects"

echo "🧹 Starting directory name cleaning process..."
echo "📁 Base path: $BASE_PATH"
echo ""

# Function to clean directory names
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

# Read the properly-rename file and process each directory
echo "📋 Processing directories from properly-rename file..."

# Create a temporary file for the rename operations
TEMP_FILE="/tmp/rename_operations.txt"
> "$TEMP_FILE"

# Extract directory names and create rename operations
grep -o "'/Users/steven/AvaTarArTs/02_Content_Aware_Analysis/01_Projects/[^']*'" /Users/steven/properly-rename | \
sed "s|'/Users/steven/AvaTarArTs/02_Content_Aware_Analysis/01_Projects/||g" | \
sed "s|'||g" | \
while read -r old_name; do
    if [ -n "$old_name" ]; then
        new_name=$(clean_name "$old_name")
        
        # Check if the new name is different from the old name
        if [ "$old_name" != "$new_name" ]; then
            # Construct the mv command, using -- to handle potential leading hyphens in names
            echo "$old_name -> $new_name" >> "$TEMP_FILE"
        fi
    fi
done

echo "📊 Found $(wc -l < "$TEMP_FILE") directories to rename"
echo ""

# Show first 10 rename operations for review
echo "🔍 Preview of first 10 rename operations:"
head -10 "$TEMP_FILE"
echo ""

# Ask for confirmation
read -p "❓ Do you want to proceed with the renaming? (y/N): " confirm
if [[ $confirm =~ ^[Yy]$ ]]; then
    echo "🚀 Starting rename operations..."
    
    # Execute the rename operations
    while IFS=" -> " read -r old_name new_name; do
        echo "Executing: mv \"$BASE_PATH/$old_name\" \"$BASE_PATH/$new_name\""
        mv -- "$BASE_PATH/$old_name" "$BASE_PATH/$new_name"
        if [ $? -eq 0 ]; then
            echo "✅ Success"
        else
            echo "❌ Failed"
        fi
        echo ""
    done < "$TEMP_FILE"
    
    echo "🎉 Rename operations completed!"
else
    echo "❌ Rename operations cancelled"
fi

# Clean up
rm -f "$TEMP_FILE"

echo "🏁 Script completed"
