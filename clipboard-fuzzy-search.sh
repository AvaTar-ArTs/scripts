#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail

# Clipboard Fuzzy Search
# Interactive fuzzy search through your organized clipboard history

CLIP_BASE="$HOME/Documents/paste_export/organized_merged"
CLIP_EXPORT="$HOME/Documents/paste_export"

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if bat is available for syntax highlighting
if command -v bat &> /dev/null; then
    PREVIEW_CMD="bat --style=numbers --color=always"
elif command -v batcat &> /dev/null; then
    PREVIEW_CMD="batcat --style=numbers --color=always"
else
    PREVIEW_CMD="head -100"
fi

# Main fuzzy file search
clip-fzf() {
    echo -e "${BLUE}🔍 Fuzzy File Search${NC}"
    echo "Type to search filenames, Enter to view, Ctrl-C to exit"
    echo ""

    selected=$(find "$CLIP_BASE" -type f \
        \( -name "*.txt" -o -name "*.py" -o -name "*.js" -o -name "*.sh" -o -name "*.md" -o -name "*.json" \) \
        2>/dev/null | fzf \
        --height=80% \
        --preview="$PREVIEW_CMD {}" \
        --preview-window=right:60%:wrap \
        --header="📁 Search clipboard files | Enter=View | Ctrl-Y=Copy | Ctrl-O=Open" \
        --bind="ctrl-y:execute-silent(cat {} | pbcopy)+abort" \
        --bind="ctrl-o:execute($EDITOR {})" \
        --border \
        --prompt="Files > ")

    if [ -n "$selected" ]; then
        echo -e "${GREEN}Selected:${NC} $selected"
        echo ""
        echo -e "${YELLOW}Content:${NC}"
        $PREVIEW_CMD "$selected"
    fi
}

# Content search - search through file contents
clip-fzf-content() {
    echo -e "${BLUE}🔍 Fuzzy Content Search${NC}"
    echo "Type to search file contents, Enter to view file"
    echo ""

    # Use ripgrep to search contents, then fzf to filter
    rg --line-number --no-heading --color=always --smart-case "" "$CLIP_BASE" 2>/dev/null | \
    fzf --ansi \
        --height=80% \
        --delimiter=: \
        --preview="$PREVIEW_CMD {1}" \
        --preview-window=right:60%:wrap:+{2}-/2 \
        --header="🔎 Search content | Enter=View file | Ctrl-Y=Copy line | Ctrl-O=Open file" \
        --bind="ctrl-y:execute-silent(echo {3..} | pbcopy)+abort" \
        --bind="ctrl-o:execute($EDITOR {1})" \
        --border \
        --prompt="Content > " | \
    awk -F: '{print $1}' | while read -r file; do
        if [ -n "$file" ]; then
            echo -e "${GREEN}File:${NC} $file"
            echo ""
            $PREVIEW_CMD "$file"
        fi
    done
}

# Quick category browser
clip-fzf-category() {
    echo -e "${BLUE}📂 Browse by Category${NC}"
    echo ""

    # List all directories as categories
    category=$(find "$CLIP_BASE" -type d -mindepth 1 -maxdepth 3 2>/dev/null | \
        sed "s|$CLIP_BASE/||" | \
        fzf \
        --height=50% \
        --header="📂 Select category to explore" \
        --border \
        --prompt="Category > ")

    if [ -n "$category" ]; then
        echo -e "${GREEN}Exploring:${NC} $category"
        echo ""

        # Now search within that category
        clip-fzf-in-path "$CLIP_BASE/$category"
    fi
}

# Search within a specific path
clip-fzf-in-path() {
    local search_path="$1"

    selected=$(find "$search_path" -type f \
        \( -name "*.txt" -o -name "*.py" -o -name "*.js" -o -name "*.sh" -o -name "*.md" -o -name "*.json" \) \
        2>/dev/null | fzf \
        --height=80% \
        --preview="$PREVIEW_CMD {}" \
        --preview-window=right:60%:wrap \
        --header="📁 Files in $(basename $search_path) | Enter=View | Ctrl-Y=Copy | Ctrl-O=Open" \
        --bind="ctrl-y:execute-silent(cat {} | pbcopy)+abort" \
        --bind="ctrl-o:execute($EDITOR {})" \
        --border \
        --prompt="Files > ")

    if [ -n "$selected" ]; then
        echo -e "${GREEN}Selected:${NC} $selected"
        echo ""
        $PREVIEW_CMD "$selected"
    fi
}

# Search JSON export directly
clip-fzf-json() {
    echo -e "${BLUE}🔍 Search JSON Export${NC}"
    echo "Searching text_items.json..."
    echo ""

    # Search through the JSON export with jq
    if [ -f "$CLIP_EXPORT/text_items.json" ]; then
        cat "$CLIP_EXPORT/text_items.json" | \
        jq -r '.[] | "\(.created) | \(.text | tostring | .[0:200])"' | \
        fzf \
            --height=80% \
            --multi \
            --header="🗓️  Search clipboard history | Enter=View | Ctrl-Y=Copy text" \
            --delimiter='|' \
            --preview='echo {2..} | fold -w 80' \
            --preview-window=right:60%:wrap \
            --bind="ctrl-y:execute-silent(echo {2..} | pbcopy)+abort" \
            --border \
            --prompt="Clipboard > " | \
        while IFS='|' read -r date text; do
            echo -e "${GREEN}Date:${NC} $date"
            echo -e "${YELLOW}Content:${NC}"
            echo "$text"
        done
    else
        echo "❌ text_items.json not found"
    fi
}

# Recent files search (last modified)
clip-fzf-recent() {
    echo -e "${BLUE}🕐 Recent Files${NC}"
    echo ""

    find "$CLIP_BASE" -type f \
        \( -name "*.txt" -o -name "*.py" -o -name "*.js" -o -name "*.sh" -o -name "*.md" -o -name "*.json" \) \
        -mtime -30 2>/dev/null | \
    xargs ls -lt | \
    awk '{print $9}' | \
    fzf \
        --height=80% \
        --preview="$PREVIEW_CMD {}" \
        --preview-window=right:60%:wrap \
        --header="🕐 Files modified in last 30 days | Enter=View | Ctrl-Y=Copy" \
        --bind="ctrl-y:execute-silent(cat {} | pbcopy)+abort" \
        --bind="ctrl-o:execute($EDITOR {})" \
        --border \
        --prompt="Recent > " | \
    while read -r file; do
        if [ -n "$file" ]; then
            echo -e "${GREEN}File:${NC} $file"
            echo ""
            $PREVIEW_CMD "$file"
        fi
    done
}

# Python code search
clip-fzf-python() {
    echo -e "${BLUE}🐍 Python Code Search${NC}"
    echo ""

    find "$CLIP_BASE" -type f -name "*.py" 2>/dev/null | \
    fzf \
        --height=80% \
        --preview="$PREVIEW_CMD {}" \
        --preview-window=right:60%:wrap \
        --header="🐍 Python files | Enter=View | Ctrl-Y=Copy" \
        --bind="ctrl-y:execute-silent(cat {} | pbcopy)+abort" \
        --bind="ctrl-o:execute($EDITOR {})" \
        --border \
        --prompt="Python > " | \
    while read -r file; do
        if [ -n "$file" ]; then
            echo -e "${GREEN}File:${NC} $file"
            echo ""
            $PREVIEW_CMD "$file"
        fi
    done
}

# Interactive menu
clip-fzf-menu() {
    echo -e "${BLUE}╔═══════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║  Clipboard Fuzzy Search Menu         ║${NC}"
    echo -e "${BLUE}╚═══════════════════════════════════════╝${NC}"
    echo ""
    echo "1) Search files by name"
    echo "2) Search by content"
    echo "3) Browse by category"
    echo "4) Search JSON export"
    echo "5) Recent files (30 days)"
    echo "6) Python code search"
    echo "7) Exit"
    echo ""
    read -p "Select option (1-7): " choice

    case $choice in
        1) clip-fzf ;;
        2) clip-fzf-content ;;
        3) clip-fzf-category ;;
        4) clip-fzf-json ;;
        5) clip-fzf-recent ;;
        6) clip-fzf-python ;;
        7) exit 0 ;;
        *) echo "Invalid option" ;;
    esac
}

# Show help
clip-fzf-help() {
    cat << 'EOF'
Clipboard Fuzzy Search Commands:

  clip-fzf                 - Fuzzy search files by name
  clip-fzf-content         - Search through file contents
  clip-fzf-category        - Browse by category
  clip-fzf-json            - Search JSON export directly
  clip-fzf-recent          - Show recent files (30 days)
  clip-fzf-python          - Search Python files only
  clip-fzf-menu            - Interactive menu
  clip-fzf-help            - Show this help

Keyboard shortcuts in fzf:
  Enter         - View selected file
  Ctrl-Y        - Copy content to clipboard
  Ctrl-O        - Open in $EDITOR
  Ctrl-C / Esc  - Exit
  Tab           - Select multiple (where available)

Examples:
  clip-fzf                 # Search all files
  clip-fzf-content         # Search for text within files
  clip-fzf-category        # Browse by project/category

To add to your shell:
  source ~/Documents/paste_export/clipboard_fuzzy_search.sh
EOF
}

# If run directly, show menu
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    clip-fzf-menu
else
    echo "Clipboard fuzzy search loaded! Type 'clip-fzf-help' for commands."
fi
