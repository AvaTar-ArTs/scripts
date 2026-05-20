#!/bin/bash
set -euo pipefail

# Conversation History Fuzzy Finder
# This script provides a fuzzy search interface for all your conversation history files

echo "🔍 Conversation History Fuzzy Finder"
echo "====================================="
echo ""

# Define all conversation history locations
declare -A CONV_HISTORY=(
  ["Claude History"]="~/.claude/history.jsonl"
  ["Aider Chat"]="~/.aider.chat.history.md"
  ["Aider Input"]="~/.aider.input.history"
  ["Harbor Aider"]="~/.harbor/.aider.chat.history.md"
  ["ChatGPT Log"]="~/.chatgpt/ChatGPT.log"
  ["Codex History"]="~/.codex/history.json"
  ["Codex Line History"]="~/.codex/history.jsonl"
  ["Cursor Prompts"]="~/.cursor/prompt_history.json"
)

# Function to list all conversation sources
list_sources() {
  echo "Available conversation sources:"
  counter=1
  for key in "${!CONV_HISTORY[@]}"; do
    echo "$counter. $key (${CONV_HISTORY[$key]})"
    ((counter++))
  done
  echo ""
}

# Function to search in a specific file
search_in_file() {
  local file="$1"
  local query="$2"
  local expanded_file="${file/#\~/$HOME}"
  
  if [[ -f "$expanded_file" ]]; then
    echo "Searching for '$query' in $file:"
    echo "----------------------------------------"
    grep -i --color=always "$query" "$expanded_file" | head -20
    echo ""
  else
    echo "File not found: $file"
    echo ""
  fi
}

# Function to fuzzy search all files
fuzzy_search_all() {
  local query="$1"
  echo "Fuzzy searching for '$query' in all conversation histories:"
  echo "=========================================================="
  
  for key in "${!CONV_HISTORY[@]}"; do
    local file="${CONV_HISTORY[$key]}"
    local expanded_file="${file/#\~/$HOME}"
    
    if [[ -f "$expanded_file" ]]; then
      local count=$(grep -ic "$query" "$expanded_file" 2>/dev/null || echo 0)
      if [[ $count -gt 0 ]]; then
        echo "📄 $key ($file): $count matches"
        grep -i --color=always "$query" "$expanded_file" | head -5
        echo "---"
      fi
    fi
  done
}

# Function to open a file in a pager with search capability
browse_file() {
  local file_key="$1"
  local file_path="${CONV_HISTORY[$file_key]}"
  local expanded_path="${file_path/#\~/$HOME}"
  
  if [[ -f "$expanded_path" ]]; then
    echo "Opening $file_key in pager (Press / to search, q to quit): $file_path"
    less "$expanded_path"
  else
    echo "File not found: $file_path"
  fi
}

# Show help
show_help() {
  echo "Usage:"
  echo "  $0                            # Show this help"
  echo "  $0 list                       # List all conversation sources"
  echo "  $0 search [query]             # Fuzzy search all files for query"
  echo "  $0 browse [source_number]     # Browse a specific source"
  echo "  $0 preview [source_number]    # Preview a specific source"
  echo ""
  echo "Examples:"
  echo "  $0 search music               # Find all mentions of 'music'"
  echo "  $0 browse 1                   # Browse Claude history"
  echo "  $0 preview 3                  # Preview Aider input history"
  echo ""
}

# Main logic
case "$1" in
  "list")
    list_sources
    ;;
  "search")
    if [[ -z "$2" ]]; then
      echo "Please provide a search query"
      echo "Usage: $0 search [query]"
    else
      fuzzy_search_all "$2"
    fi
    ;;
  "browse")
    if [[ -z "$2" ]] || ! [[ "$2" =~ ^[0-9]+$ ]]; then
      echo "Please provide a valid source number"
      list_sources
    else
      counter=1
      for key in "${!CONV_HISTORY[@]}"; do
        if [[ $counter -eq $2 ]]; then
          browse_file "$key"
          break
        fi
        ((counter++))
      done
      if [[ $counter -ne $2 ]] && [[ $2 -lt $counter ]]; then
        echo "Invalid source number. Please choose from the list below:"
        list_sources
      fi
    fi
    ;;
  "preview")
    if [[ -z "$2" ]] || ! [[ "$2" =~ ^[0-9]+$ ]]; then
      echo "Please provide a valid source number"
      list_sources
    else
      counter=1
      for key in "${!CONV_HISTORY[@]}"; do
        if [[ $counter -eq $2 ]]; then
          local file="${CONV_HISTORY[$key]}"
          local expanded_file="${file/#\~/$HOME}"
          
          if [[ -f "$expanded_file" ]]; then
            echo "Preview of $key ($file):"
            echo "=================================="
            head -20 "$expanded_file"
            echo "..."
            echo "(Showing first 20 lines of $file)"
          else
            echo "File not found: $file"
          fi
          break
        fi
        ((counter++))
      done
      if [[ $counter -ne $2 ]] && [[ $2 -lt $counter ]]; then
        echo "Invalid source number. Please choose from the list below:"
        list_sources
      fi
    fi
    ;;
  *)
    show_help
    ;;
esac
