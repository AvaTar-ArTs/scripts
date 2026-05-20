#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail


# Analyze Folder Contents Script
# Analyzes the content of directories to understand their purpose

BASE_PATH="/Users/steven/AvaTarArTs/02_Content_Aware_Analysis/01_Projects"

echo "🔍 ANALYZING FOLDER CONTENTS"
echo "============================="
echo "📁 Base path: $BASE_PATH"
echo ""

# Function to analyze a directory
analyze_directory() {
    local dir_name="$1"
    local full_path="$BASE_PATH/$dir_name"
    
    if [ -d "$full_path" ]; then
        echo "📂 Directory: $dir_name"
        echo "   Files:"
        
        # List files in the directory
        ls -la "$full_path" | while read -r line; do
            if [[ $line == -* ]]; then
                filename=$(echo "$line" | awk '{print $NF}')
                if [[ $filename != "." && $filename != ".." ]]; then
                    echo "     - $filename"
                fi
            fi
        done
        
        # Check if there's an analysis file
        analysis_file=$(ls "$full_path" | grep -i "analysis" | head -1)
        if [ -n "$analysis_file" ]; then
            echo "   📄 Analysis file: $analysis_file"
            
            # Extract key information from the analysis file
            if [ -f "$full_path/$analysis_file" ]; then
                echo "   📋 Content preview:"
                
                # Get title
                title=$(grep -m1 "^title:" "$full_path/$analysis_file" 2>/dev/null | sed 's/title: *"//; s/"$//')
                if [ -n "$title" ]; then
                    echo "     Title: $title"
                fi
                
                # Get description
                description=$(grep -m1 "^description:" "$full_path/$analysis_file" 2>/dev/null | sed 's/description: *"//; s/"$//')
                if [ -n "$description" ]; then
                    echo "     Description: $description"
                fi
                
                # Get keywords
                keywords=$(grep -m1 "^keywords:" "$full_path/$analysis_file" 2>/dev/null | sed 's/keywords: *"//; s/"$//')
                if [ -n "$keywords" ]; then
                    echo "     Keywords: $keywords"
                fi
                
                # Get status
                status=$(grep -m1 "^status:" "$full_path/$analysis_file" 2>/dev/null | sed 's/status: *"//; s/"$//')
                if [ -n "$status" ]; then
                    echo "     Status: $status"
                fi
                
                # Get value
                value=$(grep -m1 "^value:" "$full_path/$analysis_file" 2>/dev/null | sed 's/value: *"//; s/"$//')
                if [ -n "$value" ]; then
                    echo "     Value: $value"
                fi
            fi
        fi
        
        echo "   ---"
        echo ""
    else
        echo "❌ Directory not found: $dir_name"
        echo ""
    fi
}

echo "🎯 Analyzing emoji-based directories..."
echo ""

# Analyze emoji directories
emoji_dirs=("🎯" "📊" "🚀" "🛠️" "💰" "✅" "🌐" "🐍" "🎉" "✨")

for dir in "${emoji_dirs[@]}"; do
    analyze_directory "$dir"
done

echo "🔢 Analyzing numbered directories..."
echo ""

# Analyze some numbered directories
numbered_dirs=("01_co_e_ai_a_alysis" "02_media_p_ocessi_g" "03_automatio__platfo_ms" "04_co_te_t_c_eatio" "05_data_ma_ageme_t")

for dir in "${numbered_dirs[@]}"; do
    analyze_directory "$dir"
done

echo "📝 Analyzing text-based directories..."
echo ""

# Analyze some text-based directories (first 5)
text_dirs=($(ls "$BASE_PATH" | grep -E "^[A-Za-z]" | head -5))

for dir in "${text_dirs[@]}"; do
    analyze_directory "$dir"
done

echo "🏁 Analysis completed"
