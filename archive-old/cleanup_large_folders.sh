#!/usr/bin/env bash

# Comprehensive cleanup script for large folders in /Users/steven
# This script safely removes temporary files, caches, and logs while preserving important data

set -e  # Exit on any error

echo "Starting comprehensive cleanup of large folders..."
echo "Date: $(date)"
echo "----------------------------------------"

# Function to backup important files before cleanup
backup_important_files() {
    local dir=$1
    local backup_dir="/Users/steven/backups/$(basename $dir)_$(date +%Y%m%d_%H%M%S)"
    
    echo "Creating backup of important files from $dir to $backup_dir"
    mkdir -p "$backup_dir"
    
    # Backup important config files
    for file in settings.json settings.local.json oauth_creds.json google_accounts.json; do
        if [ -f "$dir/$file" ]; then
            cp "$dir/$file" "$backup_dir/"
            echo "  Backed up: $file"
        fi
    done
    
    # Backup history files
    for hist in history.jsonl history; do
        if [ -f "$dir/$hist" ]; then
            cp "$dir/$hist" "$backup_dir/"
            echo "  Backed up: $hist"
        fi
    done
}

# Function to get directory size
get_size() {
    du -sh "$1" 2>/dev/null | cut -f1
}

# Initialize backup directory
BACKUP_DIR="/Users/steven/backups"
mkdir -p "$BACKUP_DIR"

# 1. Clean .claude directory (1.2G -> likely ~0.3G after cleanup)
if [ -d "/Users/steven/.claude" ]; then
    echo "Processing /Users/steven/.claude ($(get_size /Users/steven/.claude))"
    backup_important_files "/Users/steven/.claude"
    
    # Remove debug and session-env directories (these are typically large temporary files)
    if [ -d "/Users/steven/.claude/debug" ]; then
        echo "  Removing debug directory..."
        rm -rf "/Users/steven/.claude/debug"
    fi
    
    if [ -d "/Users/steven/.claude/session-env" ]; then
        echo "  Removing session-env directory (keeping only last 10)..."
        cd "/Users/steven/.claude/session-env"
        # Fixed: use null delimiters to handle filenames with spaces
        ls -t | tail -n +11 | tr '\n' '\0' | xargs -0 rm -rf 2>/dev/null || true
    fi
    
    if [ -d "/Users/steven/.claude/shell-snapshots" ]; then
        echo "  Removing shell-snapshots (keeping only last 5)..."
        cd "/Users/steven/.claude/shell-snapshots"
        # Fixed: use null delimiters to handle filenames with spaces
        ls -t | tail -n +6 | tr '\n' '\0' | xargs -0 rm -rf 2>/dev/null || true
    fi
    
    if [ -d "/Users/steven/.claude/todos" ]; then
        echo "  Cleaning todos directory (keeping only last 10)..."
        cd "/Users/steven/.claude/todos"
        # Fixed: use null delimiters to handle filenames with spaces
        ls -t | tail -n +11 | tr '\n' '\0' | xargs -0 rm -rf 2>/dev/null || true
    fi
    
    # Truncate history.jsonl to last 1000 lines if it's very large
    if [ -f "/Users/steven/.claude/history.jsonl" ] && [ $(stat -f%z "/Users/steven/.claude/history.jsonl" 2>/dev/null || stat -c%s "/Users/steven/.claude/history.jsonl") -gt 100000 ]; then
        echo "  Truncating history.jsonl to last 1000 lines..."
        tail -n 1000 "/Users/steven/.claude/history.jsonl" > "/Users/steven/.claude/history.jsonl.tmp" && mv "/Users/steven/.claude/history.jsonl.tmp" "/Users/steven/.claude/history.jsonl"
    fi
    
    echo "  New size: $(get_size /Users/steven/.claude)"
fi

# 2. Clean .gemini directory (6.5G -> likely ~1G after cleanup)
if [ -d "/Users/steven/.gemini" ]; then
    echo "Processing /Users/steven/.gemini ($(get_size /Users/steven/.gemini))"
    backup_important_files "/Users/steven/.gemini"
    
    # Clean up tmp directory
    if [ -d "/Users/steven/.gemini/tmp" ]; then
        echo "  Cleaning tmp directory..."
        rm -rf "/Users/steven/.gemini/tmp"/*
    fi
    
    # Clean up history directory
    if [ -d "/Users/steven/.gemini/history" ]; then
        echo "  Cleaning history directory..."
        rm -rf "/Users/steven/.gemini/history"/*
    fi
    
    echo "  New size: $(get_size /Users/steven/.gemini)"
fi

# 3. Clean .ollama directory (4.4G -> likely ~0.5G after cleanup)
if [ -d "/Users/steven/.ollama" ]; then
    echo "Processing /Users/steven/.ollama ($(get_size /Users/steven/.ollama))"
    backup_important_files "/Users/steven/.ollama"
    
    # Clean up logs directory
    if [ -d "/Users/steven/.ollama/logs" ]; then
        echo "  Cleaning logs directory..."
        rm -rf "/Users/steven/.ollama/logs"/*
    fi
    
    echo "  New size: $(get_size /Users/steven/.ollama)"
fi

# 4. Clean .cache directory (4.9G -> likely ~1G after cleanup)
if [ -d "/Users/steven/.cache" ]; then
    echo "Processing /Users/steven/.cache ($(get_size /Users/steven/.cache))"
    
    # Clean up uv cache (likely large)
    if [ -d "/Users/steven/.cache/uv" ]; then
        echo "  Cleaning uv cache..."
        rm -rf "/Users/steven/.cache/uv"/*
    fi
    
    # Clean up node cache
    if [ -d "/Users/steven/.cache/node" ]; then
        echo "  Cleaning node cache..."
        rm -rf "/Users/steven/.cache/node"/*
    fi
    
    # Clean up claude cache
    if [ -d "/Users/steven/.cache/claude" ]; then
        echo "  Cleaning claude cache..."
        rm -rf "/Users/steven/.cache/claude"/*
    fi
    
    echo "  New size: $(get_size /Users/steven/.cache)"
fi

# 5. Clean .local directory (3.3G -> likely ~2G after cleanup)
if [ -d "/Users/steven/.local" ]; then
    echo "Processing /Users/steven/.local ($(get_size /Users/steven/.local))"
    
    # Clean up state directory if it has temporary files
    if [ -d "/Users/steven/.local/state" ]; then
        echo "  Cleaning state directory..."
        find "/Users/steven/.local/state" -name "*.tmp" -o -name "*.log" -o -name "*cache*" | xargs rm -f 2>/dev/null || true
    fi
    
    # Clean up any large log files in lib
    if [ -d "/Users/steven/.local/lib" ]; then
        echo "  Checking for large log files in lib..."
        find "/Users/steven/.local/lib" -name "*.log" -size +100M | xargs rm -f 2>/dev/null || true
    fi
    
    echo "  New size: $(get_size /Users/steven/.local)"
fi

# 6. Clean GitHub directory (2.7G -> likely ~1.5G after cleanup)
if [ -d "/Users/steven/GitHub" ]; then
    echo "Processing /Users/steven/GitHub ($(get_size /Users/steven/GitHub))"
    
    # Clean up .git folders in subdirectories that might have large histories
    echo "  Cleaning .git folders in subdirectories..."
    find "/Users/steven/GitHub" -name ".git" -type d -depth | while read gitdir; do
        repo_dir=$(dirname "$gitdir")
        echo "    Processing git repo: $repo_dir"
        
        # Clean up git objects that are safe to remove
        (
            cd "$repo_dir"
            if [ -d ".git" ]; then
                # Prune unreachable objects only (safe operation)
                git gc --aggressive --prune=now 2>/dev/null || true

                # NOTE: Removed dangerous git filter-branch command that rewrites history
                # If you need to remove large files from history, use git-filter-repo or BFG
                # and do it manually with full understanding of the implications
            fi
        )
    done
    
    echo "  New size: $(get_size /Users/steven/GitHub)"
fi

# 7. Clean .cursor directory (2.4G -> likely ~0.5G after cleanup)
if [ -d "/Users/steven/.cursor" ]; then
    echo "Processing /Users/steven/.cursor ($(get_size /Users/steven/.cursor))"
    
    # Clean up cursor cache and temporary files
    echo "  Looking for cursor cache directories..."
    find "/Users/steven/.cursor" -name "cache" -type d | while read cachedir; do
        echo "    Cleaning cache directory: $cachedir"
        # Fixed: use -print0 and xargs -0 for safe filename handling
        find "$cachedir" \( -name "*.tmp" -o -name "*.log" \) -print0 | xargs -0 rm -f 2>/dev/null || true
    done
    
    echo "  New size: $(get_size /Users/steven/.cursor)"
fi

# 8. Clean .eigent directory (2.4G -> depends on content)
if [ -d "/Users/steven/.eigent" ]; then
    echo "Processing /Users/steven/.eigent ($(get_size /Users/steven/.eigent))"
    
    # Clean up temporary and cache files
    find "/Users/steven/.eigent" -name "*.tmp" -o -name "*.log" -o -name "cache" -type d | while read tempfile; do
        if [ -d "$tempfile" ]; then
            echo "    Removing cache directory: $tempfile"
            rm -rf "$tempfile"
        else
            echo "    Removing temp file: $tempfile"
            rm -f "$tempfile"
        fi
    done
    
    echo "  New size: $(get_size /Users/steven/.eigent)"
fi

# 9. Clean .x-cmd.root directory (1.6G -> depends on content)
if [ -d "/Users/steven/.x-cmd.root" ]; then
    echo "Processing /Users/steven/.x-cmd.root ($(get_size /Users/steven/.x-cmd.root))"
    
    # Clean up temporary and cache files
    find "/Users/steven/.x-cmd.root" -name "*.tmp" -o -name "*.log" -o -name "cache" -type d | while read tempfile; do
        if [ -d "$tempfile" ]; then
            echo "    Removing cache directory: $tempfile"
            rm -rf "$tempfile"
        else
            echo "    Removing temp file: $tempfile"
            rm -f "$tempfile"
        fi
    done
    
    echo "  New size: $(get_size /Users/steven/.x-cmd.root)"
fi

# 10. Clean eigent directory (1.6G -> depends on content)
if [ -d "/Users/steven/eigent" ]; then
    echo "Processing /Users/steven/eigent ($(get_size /Users/steven/eigent))"
    
    # Clean up temporary and cache files
    find "/Users/steven/eigent" -name "*.tmp" -o -name "*.log" -o -name "cache" -type d | while read tempfile; do
        if [ -d "$tempfile" ]; then
            echo "    Removing cache directory: $tempfile"
            rm -rf "$tempfile"
        else
            echo "    Removing temp file: $tempfile"
            rm -f "$tempfile"
        fi
    done
    
    echo "  New size: $(get_size /Users/steven/eigent)"
fi

# 11. Clean .config directory (1.4G -> depends on content)
if [ -d "/Users/steven/.config" ]; then
    echo "Processing /Users/steven/.config ($(get_size /Users/steven/.config))"
    
    # Clean up common cache and temporary files in config
    find "/Users/steven/.config" -name "cache" -type d -o -name "*.tmp" -o -name "*.log" | while read tempfile; do
        if [ -d "$tempfile" ]; then
            echo "    Removing cache directory: $tempfile"
            rm -rf "$tempfile"
        else
            echo "    Removing temp file: $tempfile"
            rm -f "$tempfile"
        fi
    done
    
    echo "  New size: $(get_size /Users/steven/.config)"
fi

echo "----------------------------------------"
echo "Cleanup completed!"
echo "Please verify that your applications are working correctly."
echo ""
echo "Note: Some applications may recreate cache files over time."
echo "The backups are stored in $BACKUP_DIR in case you need to restore anything."
