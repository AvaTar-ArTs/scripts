#!/bin/bash
# 🎯 **SIMPLE & INTUITIVE CONSOLIDATION**
# Just 3 folders that make sense to humans

set -e

echo "🎯 SIMPLE CONSOLIDATION"
echo "======================"
echo ""

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
PURPLE='\033[0;35m'
NC='\033[0m'

status() { echo -e "${GREEN}✅ $1${NC}"; }
warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
info() { echo -e "${BLUE}ℹ️  $1${NC}"; }
preview() { echo -e "${PURPLE}🔍 $1${NC}"; }

echo "Instead of 32 technical folders, just organize into:"
echo ""
echo "📁 ~/active/     ← Stuff you use regularly"
echo "📁 ~/tools/      ← All your scripts & utilities"
echo "📁 ~/archive/    ← Old stuff you don't touch"
echo ""

# Create simple structure
info "Creating simple 3-folder structure..."
mkdir -p ~/active ~/tools ~/archive

# Quick consolidation
info "Moving your stuff intuitively..."

# ACTIVE: Stuff you work with regularly
echo ""
info "📁 ~/active/ - Your regular workspace:"
echo "Moving AI research, current projects, active configs..."

if [ -d ~/workspace/ai_cli_research ]; then
    cp -r ~/workspace/ai_cli_research ~/active/ai-research/
    echo "  → AI research (4995 files)"
fi

if [ -d ~/pythons/projects ]; then
    cp -r ~/pythons/projects ~/active/projects/
    echo "  → Current projects (1884 files)"
fi

if [ -f ~/pythons/avatar_utils.py ]; then
    cp ~/pythons/avatar_utils.py ~/active/
    echo "  → Core utilities"
fi

# TOOLS: All scripts and automation
echo ""
info "📁 ~/tools/ - All your scripts & tools:"
echo "Moving Python scripts, automation, utilities..."

if [ -d ~/pythons ]; then
    cp -r ~/pythons ~/tools/python-scripts/
    echo "  → Python ecosystem (6134 files)"
fi

if [ -d ~/scripts ]; then
    cp -r ~/scripts ~/tools/shell-scripts/
    echo "  → Shell scripts (792 files)"
fi

if [ -d ~/.claude ]; then
    cp -r ~/.claude ~/tools/claude-config/
    echo "  → Claude config (11469 files)"
fi

if [ -d ~/.cursor ]; then
    cp -r ~/.cursor ~/tools/cursor-config/
    echo "  → Cursor config (24924 files)"
fi

if [ -d ~/.config/mcp ]; then
    cp -r ~/.config/mcp ~/tools/mcp-config/
    echo "  → MCP config (5 files)"
fi

# ARCHIVE: Old stuff
echo ""
info "📁 ~/archive/ - Old completed stuff:"
echo "Moving archives, backups, old projects..."

if [ -d ~/pythons/archives ]; then
    cp -r ~/pythons/archives ~/archive/old-archives/
    echo "  → Old archives (83 files)"
fi

# Count what we moved
echo ""
info "SUMMARY:"
active_count=$(find ~/active -type f 2>/dev/null | wc -l)
tools_count=$(find ~/tools -type f 2>/dev/null | wc -l)
archive_count=$(find ~/archive -type f 2>/dev/null | wc -l)

echo "📁 ~/active/: $active_count files (stuff you use)"
echo "📁 ~/tools/: $tools_count files (your scripts & configs)"
echo "📁 ~/archive/: $archive_count files (old stuff)"

echo ""
echo "🎯 RESULT:"
echo "Instead of hunting through 200+ scattered folders,"
echo "you now have just 3 intuitive folders:"
echo ""
echo "• ~/active/  ← Open this for current work"
echo "• ~/tools/   ← Open this for scripts & configs"
echo "• ~/archive/ ← Open this for old stuff"
echo ""

status "Simple consolidation complete!"
echo ""
echo "Want to make this permanent? Run:"
echo "  rm -rf ~/pythons ~/workspace/ai_cli_research ~/.claude ~/.cursor"
echo ""
echo "Or keep both - the simple folders are now ready to use! 🎉"