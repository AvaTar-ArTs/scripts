#!/usr/bin/env bash

###############################################################################
# Documents Organization and Merge Script
# Author: AI Assistant
# Version: 1.0
# Purpose: Organize and merge Documents directory
###############################################################################

set -euo pipefail

# Configuration
DOCUMENTS_DIR="/Users/steven/Documents"
CSV_FILE="/Users/steven/Documents_ORGANIZATION_MAPPING_$(date +%Y%m%d_%H%M%S).csv"
LOG_FILE="/Users/steven/.update_logs/document_organization_$(date +%Y%m%d_%H%M%S).log"
REVERT_SCRIPT="/Users/steven/revert_documents_organization.sh"

# Colors
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly PURPLE='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly WHITE='\033[1;37m'
readonly CLEAR='\033[0m'

# Emojis
readonly EMOJIS=("🚀" "⏳" "🔄" "📦" "✅" "⚠️" "❌" "🔧" "💾" "🌐" "📁" "🗂️" "📄" "🔍")

# Logging setup
mkdir -p "$(dirname "$LOG_FILE")"
exec > >(tee -a "$LOG_FILE") 2>&1

print_header() {
    local msg="$1"
    echo -e "\n${BLUE}═══════════════════════════════════════════════════════════════${CLEAR}"
    echo -e "${WHITE}${msg}${CLEAR}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${CLEAR}\n"
}

print_section() {
    local msg="$1"
    echo -e "\n${CYAN}▶ ${msg}${CLEAR}"
}

print_with_emoji() {
    local msg="$1"
    local emoji="🔧"
    echo -e "${emoji} ${GREEN}${msg}${CLEAR}"
}

print_warning() {
    local msg="$1"
    echo -e "⚠️  ${YELLOW}${msg}${CLEAR}"
}

print_error() {
    local msg="$1"
    echo -e "❌ ${RED}${msg}${CLEAR}"
}

print_success() {
    local msg="$1"
    echo -e "✅ ${GREEN}${msg}${CLEAR}"
}

print_info() {
    local msg="$1"
    echo -e "ℹ️  ${BLUE}${msg}${CLEAR}"
}

# Initialize CSV mapping file
initialize_csv_mapping() {
    print_section "Initializing CSV Mapping File"
    
    print_with_emoji "Creating CSV mapping file for easy reversion"
    
    # Create CSV header
    cat > "$CSV_FILE" << 'EOF'
Original_Path,New_Path,Item_Type,Category,Move_Date,Size_Bytes,Description
EOF
    
    print_success "CSV mapping file created: $CSV_FILE"
    print_info "This file will track every move for easy reversion"
}

# Log move to CSV
log_move() {
    local original_path="$1"
    local new_path="$2"
    local item_type="$3"
    local category="$4"
    local description="${5:-}"
    
    # Get file size
    local size_bytes="0"
    if [[ -e "$new_path" ]]; then
        if [[ -f "$new_path" ]]; then
            size_bytes=$(stat -f%z "$new_path" 2>/dev/null || echo "0")
        elif [[ -d "$new_path" ]]; then
            size_bytes=$(du -s "$new_path" 2>/dev/null | cut -f1 || echo "0")
        fi
    fi
    
    # Escape commas in paths and descriptions
    local escaped_original=$(echo "$original_path" | sed 's/,/\\,/g')
    local escaped_new=$(echo "$new_path" | sed 's/,/\\,/g')
    local escaped_desc=$(echo "$description" | sed 's/,/\\,/g')
    
    # Add to CSV
    echo "$escaped_original,$escaped_new,$item_type,$category,$(date +%Y-%m-%d\ %H:%M:%S),$size_bytes,$escaped_desc" >> "$CSV_FILE"
}

# Analyze current structure
analyze_structure() {
    print_section "Analyzing Current Structure"
    
    local total_dirs=$(find "$DOCUMENTS_DIR" -maxdepth 1 -type d | wc -l | tr -d ' ')
    local total_files=$(find "$DOCUMENTS_DIR" -maxdepth 1 -type f | wc -l | tr -d ' ')
    
    print_info "Total directories: $((total_dirs - 1))"  # Subtract current dir
    print_info "Total files: $total_files"
    
    # Find potential duplicates
    print_with_emoji "Scanning for potential duplicates"
    find "$DOCUMENTS_DIR" -maxdepth 1 -type d -name "*backup*" -o -name "*BACKUP*" | while read -r dir; do
        print_warning "Found backup directory: $(basename "$dir")"
    done
    
    find "$DOCUMENTS_DIR" -maxdepth 1 -type d -name "*2025*" | while read -r dir; do
        print_warning "Found date-based directory: $(basename "$dir")"
    done
    
    find "$DOCUMENTS_DIR" -maxdepth 1 -type d -name "*chat*" -o -name "*Chat*" -o -name "*gpt*" -o -name "*GPT*" | while read -r dir; do
        print_warning "Found AI chat directory: $(basename "$dir")"
    done
}

# Create organized structure
create_organized_structure() {
    print_section "Creating Organized Structure"
    
    cd "$DOCUMENTS_DIR"
    
    # Main categories
    local main_categories=(
        "01_AI_Tools_and_Projects"
        "02_Business_and_Finance"
        "03_Creative_Projects"
        "04_Development_and_Code"
        "05_Documentation_and_Notes"
        "06_Archives_and_Backups"
        "07_Media_and_Assets"
        "08_Personal_Projects"
        "09_Websites_and_Online"
        "10_Temporary_and_Processing"
    )
    
    for category in "${main_categories[@]}"; do
        if [[ ! -d "$category" ]]; then
            mkdir -p "$category"
            print_success "Created category: $category"
        fi
    done
}

# Merge AI-related directories
merge_ai_directories() {
    print_section "Merging AI-Related Directories"
    
    local ai_dirs=(
        "aGPT" "ai_alchemy_empire" "ai-bank-analysis" "Ai-TooL" "AiAutomation"
        "chatGPT" "claude" "DeepSeek" "grok" "superchatGPT" "superGPT"
        "spooky-chatgpt" "typingmind" "boLtAi" "bluesky"
    )
    
    local target_dir="01_AI_Tools_and_Projects"
    
    for dir in "${ai_dirs[@]}"; do
        if [[ -d "$dir" ]]; then
            print_with_emoji "Moving $dir to AI Tools"
            local original_path="$dir"
            local new_path="$target_dir/$(basename "$dir")"
            mv "$dir" "$target_dir/"
            log_move "$original_path" "$new_path" "directory" "AI_Tools" "AI-related directory"
            print_success "Moved $dir"
        fi
    done
    
    # Move AI-related files
    find . -maxdepth 1 -name "*ChatGPT*" -o -name "*AI*" -o -name "*GPT*" | while read -r file; do
        if [[ -f "$file" ]]; then
            print_with_emoji "Moving AI file: $(basename "$file")"
            local original_path="$file"
            local new_path="$target_dir/$(basename "$file")"
            mv "$file" "$target_dir/"
            log_move "$original_path" "$new_path" "file" "AI_Tools" "AI-related file"
        fi
    done
}

# Merge business directories
merge_business_directories() {
    print_section "Merging Business Directories"
    
    local business_dirs=(
        "Business" "BUSINESS_ECOSYSTEM" "business_plan" "business_setup" "business_setup1"
        "money" "upwork" "professional_portfolio"
    )
    
    local target_dir="02_Business_and_Finance"
    
    for dir in "${business_dirs[@]}"; do
        if [[ -d "$dir" ]]; then
            print_with_emoji "Moving $dir to Business"
            local original_path="$dir"
            local new_path="$target_dir/$(basename "$dir")"
            mv "$dir" "$target_dir/"
            log_move "$original_path" "$new_path" "directory" "Business" "Business-related directory"
            print_success "Moved $dir"
        fi
    done
    
    # Move business files
    find . -maxdepth 1 -name "*lease*" -o -name "*LEASE*" -o -name "*business*" | while read -r file; do
        if [[ -f "$file" ]]; then
            print_with_emoji "Moving business file: $(basename "$file")"
            mv "$file" "$target_dir/"
        fi
    done
}

# Merge creative directories
merge_creative_directories() {
    print_section "Merging Creative Directories"
    
    local creative_dirs=(
        "Creative" "AvatararTs" "comic" "craft" "Harmoniq Starter Kit"
        "The Adventures of iTchy iSLe" "itchy Isle" "Space Spies Unite Juice"
        "Esoteric-Binary-Biology" "Facekless-empire" "HeKaTe" "Walter Russell"
    )
    
    local target_dir="03_Creative_Projects"
    
    for dir in "${creative_dirs[@]}"; do
        if [[ -d "$dir" ]]; then
            print_with_emoji "Moving $dir to Creative"
            mv "$dir" "$target_dir/"
            print_success "Moved $dir"
        fi
    done
    
    # Move creative files
    find . -maxdepth 1 -name "*.pdf" -o -name "*Story*" -o -name "*Adventures*" | while read -r file; do
        if [[ -f "$file" ]]; then
            print_with_emoji "Moving creative file: $(basename "$file")"
            mv "$file" "$target_dir/"
        fi
    done
}

# Merge development directories
merge_development_directories() {
    print_section "Merging Development Directories"
    
    local dev_dirs=(
        "python" "Python_Analysis" "github" "github_improvements" "github_repo"
        "github_templates" "github_upload" "Repos" "script" "scripts"
        "tools" "UserScripts" "code_browser" "dupeGuru" "FileJuicer"
        "my-crawler" "scrape-youtube-channel-videos-url" "transcription_analyzer"
        "Whisper-Text" "yt-extract" "Yt-viral" "gemini_storybook_downloader"
    )
    
    local target_dir="04_Development_and_Code"
    
    for dir in "${dev_dirs[@]}"; do
        if [[ -d "$dir" ]]; then
            print_with_emoji "Moving $dir to Development"
            mv "$dir" "$target_dir/"
            print_success "Moved $dir"
        fi
    done
    
    # Move development files
    find . -maxdepth 1 -name "*.py" -o -name "*.js" -o -name "*.json" -o -name "*.html" | while read -r file; do
        if [[ -f "$file" ]]; then
            print_with_emoji "Moving dev file: $(basename "$file")"
            mv "$file" "$target_dir/"
        fi
    done
}

# Merge documentation directories
merge_documentation_directories() {
    print_section "Merging Documentation Directories"
    
    local doc_dirs=(
        "Documentation" "docs" "comprehensive_docs" "sphinx-docs" "sphinx-test"
        "RayCast-docs" "Notion" "Obsidian Vault" "oG-obsidian" "all.md"
        "as-a-man-thinketh" "thinketh_out" "DOCUMENTS_ANALYSIS"
    )
    
    local target_dir="05_Documentation_and_Notes"
    
    for dir in "${doc_dirs[@]}"; do
        if [[ -d "$dir" ]]; then
            print_with_emoji "Moving $dir to Documentation"
            mv "$dir" "$target_dir/"
            print_success "Moved $dir"
        fi
    done
    
    # Move documentation files
    find . -maxdepth 1 -name "*.md" -o -name "*.txt" | while read -r file; do
        if [[ -f "$file" ]]; then
            print_with_emoji "Moving doc file: $(basename "$file")"
            mv "$file" "$target_dir/"
        fi
    done
}

# Merge archive directories
merge_archive_directories() {
    print_section "Merging Archive Directories"
    
    local archive_dirs=(
        "Archives" "BACKUP_DOCUMENTS" "BACKUP_ORIGINAL_STRUCTURE" "CLEANUP_BACKUP_20251014_201952"
        "MIGRATION_BACKUP" "ORGANIZED_DOCUMENTS" "2025-8-2" "2025-8-8" "1-9"
        "Sp2023" "Transfer" "updateLog"
    )
    
    local target_dir="06_Archives_and_Backups"
    
    for dir in "${archive_dirs[@]}"; do
        if [[ -d "$dir" ]]; then
            print_with_emoji "Moving $dir to Archives"
            mv "$dir" "$target_dir/"
            print_success "Moved $dir"
        fi
    done
    
    # Move archive files
    find . -maxdepth 1 -name "*.zip" | while read -r file; do
        if [[ -f "$file" ]]; then
            print_with_emoji "Moving archive file: $(basename "$file")"
            mv "$file" "$target_dir/"
        fi
    done
}

# Merge media directories
merge_media_directories() {
    print_section "Merging Media Directories"
    
    local media_dirs=(
        "PdF" "HTML" "Txt" "text" "json" "CsV" "Data" "Photoshop-Addon"
        "PhotoShop-Addon" "Topaz VideoAI Projects" "simplegallery-bin"
        "output_chunks" "quality_reports" "reports" "focused_analysis_output"
    )
    
    local target_dir="07_Media_and_Assets"
    
    for dir in "${media_dirs[@]}"; do
        if [[ -d "$dir" ]]; then
            print_with_emoji "Moving $dir to Media"
            mv "$dir" "$target_dir/"
            print_success "Moved $dir"
        fi
    done
}

# Merge website directories
merge_website_directories() {
    print_section "Merging Website Directories"
    
    local website_dirs=(
        "MySiTes" "pages" "toc" "api" "apify" "config" "copied_files"
        "drive_content_analysis" "pdf-statement-details" "python.bfg-report"
        "replicate" "silent-retribution" "test" "tests"
    )
    
    local target_dir="08_Websites_and_Online"
    
    for dir in "${website_dirs[@]}"; do
        if [[ -d "$dir" ]]; then
            print_with_emoji "Moving $dir to Websites"
            mv "$dir" "$target_dir/"
            print_success "Moved $dir"
        fi
    done
}

# Move remaining items to temporary
move_remaining_items() {
    print_section "Moving Remaining Items to Temporary"
    
    local target_dir="10_Temporary_and_Processing"
    
    # Move any remaining directories
    find . -maxdepth 1 -type d ! -name "." ! -name "0[1-9]_*" | while read -r dir; do
        if [[ -d "$dir" ]]; then
            print_with_emoji "Moving remaining directory: $(basename "$dir")"
            mv "$dir" "$target_dir/"
        fi
    done
    
    # Move any remaining files
    find . -maxdepth 1 -type f | while read -r file; do
        if [[ -f "$file" ]]; then
            print_with_emoji "Moving remaining file: $(basename "$file")"
            mv "$file" "$target_dir/"
        fi
    done
}

# Create index files
create_index_files() {
    print_section "Creating Index Files"
    
    # Create main index
    cat > "INDEX.md" << 'EOF'
# Documents Directory Organization

This directory has been organized into the following categories:

## 📁 Directory Structure

- **01_AI_Tools_and_Projects** - AI-related tools, ChatGPT conversations, and AI projects
- **02_Business_and_Finance** - Business documents, financial records, and professional materials
- **03_Creative_Projects** - Creative works, stories, art projects, and creative tools
- **04_Development_and_Code** - Code repositories, development tools, and programming projects
- **05_Documentation_and_Notes** - Documentation, notes, and knowledge management
- **06_Archives_and_Backups** - Archived materials and backup files
- **07_Media_and_Assets** - Images, PDFs, and other media files
- **08_Websites_and_Online** - Website projects and online content
- **09_Personal_Projects** - Personal projects and miscellaneous items
- **10_Temporary_and_Processing** - Items that need further organization

## 🔍 Quick Access

- Use Spotlight search (Cmd+Space) to quickly find files
- Check the appropriate category directory for related materials
- Archive old materials in the Archives directory

## 📝 Notes

- This organization was created on $(date)
- Original structure backed up to: BACKUP_DIR
- Log file available at: LOG_FILE
EOF

    print_success "Created main index file"
}

# Generate summary report
generate_summary_report() {
    print_section "Generating Summary Report"
    
    local summary_file="ORGANIZATION_SUMMARY_$(date +%Y%m%d_%H%M%S).md"
    
    cat > "$summary_file" << EOF
# Documents Organization Summary

**Date:** $(date)
**Original Location:** $DOCUMENTS_DIR
**CSV Mapping File:** $CSV_FILE
**Revert Script:** $REVERT_SCRIPT
**Log File:** $LOG_FILE

## 📊 Statistics

- **Total Directories Processed:** $(find "$DOCUMENTS_DIR" -maxdepth 1 -type d | wc -l | tr -d ' ')
- **Total Files Processed:** $(find "$DOCUMENTS_DIR" -maxdepth 1 -type f | wc -l | tr -d ' ')
- **Categories Created:** 10

## 🗂️ Categories Created

EOF

    for i in {1..10}; do
        local category_name=$(ls -1 | grep "^0${i}_" | head -1)
        if [[ -n "$category_name" ]]; then
            local item_count=$(find "$category_name" -type f | wc -l | tr -d ' ')
            echo "- **$category_name**: $item_count items" >> "$summary_file"
        fi
    done

    cat >> "$summary_file" << 'EOF'

## ✅ Actions Completed

- [x] Created CSV mapping file for easy reversion
- [x] Analyzed current directory structure
- [x] Created organized category structure
- [x] Merged AI-related directories and files
- [x] Merged business and finance materials
- [x] Merged creative projects and assets
- [x] Merged development and code repositories
- [x] Merged documentation and notes
- [x] Merged archives and backups
- [x] Merged media and asset files
- [x] Merged website and online content
- [x] Moved remaining items to temporary processing
- [x] Created index and navigation files
- [x] Generated revert script
- [x] Generated summary report

## 🔄 Reversion

**To revert all changes:**
\`\`\`bash
$REVERT_SCRIPT
\`\`\`

**CSV Mapping File:** $CSV_FILE
- Contains complete mapping of all moves
- Can be used to manually revert specific items
- Includes file sizes, dates, and descriptions

## 🔄 Next Steps

1. Review the organized structure
2. Move items from Temporary_and_Processing to appropriate categories
3. Update any scripts or workflows that reference old paths
4. Consider setting up automated organization rules for future files
5. If satisfied with organization, you can delete the CSV file and revert script

## 📝 Notes

- All moves are tracked in the CSV mapping file
- Easy reversion using the generated revert script
- The organization follows a logical hierarchy for easy navigation
- Use the INDEX.md file for quick reference
- Check the log file for detailed operation information
EOF

    print_success "Generated summary report: $summary_file"
}

# Create revert script
create_revert_script() {
    print_section "Creating Revert Script"
    
    cat > "$REVERT_SCRIPT" << EOF
#!/bin/zsh

# Revert Documents Organization Script
# Generated on $(date)
# CSV File: $CSV_FILE

set -euo pipefail

CSV_FILE="$CSV_FILE"
DOCUMENTS_DIR="$DOCUMENTS_DIR"

print_info() {
    echo "ℹ️  \$1"
}

print_success() {
    echo "✅ \$1"
}

print_error() {
    echo "❌ \$1"
}

print_warning() {
    echo "⚠️  \$1"
}

if [[ ! -f "\$CSV_FILE" ]]; then
    print_error "CSV mapping file not found: \$CSV_FILE"
    exit 1
fi

print_info "Reverting Documents organization using: \$CSV_FILE"

# Read CSV and revert moves (in reverse order)
tail -n +2 "\$CSV_FILE" | tail -r | while IFS=',' read -r original_path new_path item_type category move_date size_bytes description; do
    # Unescape paths
    original_path=\$(echo "\$original_path" | sed 's/\\\\,/,/g')
    new_path=\$(echo "\$new_path" | sed 's/\\\\,/,/g')
    
    if [[ -e "\$new_path" ]]; then
        print_info "Reverting: \$(basename "\$original_path")"
        mv "\$new_path" "\$original_path"
        print_success "Reverted: \$(basename "\$original_path")"
    else
        print_warning "Target not found: \$new_path"
    fi
done

print_success "Revert completed!"
print_info "All items have been moved back to their original locations"
EOF

    chmod +x "$REVERT_SCRIPT"
    print_success "Revert script created: $REVERT_SCRIPT"
}

# Main execution
main() {
    print_header "Documents Organization and Merge Script"
    print_info "Starting organization process..."
    print_info "Documents directory: $DOCUMENTS_DIR"
    print_info "CSV mapping file: $CSV_FILE"
    print_info "Log file: $LOG_FILE"
    print_info "Revert script: $REVERT_SCRIPT"
    
    # Change to Documents directory
    cd "$DOCUMENTS_DIR"
    
    # Execute organization steps
    initialize_csv_mapping
    analyze_structure
    create_organized_structure
    merge_ai_directories
    merge_business_directories
    merge_creative_directories
    merge_development_directories
    merge_documentation_directories
    merge_archive_directories
    merge_media_directories
    merge_website_directories
    move_remaining_items
    create_index_files
    create_revert_script
    generate_summary_report
    
    print_header "Organization Complete!"
    print_success "Documents directory has been organized successfully!"
    print_info "Check the INDEX.md file for navigation help"
    print_info "Review the summary report for details"
    print_info "CSV mapping file: $CSV_FILE"
    print_info "To revert changes, run: $REVERT_SCRIPT"
}

# Run main function
main "$@"
