#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail


# Test Rename Script - 10 Directories Only
# Renames the 10 specific directories you provided

BASE_PATH="/Users/steven/AvaTarArTs/02_Content_Aware_Analysis/01_Projects"

echo "🧪 TEST RENAME: 10 Directories Only"
echo "===================================="
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

# Array of the 10 specific directories to rename
declare -a directories=(
    "x27;__As a Ma_ Thi_keth"
    "x27;) as f___            jso_.dump('"
    "x27;) as f___            f.w_ite('"
    "x27;) as f___                f.w_ite('"
    "x27;) as f___            jso_.dump(self.mig_atio'"
    "x27;s _&quot;As a Ma_ Thi_keth_&quot; with multipl'"
    "x27;s _ole as a_ &quot;AI Alchemist &amp; C_eative'"
    "x27;) as f___            jso_.dump(_epo_t, f, i_de'"
    "x27;) as f___                    f.w_ite(p_oject_d'"
    "x27;) as f___                f.w_ite(_eadme_co_te'"
)

echo "📋 Processing 10 specific directories:"
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
echo "🔍 Checking if directories exist..."
echo ""

# Check if directories exist before renaming
for i in "${!directories[@]}"; do
    old_name="${directories[$i]}"
    full_path="$BASE_PATH/$old_name"
    
    if [ -d "$full_path" ]; then
        echo "✅ EXISTS: $old_name"
    else
        echo "❌ NOT FOUND: $old_name"
    fi
done

echo ""
read -p "❓ Do you want to proceed with renaming these 10 directories? (y/N): " confirm

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
    echo "   ⚠️  Skipped: $((10 - success_count - fail_count))"
    
else
    echo "❌ Rename operations cancelled"
fi

echo ""
echo "🏁 Test script completed"
