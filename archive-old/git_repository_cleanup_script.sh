#!/usr/bin/env bash
# Git Repository Cleanup Script for AVATARARTS Ecosystem
# This script identifies and optionally removes temporary/cache git repositories
# while preserving important project repositories

set -e  # Exit on any error

echo "==========================================="
echo "AVATARARTS Git Repository Analysis & Cleanup"
echo "==========================================="
echo ""

# Define source directory
SOURCE_DIR="/Users/steven"
BACKUP_DIR="/Users/steven/git_repo_cleanup_backup_$(date +%Y%m%d_%H%M%S)"

# Define patterns for temporary repositories that can be removed
TEMP_REPO_PATTERNS=(
    ".cursor/plugins/cache"
    ".claude/cache"
    "node_modules"
    ".venv"
    ".env"
    "cache"
    "temp"
    "tmp"
    ".gemini"
    ".qwen"
    ".ollama"
    ".aider"
    ".harbor"
    "workspaceStorage"
    ".cursor/worktrees"
    ".claude-worktrees"
)

# Define important repositories that should be preserved
IMPORTANT_REPOS=()

# Function to identify temporary repositories
identify_temp_repos() {
    echo "Identifying temporary repositories..."
    echo ""
    
    TEMP_COUNT=0
    for pattern in "${TEMP_REPO_PATTERNS[@]}"; do
        repos=$(find "$SOURCE_DIR" -type d -name ".git" -path "*/$pattern/*" 2>/dev/null)
        if [ -n "$repos" ]; then
            echo "Pattern: $pattern"
            echo "$repos" | while read -r repo; do
                if [ -n "$repo" ]; then
                    echo "  - $repo"
                    TEMP_COUNT=$((TEMP_COUNT + 1))
                fi
            done
            echo ""
        fi
    done
    
    echo "Total temporary repositories identified: $TEMP_COUNT"
    return $TEMP_COUNT
}

# Function to identify important repositories
identify_important_repos() {
    echo "Identifying important repositories..."
    echo ""
    
    # Find repositories that are NOT in temporary locations
    IMPORTANT_COUNT=0
    find "$SOURCE_DIR" -type d -name ".git" 2>/dev/null | while read -r repo; do
        is_temp=false
        for pattern in "${TEMP_REPO_PATTERNS[@]}"; do
            if [[ "$repo" == *"/$pattern/"* ]]; then
                is_temp=true
                break
            fi
        done
        
        if [ "$is_temp" = false ]; then
            # Additional check to see if it's in a top-level project directory
            repo_path="${repo%/.git}"
            parent_dir=$(dirname "$repo_path")
            
            # If it's a direct child of home directory or in important project directories
            if [[ "$parent_dir" == "$SOURCE_DIR" ]] || [[ "$repo_path" == *"/AVATARARTS" ]] || [[ "$repo_path" == *"/pythons" ]] || [[ "$repo_path" == *"/scripts" ]] || [[ "$repo_path" == *"/github" ]]; then
                echo "  - $repo"
                IMPORTANT_COUNT=$((IMPORTANT_COUNT + 1))
            fi
        fi
    done
    
    echo "Total important repositories identified: $IMPORTANT_COUNT"
}

# Function to show summary
show_summary() {
    echo "==========================================="
    echo "GIT REPOSITORY ANALYSIS SUMMARY"
    echo "==========================================="
    
    # Count total repositories
    TOTAL_REPOS=$(find "$SOURCE_DIR" -type d -name ".git" 2>/dev/null | wc -l)
    echo "Total git repositories in system: $TOTAL_REPOS"
    
    # Count temporary repositories
    TEMP_REPOS=0
    for pattern in "${TEMP_REPO_PATTERNS[@]}"; do
        count=$(find "$SOURCE_DIR" -type d -name ".git" -path "*/$pattern/*" 2>/dev/null | wc -l)
        TEMP_REPOS=$((TEMP_REPOS + count))
    done
    echo "Temporary repositories (safe to remove): $TEMP_REPOS"
    
    IMPORTANT_REPOS=$((TOTAL_REPOS - TEMP_REPOS))
    echo "Important repositories (should preserve): $IMPORTANT_REPOS"
    echo ""
    
    if [ $TEMP_REPOS -gt 0 ]; then
        PERCENTAGE=$((TEMP_REPOS * 100 / TOTAL_REPOS))
        echo "⚠️  $PERCENTAGE% of your repositories are temporary/cache repositories"
        echo ""
    fi
}

# Function to create backup list
create_backup_list() {
    echo "Creating backup list of repositories to preserve..."
    mkdir -p "$BACKUP_DIR"
    
    # Create list of important repositories
    find "$SOURCE_DIR" -type d -name ".git" 2>/dev/null | while read -r repo; do
        is_temp=false
        for pattern in "${TEMP_REPO_PATTERNS[@]}"; do
            if [[ "$repo" == *"/$pattern/"* ]]; then
                is_temp=true
                break
            fi
        done
        
        if [ "$is_temp" = false ]; then
            echo "$repo" >> "$BACKUP_DIR/important_repos.txt"
        fi
    done
    
    # Create list of temporary repositories
    for pattern in "${TEMP_REPO_PATTERNS[@]}"; do
        find "$SOURCE_DIR" -type d -name ".git" -path "*/$pattern/*" 2>/dev/null >> "$BACKUP_DIR/temp_repos.txt"
    done
    
    echo "Backup lists created in: $BACKUP_DIR"
    echo "  - important_repos.txt: Repositories to preserve"
    echo "  - temp_repos.txt: Repositories that can be removed"
}

# Function to remove temporary repositories (with confirmation)
remove_temp_repos() {
    if [ $TEMP_REPOS -eq 0 ]; then
        echo "No temporary repositories to remove."
        return
    fi
    
    echo ""
    echo "⚠️  WARNING: This will remove $TEMP_REPOS temporary repositories"
    echo "This action cannot be undone without a backup."
    echo ""
    
    read -p "Do you want to proceed with removing temporary repositories? (yes/no): " confirm
    if [[ $confirm != "yes" ]]; then
        echo "Aborted by user."
        exit 0
    fi
    
    echo "Removing temporary repositories..."
    COUNT=0
    for pattern in "${TEMP_REPO_PATTERNS[@]}"; do
        repos=$(find "$SOURCE_DIR" -type d -name ".git" -path "*/$pattern/*" 2>/dev/null)
        if [ -n "$repos" ]; then
            echo "Removing repositories matching pattern: $pattern"
            echo "$repos" | while read -r repo; do
                if [ -n "$repo" ]; then
                    repo_path="${repo%/.git}"
                    echo "  Removing: $repo_path"
                    rm -rf "$repo_path" 2>/dev/null && echo "    ✓ Removed" || echo "    ✗ Failed"
                    COUNT=$((COUNT + 1))
                fi
            done
        fi
    done
    
    echo ""
    echo "Removed $COUNT temporary repositories"
}

# Main execution
main() {
    echo "Analyzing git repositories in $SOURCE_DIR"
    echo ""
    
    show_summary
    
    echo ""
    echo "Detailed analysis:"
    identify_temp_repos
    echo ""
    identify_important_repos
    
    echo ""
    create_backup_list
    
    echo ""
    echo "Options:"
    echo "1. Just analyze (no changes)"
    echo "2. Remove temporary repositories (with confirmation)"
    echo "3. Exit"
    echo ""
    
    read -p "Choose an option (1-3): " option
    
    case $option in
        1)
            echo "Analysis complete. No changes made."
            ;;
        2)
            remove_temp_repos
            echo ""
            echo "Cleanup complete! Please verify that all important functionality still works."
            ;;
        3)
            echo "Exiting without making changes."
            ;;
        *)
            echo "Invalid option. Exiting."
            ;;
    esac
}

# Run the main function
main
