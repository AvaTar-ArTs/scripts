#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail

# Clipboard Search Helpers
# Add these to your .bashrc or .zshrc for quick access

# Base directory
CLIP_BASE="/Users/steven/Documents/paste_export/organized_v2"

# Search clipboard by content
clip-search() {
    if [ -z "$1" ]; then
        echo "Usage: clip-search <search_term>"
        echo "Example: clip-search ffmpeg"
        return 1
    fi
    echo "Searching for: $1"
    grep -r -i --color=always "$1" "$CLIP_BASE" | head -50
}

# List recent clips (last 20)
clip-recent() {
    echo "Recent clipboard items (last 20):"
    find "$CLIP_BASE" -type f \( -name "*.txt" -o -name "*.py" -o -name "*.js" -o -name "*.sh" \) \
        | sort -r | head -20 | while read file; do
        echo "$(basename "$file")"
    done
}

# Find clips from a specific date
clip-date() {
    if [ -z "$1" ]; then
        echo "Usage: clip-date YYYY-MM-DD"
        echo "Example: clip-date 2025-10-16"
        return 1
    fi
    echo "Files from $1:"
    find "$CLIP_BASE" -name "$1*" | sort
}

# Search in specific project
clip-project() {
    if [ -z "$1" ] || [ -z "$2" ]; then
        echo "Usage: clip-project <project_name> <search_term>"
        echo "Example: clip-project etsy gallery"
        echo ""
        echo "Available projects:"
        ls "$CLIP_BASE/PROJECTS/"
        return 1
    fi
    echo "Searching in project '$1' for: $2"
    grep -r -i --color=always "$2" "$CLIP_BASE/PROJECTS/"*"$1"* | head -30
}

# Search in specific workflow
clip-workflow() {
    if [ -z "$1" ] || [ -z "$2" ]; then
        echo "Usage: clip-workflow <workflow_name> <search_term>"
        echo "Example: clip-workflow transcribe whisper"
        echo ""
        echo "Available workflows:"
        ls "$CLIP_BASE/WORKFLOWS/"
        return 1
    fi
    echo "Searching in workflow '$1' for: $2"
    grep -r -i --color=always "$2" "$CLIP_BASE/WORKFLOWS/"*"$1"* | head -30
}

# Show all Python scripts
clip-python() {
    echo "All Python scripts:"
    find "$CLIP_BASE" -name "*.py" | sort
}

# Show all shell scripts
clip-shell() {
    echo "All shell scripts:"
    find "$CLIP_BASE" -name "*.sh" | sort
}

# Show all JavaScript files
clip-js() {
    echo "All JavaScript files:"
    find "$CLIP_BASE" -name "*.js" | sort
}

# Show statistics
clip-stats() {
    echo "=== Clipboard Statistics ==="
    echo ""
    echo "Total files: $(find "$CLIP_BASE" -type f | wc -l)"
    echo ""
    echo "By type:"
    echo "  Python:     $(find "$CLIP_BASE" -name "*.py" | wc -l)"
    echo "  JavaScript: $(find "$CLIP_BASE" -name "*.js" | wc -l)"
    echo "  Shell:      $(find "$CLIP_BASE" -name "*.sh" | wc -l)"
    echo "  Markdown:   $(find "$CLIP_BASE" -name "*.md" | wc -l)"
    echo "  JSON:       $(find "$CLIP_BASE" -name "*.json" | wc -l)"
    echo "  Text:       $(find "$CLIP_BASE" -name "*.txt" | wc -l)"
    echo ""
    echo "By category:"
    for dir in "$CLIP_BASE"/*/; do
        name=$(basename "$dir")
        count=$(find "$dir" -type f | wc -l)
        printf "  %-30s: %5d files\n" "$name" "$count"
    done
}

# Show sprint days
clip-sprints() {
    echo "=== High Activity Sprint Days ==="
    for dir in "$CLIP_BASE/HIGH_ACTIVITY_SPRINTS/"*/; do
        name=$(basename "$dir")
        count=$(find "$dir" -type f | wc -l)
        echo "$name: $count files"
    done
}

# View a random clip (for inspiration)
clip-random() {
    random_file=$(find "$CLIP_BASE" -type f -name "*.txt" -o -name "*.py" -o -name "*.js" | sort -R | head -1)
    echo "Random clip: $random_file"
    echo "---"
    head -20 "$random_file"
}

# Search for code with specific pattern
clip-code() {
    if [ -z "$1" ]; then
        echo "Usage: clip-code <pattern>"
        echo "Example: clip-code 'def transcribe'"
        return 1
    fi
    echo "Searching code for pattern: $1"
    find "$CLIP_BASE/DEVELOPMENT" -type f \( -name "*.py" -o -name "*.js" -o -name "*.sh" \) \
        -exec grep -l "$1" {} \; | while read file; do
        echo "=== $(basename "$file") ==="
        grep -C 3 --color=always "$1" "$file"
        echo ""
    done | head -50
}

# Find similar content (files containing the same keywords)
clip-similar() {
    if [ -z "$1" ]; then
        echo "Usage: clip-similar <file_path>"
        echo "Finds other files with similar content"
        return 1
    fi

    if [ ! -f "$1" ]; then
        echo "Error: File not found: $1"
        return 1
    fi

    # Extract key words from the file (simple approach)
    keywords=$(cat "$1" | tr '[:space:]' '\n' | grep -E '^[a-zA-Z]{4,}$' | sort | uniq -c | sort -rn | head -5 | awk '{print $2}')

    echo "Finding similar files based on keywords: $keywords"
    for keyword in $keywords; do
        echo ""
        echo "Files containing '$keyword':"
        grep -l -r -i "$keyword" "$CLIP_BASE" | grep -v "$(basename "$1")" | head -5
    done
}

# Timeline view
clip-timeline() {
    if [ -z "$1" ]; then
        echo "Usage: clip-timeline <YYYY-QX>"
        echo "Example: clip-timeline 2025-Q1"
        echo ""
        echo "Available quarters:"
        ls "$CLIP_BASE/TIMELINE/"
        return 1
    fi

    quarter_dir="$CLIP_BASE/TIMELINE/$1"
    if [ ! -d "$quarter_dir" ]; then
        echo "Error: Quarter not found: $1"
        return 1
    fi

    count=$(find "$quarter_dir" -type f | wc -l)
    echo "Timeline: $1 ($count files)"
    echo ""

    # Show some recent files from that quarter
    find "$quarter_dir" -type f | sort -r | head -10 | while read file; do
        echo "$(basename "$file")"
    done
}

# Cross-project view
clip-cross() {
    echo "=== Cross-Project Connections ==="
    for dir in "$CLIP_BASE/CROSS_PROJECT/"*/; do
        name=$(basename "$dir")
        count=$(find "$dir" -type f | wc -l)
        echo "$name: $count files"
    done
}

# Help function
clip-help() {
    echo "=== Clipboard Search Helpers ==="
    echo ""
    echo "Content Search:"
    echo "  clip-search <term>           - Search all content"
    echo "  clip-project <proj> <term>   - Search specific project"
    echo "  clip-workflow <flow> <term>  - Search specific workflow"
    echo "  clip-code <pattern>          - Search code for pattern"
    echo ""
    echo "Browse & Filter:"
    echo "  clip-recent                  - Show recent clips"
    echo "  clip-date YYYY-MM-DD         - Show clips from date"
    echo "  clip-timeline YYYY-QX        - Show clips from quarter"
    echo "  clip-random                  - Show random clip"
    echo "  clip-similar <file>          - Find similar content"
    echo ""
    echo "By Type:"
    echo "  clip-python                  - List Python scripts"
    echo "  clip-shell                   - List shell scripts"
    echo "  clip-js                      - List JavaScript files"
    echo ""
    echo "Analysis:"
    echo "  clip-stats                   - Show statistics"
    echo "  clip-sprints                 - Show sprint days"
    echo "  clip-cross                   - Show cross-project connections"
    echo ""
    echo "Help:"
    echo "  clip-help                    - Show this help"
}

# Installation instructions
install-clip-helpers() {
    echo "To install these helpers, add this to your ~/.bashrc or ~/.zshrc:"
    echo ""
    echo "source /Users/steven/Documents/paste_export/organized_v2/search_helpers.sh"
    echo ""
    echo "Then run: source ~/.bashrc (or source ~/.zshrc)"
}

# If script is sourced, show help
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    echo "This script should be sourced, not executed directly."
    echo ""
    install-clip-helpers
else
    echo "Clipboard search helpers loaded! Type 'clip-help' for usage."
fi
