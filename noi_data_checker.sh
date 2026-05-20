#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail


# Noi AI Service Data Checker
# This script checks each AI service in Noi for conversation data

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
    
    # Check for recent activity by looking at the most recent file
    recent_file=$(find "$PARTITIONS_DIR/$dir" -type f -exec stat -f "%m:%N" {} \; | sort -nr | head -1 | cut -d: -f2-)
    if [ ! -z "$recent_file" ]; then
      recent_mod_time=$(stat -f "%Sm" -t "%Y-%m-%d %H:%M" "$recent_file")
      echo "   ⏰ Most recent activity: $recent_mod_time"
    fi
    
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
echo "🔍 Checking for specific conversation history in history database..."
echo "Z.ai conversations found: $(sqlite3 "$MAIN_DB_DIR/history/history.db" "SELECT COUNT(*) FROM history WHERE url LIKE '%z.ai%';")"
echo "ChatGPT conversations found: $(sqlite3 "$MAIN_DB_DIR/history/history.db" "SELECT COUNT(*) FROM history WHERE url LIKE '%chatgpt%';")"
echo "Claude conversations found: $(sqlite3 "$MAIN_DB_DIR/history/history.db" "SELECT COUNT(*) FROM history WHERE url LIKE '%claude%';")"
echo "Grok conversations found: $(sqlite3 "$MAIN_DB_DIR/history/history.db" "SELECT COUNT(*) FROM history WHERE url LIKE '%grok%';")"
echo "Perplexity conversations found: $(sqlite3 "$MAIN_DB_DIR/history/history.db" "SELECT COUNT(*) FROM history WHERE url LIKE '%perplexity%';")"

echo ""
echo "✅ Noi data check complete!"
