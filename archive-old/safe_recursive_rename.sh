#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail


# Safe Recursive Content-Aware Rename Script
# Processes directories in batches with progress tracking

BASE_PATH="/Users/steven/AvaTarArTs"

echo "🎯 SAFE RECURSIVE CONTENT-AWARE RENAMING"
echo "======================================="
echo "📁 Base path: $BASE_PATH"
echo ""

# Function to create content-aware name (same as before)
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
            # Handle text-based directories with content analysis
            case "$dir_name" in
                *"Expe_ime_tal"*|*"Experimental"*|*"experimental"*)
                    new_name="experimental_projects"
                    ;;
                *"Completed"*|*"Complete"*|*"complete"*)
                    new_name="completed_projects"
                    ;;
                *"A_chived"*|*"Archived"*|*"archived"*)
                    new_name="archived_projects"
                    ;;
                *"Fi_ished"*|*"Finished"*|*"finished"*)
                    new_name="finished_projects"
                    ;;
                *"I_dividual"*|*"Individual"*|*"individual"*)
                    new_name="individual_projects"
                    ;;
                *"Qua_tumFo_geLabs"*|*"QuantumForgeLabs"*|*"quantumforge"*)
                    new_name="quantumforge_labs_technical"
                    ;;
                *"Lice_se"*|*"License"*|*"license"*)
                    new_name="license_and_legal"
                    ;;
                *"ud83d_udcc4"*)
                    new_name="license_documentation"
                    ;;
                *"A_alysis"*|*"Analysis"*|*"analysis"*)
                    new_name="analysis_and_reports"
                    ;;
                *"P_oject"*|*"Project"*|*"project"*)
                    new_name="project_management"
                    ;;
                *"SEO"*|*"seo"*)
                    new_name="seo_optimization"
                    ;;
                *"Python"*|*"python"*|*"pytho"*)
                    new_name="python_development"
                    ;;
                *"Web"*|*"web"*|*"website"*)
                    new_name="web_development"
                    ;;
                *"AI"*|*"ai"*|*"artificial"*)
                    new_name="ai_and_machine_learning"
                    ;;
                *"Data"*|*"data"*|*"database"*)
                    new_name="data_management"
                    ;;
                *"Code"*|*"code"*|*"coding"*)
                    new_name="code_development"
                    ;;
                *"Creative"*|*"creative"*|*"design"*)
                    new_name="creative_design"
                    ;;
                *"Business"*|*"business"*|*"commercial"*)
                    new_name="business_development"
                    ;;
                *"Financial"*|*"financial"*|*"revenue"*|*"ROI"*)
                    new_name="financial_analysis"
                    ;;
                *"Technical"*|*"technical"*|*"tech"*)
                    new_name="technical_implementation"
                    ;;
                *"Documentation"*|*"documentation"*|*"docs"*)
                    new_name="documentation"
                    ;;
                *"Template"*|*"template"*|*"templates"*)
                    new_name="templates_and_tools"
                    ;;
                *"Automation"*|*"automation"*|*"automated"*)
                    new_name="automation_tools"
                    ;;
                *"Media"*|*"media"*|*"video"*|*"audio"*)
                    new_name="media_processing"
                    ;;
                *"Content"*|*"content"*|*"creation"*)
                    new_name="content_creation"
                    ;;
                *"Marketing"*|*"marketing"*|*"promotion"*)
                    new_name="marketing_strategy"
                    ;;
                *"ChatGPT"*|*"chatgpt"*|*"chat"*)
                    new_name="chatgpt_automation"
                    ;;
                *"Sora"*|*"sora"*)
                    new_name="sora_video_generation"
                    ;;
                *"HTML"*|*"html"*)
                    new_name="html_development"
                    ;;
                *"Optimized"*|*"optimized"*)
                    new_name="optimized_content"
                    ;;
                *"Comprehensive"*|*"comprehensive"*)
                    new_name="comprehensive_analysis"
                    ;;
                *"Multimedia"*|*"multimedia"*)
                    new_name="multimedia_workflows"
                    ;;
                *"Creator"*|*"creator"*)
                    new_name="creator_tools"
                    ;;
                [0-9])
                    new_name="project_$dir_name"
                    ;;
                [0-9][0-9])
                    new_name="project_$dir_name"
                    ;;
                *)
                    # Clean up the name as fallback
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

# Function to rename directory and its files
rename_directory_and_files() {
    local old_dir_name="$1"
    local new_dir_name="$2"
    local parent_path="$3"
    local old_path="$parent_path/$old_dir_name"
    local new_path="$parent_path/$new_dir_name"
    
    if [ -d "$old_path" ]; then
        # Rename the directory
        if mv "$old_path" "$new_path" 2>/dev/null; then
            # Now rename the files inside the directory
            if [ -d "$new_path" ]; then
                # Find and rename analysis files
                for file in "$new_path"/*; do
                    if [ -f "$file" ]; then
                        filename=$(basename "$file")
                        
                        # Check if it's an analysis file
                        if [[ $filename == *"_ANALYSIS.md" ]]; then
                            new_filename="${new_dir_name}_ANALYSIS.md"
                            if [ "$filename" != "$new_filename" ]; then
                                mv "$file" "$new_path/$new_filename" 2>/dev/null
                            fi
                        elif [[ $filename == *"_ANALYSIS.md.seo_backup" ]]; then
                            new_filename="${new_dir_name}_ANALYSIS.md.seo_backup"
                            if [ "$filename" != "$new_filename" ]; then
                                mv "$file" "$new_path/$new_filename" 2>/dev/null
                            fi
                        fi
                    fi
                done
            fi
            return 0
        else
            return 1
        fi
    else
        return 2
    fi
}

# Get total count of directories
total_dirs=$(find "$BASE_PATH" -type d | wc -l)
echo "📊 Total directories to process: $total_dirs"
echo ""

# Show some examples of what will be renamed
echo "🔍 Sample directories that will be processed:"
find "$BASE_PATH" -maxdepth 2 -type d | head -10 | while read -r dir; do
    if [ "$dir" != "$BASE_PATH" ]; then
        dir_name=$(basename "$dir")
        new_name=$(create_content_aware_name "$dir_name")
        if [ "$dir_name" != "$new_name" ]; then
            echo "   $dir_name → $new_name"
        fi
    fi
done

echo ""
echo "⚠️  WARNING: This will process $total_dirs directories recursively!"
echo "   This is a large operation that may take significant time."
echo ""

read -p "❓ Do you want to proceed with recursive renaming? (y/N): " confirm

if [[ $confirm =~ ^[Yy]$ ]]; then
    echo "🚀 Starting recursive rename operations..."
    echo ""
    
    # Process directories in batches
    batch_size=100
    processed=0
    success_count=0
    fail_count=0
    skip_count=0
    
    # Get all directories and process them
    find "$BASE_PATH" -type d | while read -r dir_path; do
        if [ "$dir_path" != "$BASE_PATH" ]; then
            dir_name=$(basename "$dir_path")
            parent_path=$(dirname "$dir_path")
            new_name=$(create_content_aware_name "$dir_name")
            
            # Only rename if the name actually changed
            if [ "$dir_name" != "$new_name" ]; then
                result=$(rename_directory_and_files "$dir_name" "$new_name" "$parent_path")
                case $? in
                    0) ((success_count++)) ;;
                    1) ((fail_count++)) ;;
                    2) ((skip_count++)) ;;
                esac
            else
                ((skip_count++))
            fi
            
            ((processed++))
            
            # Show progress every 100 directories
            if [ $((processed % 100)) -eq 0 ]; then
                echo "📊 Progress: $processed/$total_dirs processed (Success: $success_count, Failed: $fail_count, Skipped: $skip_count)"
            fi
        fi
    done
    
    echo ""
    echo "📊 Final Results:"
    echo "   ✅ Successful: $success_count"
    echo "   ❌ Failed: $fail_count"
    echo "   ⚠️  Skipped: $skip_count"
    echo "   📁 Total processed: $processed"
    
else
    echo "❌ Recursive rename operations cancelled"
fi

echo ""
echo "🏁 Recursive renaming script finished"
