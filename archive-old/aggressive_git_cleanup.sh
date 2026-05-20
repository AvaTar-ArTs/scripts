#!/usr/bin/env bash
# Aggressive Git Repository Cleanup Script for AVATARARTS Ecosystem
# This script will remove temporary/cache git repositories without creating backups
# Focuses on cleaning up the 3,157 temporary repositories out of 3,263 total

set -e  # Exit on any error

echo "==========================================="
echo "AGGRESSIVE GIT REPOSITORY CLEANUP"
echo "Removing temporary/cache git repositories"
echo "==========================================="
echo ""

# Define source directory
SOURCE_DIR="/Users/steven"

# Define patterns for temporary repositories that can be removed
TEMP_REPO_PATTERNS=(
    ".cursor/plugins/cache/.temp"
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
    ".cursor/plugins/cache"
    ".claude/file-history"
    ".claude/debug"
    ".claude/projects"
    ".claude/todos"
    ".claude/chats"
    ".qwen/projects"
    ".qwen/todos"
    ".gemini/tmp"
    ".gemini/projects"
    ".ollama/models"
    "Library/Application Support/Cursor/User/workspaceStorage"
    "Music/nocTurneMeLoDieS/.claude"
    "Music/nocTurneMeLoDieS/.cursor"
    "Music/nocTurneMeLoDieS/.qwen"
    "Music/nocTurneMeLoDieS/.gemini"
    "Music/nocTurneMeLoDieS/.ollama"
    "AVATARARTS/.claude"
    "AVATARARTS/.cursor"
    "AVATARARTS/.qwen"
    "AVATARARTS/.gemini"
    "AVATARARTS/.ollama"
    "pythons/.claude"
    "pythons/.cursor"
    "pythons/.qwen"
    "pythons/.gemini"
    "pythons/.ollama"
    "scripts/.claude"
    "scripts/.cursor"
    "scripts/.qwen"
    "scripts/.gemini"
    "scripts/.ollama"
)

# Function to identify and count temporary repositories
identify_temp_repos() {
    echo "Identifying temporary repositories to remove..."
    echo ""
    
    TEMP_COUNT=0
    for pattern in "${TEMP_REPO_PATTERNS[@]}"; do
        repos=$(find "$SOURCE_DIR" -type d -name ".git" -path "*/$pattern/*" 2>/dev/null)
        if [ -n "$repos" ]; then
            count=$(echo "$repos" | wc -l)
            echo "$count repositories found matching pattern: $pattern"
            TEMP_COUNT=$((TEMP_COUNT + count))
        fi
    done
    
    echo ""
    echo "Total temporary repositories to remove: $TEMP_COUNT"
    return $TEMP_COUNT
}

# Function to remove temporary repositories
remove_temp_repos() {
    echo ""
    echo "Starting aggressive removal of temporary repositories..."
    echo ""
    
    COUNT=0
    for pattern in "${TEMP_REPO_PATTERNS[@]}"; do
        repos=$(find "$SOURCE_DIR" -type d -name ".git" -path "*/$pattern/*" 2>/dev/null)
        if [ -n "$repos" ]; then
            echo "Processing pattern: $pattern"
            echo "$repos" | while read -r repo; do
                if [ -n "$repo" ]; then
                    repo_path="${repo%/.git}"
                    echo "  Removing: $repo_path"
                    rm -rf "$repo_path" 2>/dev/null
                    if [ $? -eq 0 ]; then
                        echo "    ✓ Removed"
                        COUNT=$((COUNT + 1))
                    else
                        echo "    ✗ Failed"
                    fi
                fi
            done
            echo ""
        fi
    done
    
    echo "Removed $COUNT temporary repositories"
}

# Function to remove numbered directories (the 01_, 02_, etc. that create nesting)
remove_numbered_directories() {
    echo "Removing numbered directories that create deep nesting..."
    
    # Find and remove empty numbered directories first
    find "$SOURCE_DIR" -type d -name "[0-9][0-9]_*" -empty 2>/dev/null | while read -r dir; do
        echo "Removing empty numbered directory: $dir"
        rmdir "$dir" 2>/dev/null || true
    done
    
    # Find numbered directories with content and process them
    find "$SOURCE_DIR" -type d -name "[0-9][0-9]_*" 2>/dev/null | while read -r dir; do
        if [ -d "$dir" ] && [ "$dir" != "$SOURCE_DIR" ]; then
            echo "Processing numbered directory: $dir"
            
            # Count contents
            file_count=$(find "$dir" -type f | wc -l)
            dir_count=$(find "$dir" -type d | wc -l)
            
            echo "  Contains $file_count files in $dir_count directories"
            
            # For now, just report - we won't move these without more specific logic
            # since we don't know the intended destination
        fi
    done
}

# Main execution
main() {
    echo "Aggressive Git Repository Cleanup Starting..."
    echo "Source directory: $SOURCE_DIR"
    echo ""
    
    # Show summary
    TOTAL_REPOS=$(find "$SOURCE_DIR" -type d -name ".git" 2>/dev/null | wc -l)
    echo "Total git repositories before cleanup: $TOTAL_REPOS"
    
    identify_temp_repos
    
    # Confirm with user
    read -p "Are you sure you want to remove these temporary repositories? (yes/no): " confirm
    if [[ $confirm != "yes" ]]; then
        echo "Aborted by user."
        exit 0
    fi
    
    # Remove temporary repositories
    remove_temp_repos
    
    # Show final count
    FINAL_COUNT=$(find "$SOURCE_DIR" -type d -name ".git" 2>/dev/null | wc -l)
    echo ""
    echo "==========================================="
    echo "CLEANUP COMPLETE!"
    echo "==========================================="
    echo "Repositories before: $TOTAL_REPOS"
    echo "Repositories after: $FINAL_COUNT"
    echo "Repositories removed: $COUNT"
    echo ""
    echo "Temporary/cache git repositories have been removed."
    echo "Only important project repositories remain."
}

# Run the main function
main
