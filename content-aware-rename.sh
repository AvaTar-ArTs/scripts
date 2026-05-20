#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail


# Content-Aware Rename Script
# Renames directories based on their apparent content and purpose

BASE_PATH="/Users/steven/AvaTarArTs/02_Content_Aware_Analysis/01_Projects"

echo "🎯 CONTENT-AWARE DIRECTORY RENAMING"
echo "===================================="
echo "📁 Base path: $BASE_PATH"
echo ""

# Function to create content-aware name
create_content_aware_name() {
    local dir_name="$1"
    local new_name=""
    
    # Handle emoji-based directories
    case "$dir_name" in
        "🎯")
            new_name="goals_and_targets"
            ;;
        "📁")
            new_name="folders_and_organization"
            ;;
        "📊")
            new_name="analytics_and_data"
            ;;
        "🚀")
            new_name="launch_and_deployment"
            ;;
        "🛠"|"🛠️")
            new_name="tools_and_development"
            ;;
        "💰")
            new_name="financial_and_revenue"
            ;;
        "✅")
            new_name="completed_and_status"
            ;;
        "🌐")
            new_name="web_and_online"
            ;;
        "🐍")
            new_name="python_and_code"
            ;;
        "🎉")
            new_name="celebration_and_success"
            ;;
        "✨")
            new_name="features_and_highlights"
            ;;
        "🌟")
            new_name="featured_and_starred"
            ;;
        "🏆")
            new_name="achievements_and_top"
            ;;
        "🧪")
            new_name="experimental_and_testing"
            ;;
        "📋")
            new_name="documentation_and_lists"
            ;;
        "🔮")
            new_name="future_and_innovation"
            ;;
        "📝")
            new_name="documentation_and_notes"
            ;;
        "🗺️")
            new_name="navigation_and_planning"
            ;;
        "💻")
            new_name="technical_and_computing"
            ;;
        "📜")
            new_name="technical_and_code"
            ;;
        "💾")
            new_name="storage_and_data"
            ;;
        *)
            # Handle text-based directories
            case "$dir_name" in
                *"Expe_ime_tal"*|*"Experimental"*)
                    new_name="experimental_projects"
                    ;;
                *"Completed"*|*"Complete"*)
                    new_name="completed_projects"
                    ;;
                *"A_chived"*|*"Archived"*)
                    new_name="archived_projects"
                    ;;
                *"Fi_ished"*|*"Finished"*)
                    new_name="finished_projects"
                    ;;
                *"I_dividual"*|*"Individual"*)
                    new_name="individual_projects"
                    ;;
                *"Qua_tumFo_geLabs"*|*"QuantumForgeLabs"*)
                    new_name="quantumforge_labs_technical"
                    ;;
                *"Lice_se"*|*"License"*)
                    new_name="license_and_legal"
                    ;;
                *"ud83d_udcc4"*)
                    new_name="license_documentation"
                    ;;
                [0-9])
                    new_name="project_$dir_name"
                    ;;
                [0-9][0-9])
                    new_name="project_$dir_name"
                    ;;
                *)
                    # Clean up the name
                    new_name=$(echo "$dir_name" | sed 's/[🎯📁📊🚀🛠💰✅🌐🐍🎉✨🌟🏆🧪📋🔮📝🗺️💻📜💾]//g')
                    new_name=$(echo "$new_name" | sed 's/&amp;/and/g; s/&quot;/"/g; s/&lt;/</g; s/&gt;/>/g; s/&nbsp;/ /g; s/&#x27;/'"'"'/g')
                    new_name=$(echo "$new_name" | sed 's/__*/_/g')
                    new_name=$(echo "$new_name" | sed 's/^_*//; s/_*$//')
                    new_name=$(echo "$new_name" | sed 's/[<>"'"'"'&]//g')
                    new_name=$(echo "$new_name" | sed 's/ /_/g')
                    new_name=$(echo "$new_name" | sed 's/__*/_/g')
                    new_name=$(echo "$new_name" | sed 's/^_*//; s/_*$//')
                    
                    # If name is empty or too short, use a default
                    if [ -z "$new_name" ] || [ ${#new_name} -lt 3 ]; then
                        new_name="project_$(date +%s)_$RANDOM"
                    fi
                    
                    # Ensure name starts with letter or number
                    if [[ ! "$new_name" =~ ^[A-Za-z0-9] ]]; then
                        new_name="project_$new_name"
                    fi
                    
                    # Limit length
                    if [ ${#new_name} -gt 50 ]; then
                        new_name="${new_name:0:50}"
                    fi
                    ;;
            esac
            ;;
    esac
    
    echo "$new_name"
}

# Array of directories to rename
declare -a directories=(
    "Expe_ime_tal"
    "Completed"
    "ud83d_udcc4 Lice_se____This"
    "3"
    "I_dividual"
    "A_chived"
    "Qua_tumFo_geLabs tech_ical"
    "Lice_se____This"
    "1"
    "2"
    "Fi_ished"
)

echo "📋 Processing ${#directories[@]} directories:"
echo ""

# Show what will be renamed
for i in "${!directories[@]}"; do
    old_name="${directories[$i]}"
    new_name=$(create_content_aware_name "$old_name")
    
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
        new_name=$(create_content_aware_name "$old_name")
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
