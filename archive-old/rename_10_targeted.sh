#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail


# Rename 10 Targeted Directories Script
# Renames 10 directories with substantial names containing "x27"

BASE_PATH="/Users/steven/AvaTarArTs/02_Content_Aware_Analysis/01_Projects"

echo "🎯 RENAME 10 TARGETED DIRECTORIES"
echo "=================================="
echo "📁 Base path: $BASE_PATH"
echo ""

# Function to clean directory names
clean_name() {
    local name="$1"
    
    # Remove emojis and special characters
    name=$(echo "$name" | sed 's/[🎯📁📊🚀🛠💰✅🌐🐍🎉✨🌟🏆🧪📋🔮📝🗺️💻📜💾]//g')
    
    # Remove HTML entities
    name=$(echo "$name" | sed 's/&amp;/and/g; s/&quot;/"/g; s/&lt;/</g; s/&gt;/>/g; s/&nbsp;/ /g; s/&#x27;/'"'"'/g')
    
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

echo "🔍 Finding directories with substantial names containing 'x27'..."
echo ""

# Get directories containing "x27" and filter for substantial names (length > 10)
directories=($(ls "$BASE_PATH" | grep "x27" | awk 'length($0) > 10' | head -10))

if [ ${#directories[@]} -eq 0 ]; then
    echo "❌ No substantial directories containing 'x27' found"
    echo "🔍 Trying with length > 5..."
    directories=($(ls "$BASE_PATH" | grep "x27" | awk 'length($0) > 5' | head -10))
fi

if [ ${#directories[@]} -eq 0 ]; then
    echo "❌ No directories containing 'x27' found"
    exit 1
fi

echo "📋 Found ${#directories[@]} directories to rename:"
echo ""

# Show what will be renamed
for i in "${!directories[@]}"; do
    old_name="${directories[$i]}"
    new_name=$(clean_name "$old_name")
    
    echo "$((i+1)). OLD: $old_name"
    echo "   NEW: $new_name"
    echo "   ---"
done

echo ""
read -p "❓ Do you want to proceed with renaming these ${#directories[@]} directories? (y/N): " confirm

if [[ $confirm =~ ^[Yy]$ ]]; then
    echo "🚀 Starting rename operations..."
    echo ""
    
    success_count=0
    fail_count=0
    
    for i in "${!directories[@]}"; do
        old_name="${directories[$i]}"
        new_name=$(clean_name "$old_name")
        old_path="$BASE_PATH/$old_name"
        new_path="$BASE_PATH/$new_name"
        
        echo "Renaming: $old_name"
        echo "     to: $new_name"
        
        if [ -d "$old_path" ]; then
            if mv "$old_path" "$new_path" 2>/dev/null; then
                echo "✅ SUCCESS"
                ((success_count++))
            else
                echo "❌ FAILED"
                ((fail_count++))
            fi
        else
            echo "⚠️  SKIPPED (directory not found)"
        fi
        echo "---"
    done
    
    echo ""
    echo "📊 Results:"
    echo "   ✅ Successful: $success_count"
    echo "   ❌ Failed: $fail_count"
    echo "   ⚠️  Skipped: $((${#directories[@]} - success_count - fail_count))"
    
else
    echo "❌ Rename operations cancelled"
fi

echo ""
echo "🏁 Script completed"
