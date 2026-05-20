#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail


echo "🧹 EXECUTING HOME DIRECTORY CLEANUP"
echo "========================================================================"
echo ""

# Function to show size
show_size() {
    if [ -e "$1" ]; then
        du -sh "$1" 2>/dev/null | cut -f1 || echo "0"
    else
        echo "0"
    fi
}

# Function to calculate directory size in MB
size_in_mb() {
    if [ -e "$1" ]; then
        du -sm "$1" 2>/dev/null | cut -f1 || echo "0"
    else
        echo "0"
    fi
}

cd ~

echo "📊 BEFORE CLEANUP:"
echo "----------------------------------------------------------------------"
before_npm=$(size_in_mb ~/.npm)
before_local=$(size_in_mb ~/.local)
before_nvm=$(size_in_mb ~/.nvm)
before_xcmd=$(size_in_mb ~/.x-cmd.root)
before_gemini=$(size_in_mb ~/.gemini)
before_qwen=$(size_in_mb ~/.qwen)
before_trash=$(size_in_mb ~/.Trash)
before_vscode=$(size_in_mb ~/.vscode)
before_cursor=$(size_in_mb ~/.cursor)
before_claude=$(size_in_mb ~/.claude)
before_bun=$(size_in_mb ~/.bun)

echo "  .npm:          $(show_size ~/.npm)"
echo "  .local:        $(show_size ~/.local)"
echo "  .nvm:          $(show_size ~/.nvm)"
echo "  .x-cmd.root:   $(show_size ~/.x-cmd.root)"
echo "  .gemini:       $(show_size ~/.gemini)"
echo "  .qwen:         $(show_size ~/.qwen)"
echo "  .Trash:        $(show_size ~/.Trash)"
echo "  .vscode:       $(show_size ~/.vscode)"
echo "  .cursor:       $(show_size ~/.cursor)"
echo "  .claude:       $(show_size ~/.claude)"
echo "  .bun:          $(show_size ~/.bun)"
echo ""

# Calculate total before
total_before=$((before_npm + before_local + before_nvm + before_xcmd + before_gemini + before_qwen + before_trash + before_vscode + before_cursor + before_claude + before_bun))

echo "========================================================================"
echo "STARTING CLEANUP..."
echo "========================================================================"
echo ""

# 1. .npm cache (FULL DELETE - 1.7 GB)
echo "1️⃣  Cleaning .npm cache (1.7 GB)..."
if command -v npm &> /dev/null; then
    npm cache clean --force 2>/dev/null
fi
rm -rf ~/.npm 2>/dev/null
echo "   ✅ .npm cache deleted"
echo ""

# 2. .local caches (PARTIAL - 2-3 GB)
echo "2️⃣  Cleaning .local caches (2-3 GB)..."
rm -rf ~/.local/share/Trash/* 2>/dev/null
echo "   ✅ Cleared .local/share/Trash"
rm -rf ~/.local/share/virtualenvs/* 2>/dev/null
echo "   ✅ Cleared old virtualenvs"
rm -rf ~/.local/share/jupyter/runtime/* 2>/dev/null
echo "   ✅ Cleared Jupyter runtime"
rm -rf ~/.local/share/jupyter/lab/workspaces/* 2>/dev/null
echo "   ✅ Cleared Jupyter workspaces"
rm -rf ~/.local/pipx/cache/* 2>/dev/null
echo "   ✅ Cleared pipx cache"
echo ""

# 3. .nvm (PARTIAL - list versions first)
echo "3️⃣  Checking .nvm versions (0.5-1 GB)..."
if [ -d ~/.nvm ]; then
    echo "   Node versions installed:"
    ls ~/.nvm/versions/node 2>/dev/null | head -10
    echo "   ⚠️  Keeping all versions (run 'nvm uninstall <version>' manually if needed)"
fi
echo ""

# 4. .x-cmd.root cache (FULL DELETE - 800 MB)
echo "4️⃣  Cleaning .x-cmd.root cache (800 MB)..."
rm -rf ~/.x-cmd.root/cache 2>/dev/null
echo "   ✅ Cleared cache"
rm -rf ~/.x-cmd.root/log 2>/dev/null
echo "   ✅ Cleared logs"
rm -rf ~/.x-cmd.root/tmp 2>/dev/null
echo "   ✅ Cleared tmp"
echo ""

# 5. .gemini AI cache (FULL DELETE - 300 MB)
echo "5️⃣  Cleaning .gemini AI cache (300 MB)..."
rm -rf ~/.gemini/cache 2>/dev/null
echo "   ✅ Cleared cache"
rm -rf ~/.gemini/history 2>/dev/null
echo "   ✅ Cleared history"
rm -rf ~/.gemini/logs 2>/dev/null
echo "   ✅ Cleared logs"
echo ""

# 6. .qwen AI cache (FULL DELETE - 200 MB)
echo "6️⃣  Cleaning .qwen AI cache (200 MB)..."
rm -rf ~/.qwen/cache 2>/dev/null
echo "   ✅ Cleared cache"
rm -rf ~/.qwen/logs 2>/dev/null
echo "   ✅ Cleared logs"
echo ""

# 7. .Trash (EMPTY - 260 MB)
echo "7️⃣  Emptying .Trash (260 MB)..."
rm -rf ~/.Trash/* 2>/dev/null
echo "   ✅ Trash emptied"
echo ""

# 8. .vscode caches (PARTIAL - 500 MB)
echo "8️⃣  Cleaning .vscode caches (500 MB)..."
rm -rf ~/.vscode/Cache/* 2>/dev/null
echo "   ✅ Cleared Cache"
rm -rf ~/.vscode/CachedData/* 2>/dev/null
echo "   ✅ Cleared CachedData"
rm -rf ~/.vscode/logs/* 2>/dev/null
echo "   ✅ Cleared logs"
rm -rf ~/.vscode/CachedExtensions/* 2>/dev/null
echo "   ✅ Cleared CachedExtensions"
echo ""

# 9. .cursor caches (PARTIAL - 300 MB)
echo "9️⃣  Cleaning .cursor caches (300 MB)..."
rm -rf ~/.cursor/Cache/* 2>/dev/null
echo "   ✅ Cleared Cache"
rm -rf ~/.cursor/CachedData/* 2>/dev/null
echo "   ✅ Cleared CachedData"
rm -rf ~/.cursor/logs/* 2>/dev/null
echo "   ✅ Cleared logs"
rm -rf ~/.cursor/CachedExtensions/* 2>/dev/null
echo "   ✅ Cleared CachedExtensions"
echo ""

# 10. .claude sessions (PARTIAL - 50 MB)
echo "🔟 Cleaning .claude sessions (50 MB)..."
rm -rf ~/.claude/sessions 2>/dev/null
echo "   ✅ Cleared sessions"
rm -rf ~/.claude/cache 2>/dev/null
echo "   ✅ Cleared cache"
rm -rf ~/.claude/logs 2>/dev/null
echo "   ✅ Cleared logs"
echo ""

# 11. .bun cache (FULL DELETE - 100 MB)
echo "1️⃣1️⃣  Cleaning .bun cache (100 MB)..."
rm -rf ~/.bun/install/cache 2>/dev/null
echo "   ✅ Cleared install cache"
echo ""

# Bonus: Other common caches
echo "➕ BONUS: Cleaning other common caches..."
rm -rf ~/.ruff_cache 2>/dev/null
echo "   ✅ Cleared ruff cache"
rm -rf ~/.pytest_cache 2>/dev/null
echo "   ✅ Cleared pytest cache"
rm -rf ~/.mypy_cache 2>/dev/null
echo "   ✅ Cleared mypy cache"
echo ""

echo "========================================================================"
echo "CLEANUP COMPLETE!"
echo "========================================================================"
echo ""

# Calculate after
after_npm=$(size_in_mb ~/.npm)
after_local=$(size_in_mb ~/.local)
after_nvm=$(size_in_mb ~/.nvm)
after_xcmd=$(size_in_mb ~/.x-cmd.root)
after_gemini=$(size_in_mb ~/.gemini)
after_qwen=$(size_in_mb ~/.qwen)
after_trash=$(size_in_mb ~/.Trash)
after_vscode=$(size_in_mb ~/.vscode)
after_cursor=$(size_in_mb ~/.cursor)
after_claude=$(size_in_mb ~/.claude)
after_bun=$(size_in_mb ~/.bun)

echo "📊 AFTER CLEANUP:"
echo "----------------------------------------------------------------------"
echo "  .npm:          $(show_size ~/.npm)"
echo "  .local:        $(show_size ~/.local)"
echo "  .nvm:          $(show_size ~/.nvm)"
echo "  .x-cmd.root:   $(show_size ~/.x-cmd.root)"
echo "  .gemini:       $(show_size ~/.gemini)"
echo "  .qwen:         $(show_size ~/.qwen)"
echo "  .Trash:        $(show_size ~/.Trash)"
echo "  .vscode:       $(show_size ~/.vscode)"
echo "  .cursor:       $(show_size ~/.cursor)"
echo "  .claude:       $(show_size ~/.claude)"
echo "  .bun:          $(show_size ~/.bun)"
echo ""

# Calculate total after and savings
total_after=$((after_npm + after_local + after_nvm + after_xcmd + after_gemini + after_qwen + after_trash + after_vscode + after_cursor + after_claude + after_bun))
saved=$((total_before - total_after))

echo "========================================================================"
echo "💾 DISK SPACE SAVED: ${saved} MB (~$(echo "scale=2; $saved/1024" | bc) GB)"
echo "========================================================================"
echo ""

echo "✅ ALL CLEANUP TASKS COMPLETED!"
echo ""
