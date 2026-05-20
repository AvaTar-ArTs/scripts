#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail


# Noi AI Service Data Checker with Conversation Links
# This script checks each AI service in Noi for conversation data and displays conversation links

echo "🔍 Checking Noi AI Services for Conversation Data"
echo "==============================================="

# Define the Noi partitions directory
PARTITIONS_DIR="$HOME/Library/Application Support/Noi/Partitions/noi_main/IndexedDB"

# Array of AI services to check
services=(
  "https_chatgpt.com_0.indexeddb.leveldb:ChatGPT"
  "https_claude.ai_0.indexeddb.leveldb:Claude" 
  "https_grok.com_0.indexeddb.leveldb:Grok"
  "https_z.ai_0.indexeddb.leveldb:Z.ai"
  "https_www.perplexity.ai_0.indexeddb.leveldb:Perplexity"
  "https_chat.deepseek.com_0.indexeddb.leveldb:DeepSeek"
  "https_chat.qwen.ai_0.indexeddb.leveldb:Qwen"
)

# Check each service
for service_entry in "${services[@]}"; do
  dir="${service_entry%%:*}"
  name="${service_entry##*:}"
  
  echo ""
  echo "📋 Checking $name..."
  
  if [ -d "$PARTITIONS_DIR/$dir" ]; then
    # Get size of the directory
    size=$(du -sh "$PARTITIONS_DIR/$dir" | cut -f1)
    
    # Count .ldb and .log files (these contain the actual data)
    ldb_count=$(find "$PARTITIONS_DIR/$dir" -name "*.ldb" -type f | wc -l)
    log_count=$(find "$PARTITIONS_DIR/$dir" -name "*.log" -type f | wc -l)
    
    echo "   ✅ Directory exists"
    echo "   📦 Size: $size"
    echo "   🗃️  Data files: $ldb_count .ldb files, $log_count .log files"
    
    # Check modification time
    mod_time=$(stat -f "%Sm" -t "%Y-%m-%d %H:%M" "$PARTITIONS_DIR/$dir")
    echo "   🕒 Last modified: $mod_time"
    
  else
    echo "   ❌ Directory does not exist - service may not be used"
  fi
done

echo ""
echo "📊 Summary of Noi Database Sizes:"
echo "=================================="
# Show all database sizes for comparison
if [ -d "$PARTITIONS_DIR" ]; then
  echo ""
  ls -lh "$PARTITIONS_DIR" | grep -E "indexeddb|leveldb" | awk '{print $9, $5}'
fi

echo ""
echo "📋 Checking main Noi databases..."
MAIN_DB_DIR="$HOME/Library/Application Support/Noi/noi_user/database"
echo "History DB: $(du -sh "$MAIN_DB_DIR/history/history.db" 2>/dev/null || echo 'Not found')"
echo "Ask Log DB: $(du -sh "$MAIN_DB_DIR/ask_log/ask_log.db" 2>/dev/null || echo 'Not found')"
echo "Prompts DB: $(du -sh "$MAIN_DB_DIR/ask_prompts/prompts.db" 2>/dev/null || echo 'Not found')"

echo ""
echo "🔗 Conversation Links Found in History Database:"
echo "================================================"

# Function to display conversation links for a specific service
display_links() {
  local service_name=$1
  local search_term=$2
  local limit=${3:-5}  # Default to showing 5 links
  
  echo ""
  echo "📄 $service_name Conversations:"
  local count=$(sqlite3 "$MAIN_DB_DIR/history/history.db" "SELECT COUNT(*) FROM history WHERE url LIKE '%$search_term%';")
  echo "   Total: $count conversations"
  
  if [ "$count" -gt 0 ]; then
    # Get the most recent conversation links
    local links=$(sqlite3 "$MAIN_DB_DIR/history/history.db" \
      "SELECT url, title, datetime(last_visit_at/1000, 'unixepoch') AS last_visited FROM history WHERE url LIKE '%$search_term%' ORDER BY last_visit_at DESC LIMIT $limit;")
    
    if [ ! -z "$links" ]; then
      echo "   Recent conversation links:"
      echo "$links" | while IFS='|' read -r url title last_visited; do
        if [[ "$url" == *"c/"* ]]; then  # Check if it's a conversation URL
          echo "     🗨️  $title"
          echo "        $url"
          echo "        Last visited: $last_visited"
          echo ""
        fi
      done
    fi
  fi
}

# Display links for each service
display_links "Z.ai" "z.ai" 10
display_links "ChatGPT" "chatgpt" 5
display_links "Claude" "claude" 5
display_links "Grok" "grok" 5
display_links "Perplexity" "perplexity" 5
display_links "DeepSeek" "deepseek" 5
display_links "Qwen" "qwen" 5

echo ""
echo "💡 Tip: Copy and paste these URLs directly into your browser to access specific conversations."
echo ""
echo "✅ Noi data check complete!"
