#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail


# Execute All Content-Aware Rename Script
# Renames ALL directories from properly-rename file with their internal files

BASE_PATH="/Users/steven/AvaTarArTs/02_Content_Aware_Analysis/01_Projects"

echo "🎯 EXECUTE ALL CONTENT-AWARE RENAMING"
echo "====================================="
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
    local old_path="$BASE_PATH/$old_dir_name"
    local new_path="$BASE_PATH/$new_dir_name"
    
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

echo "📊 Processing all directories from properly-rename file..."
echo ""

# Get total count
total_dirs=$(grep -o "'/Users/steven/AvaTarArTs/02_Content_Aware_Analysis/01_Projects/[^']*'" /Users/steven/properly-rename | wc -l)
echo "📁 Total directories to process: $total_dirs"
echo ""

# Process directories in batches
batch_size=50
current_batch=1
processed=0
success_count=0
fail_count=0
skip_count=0

echo "🚀 Starting batch processing (batch size: $batch_size)..."
echo ""

# Process directories
grep -o "'/Users/steven/AvaTarArTs/02_Content_Aware_Analysis/01_Projects/[^']*'" /Users/steven/properly-rename | \
sed "s|'/Users/steven/AvaTarArTs/02_Content_Aware_Analysis/01_Projects/||g" | \
sed "s|'||g" | \
while read -r old_name; do
    if [ -n "$old_name" ]; then
        new_name=$(create_content_aware_name "$old_name")
        
        # Only rename if the name actually changed
        if [ "$old_name" != "$new_name" ]; then
            result=$(rename_directory_and_files "$old_name" "$new_name")
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

echo ""
echo "🏁 All directories and files renamed successfully!"
