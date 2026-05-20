#!/usr/bin/env bash
# Cleanup script for .local/lib, .local/share/claude, and .local/share/cursor-agent
# Safely removes old versions and unused packages

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

LOCAL_LIB="/Users/steven/.local/lib"
CLAUDE_DIR="/Users/steven/.local/share/claude"
CURSOR_AGENT_DIR="/Users/steven/.local/share/cursor-agent"

DRY_RUN=true
CLEAN_CLAUDE=false
CLEAN_CURSOR=false
CLEAN_PYTHON=false

print_header() {
    echo -e "${CYAN}========================================${NC}"
    echo -e "  🧹 ${BLUE}Local Directories Cleanup${NC}"
    echo -e "${CYAN}========================================${NC}"
    echo ""
}

show_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --execute          Actually perform deletions (default: dry-run)"
    echo "  --claude           Clean old Claude versions"
    echo "  --cursor           Clean old Cursor Agent versions"
    echo "  --python           Analyze Python packages (interactive)"
    echo "  --all              Clean all (Claude + Cursor)"
    echo "  --help             Show this help"
    echo ""
    echo "Examples:"
    echo "  $0 --all --execute    # Clean everything (actually delete)"
    echo "  $0 --claude            # Preview Claude cleanup (dry-run)"
}

clean_claude_versions() {
    echo -e "${BLUE}🤖 Cleaning Claude Versions${NC}"
    echo -e "${CYAN}────────────────────────────────────────${NC}"
    
    if [ ! -d "$CLAUDE_DIR/versions" ]; then
        echo -e "${RED}❌ Directory not found${NC}"
        return
    fi
    
    versions=($(ls -1t "$CLAUDE_DIR/versions" 2>/dev/null))
    if [ ${#versions[@]} -le 1 ]; then
        echo -e "${GREEN}✓ Only one version found, nothing to clean${NC}"
        return
    fi
    
    latest="${versions[0]}"
    old_versions=("${versions[@]:1}")
    
    echo -e "Keeping latest: ${GREEN}$latest${NC}"
    echo -e "Removing old versions:"
    
    total_saved=0
    for ver in "${old_versions[@]}"; do
        size=$(du -sh "$CLAUDE_DIR/versions/$ver" 2>/dev/null | cut -f1)
        size_bytes=$(du -sk "$CLAUDE_DIR/versions/$ver" 2>/dev/null | cut -f1)
        total_saved=$((total_saved + size_bytes))
        
        if [ "$DRY_RUN" = true ]; then
            echo -e "  ${YELLOW}[DRY-RUN]${NC} Would remove: $ver (${YELLOW}$size${NC})"
        else
            echo -e "  ${RED}Removing${NC}: $ver (${YELLOW}$size${NC})"
            rm -rf "$CLAUDE_DIR/versions/$ver"
        fi
    done
    
    saved_mb=$((total_saved / 1024))
    echo -e "\n${GREEN}✓${NC} Total space saved: ${YELLOW}~${saved_mb}MB${NC}"
    echo ""
}

clean_cursor_agent_versions() {
    echo -e "${BLUE}🖱️  Cleaning Cursor Agent Versions${NC}"
    echo -e "${CYAN}────────────────────────────────────────${NC}"
    
    if [ ! -d "$CURSOR_AGENT_DIR/versions" ]; then
        echo -e "${RED}❌ Directory not found${NC}"
        return
    fi
    
    versions=($(ls -1t "$CURSOR_AGENT_DIR/versions" 2>/dev/null))
    if [ ${#versions[@]} -le 1 ]; then
        echo -e "${GREEN}✓ Only one version found, nothing to clean${NC}"
        return
    fi
    
    latest="${versions[0]}"
    old_versions=("${versions[@]:1}")
    
    echo -e "Keeping latest: ${GREEN}$latest${NC}"
    echo -e "Removing old versions:"
    
    total_saved=0
    for ver in "${old_versions[@]}"; do
        size=$(du -sh "$CURSOR_AGENT_DIR/versions/$ver" 2>/dev/null | cut -f1)
        size_bytes=$(du -sk "$CURSOR_AGENT_DIR/versions/$ver" 2>/dev/null | cut -f1)
        total_saved=$((total_saved + size_bytes))
        
        if [ "$DRY_RUN" = true ]; then
            echo -e "  ${YELLOW}[DRY-RUN]${NC} Would remove: $ver (${YELLOW}$size${NC})"
        else
            echo -e "  ${RED}Removing${NC}: $ver (${YELLOW}$size${NC})"
            rm -rf "$CURSOR_AGENT_DIR/versions/$ver"
        fi
    done
    
    saved_mb=$((total_saved / 1024))
    echo -e "\n${GREEN}✓${NC} Total space saved: ${YELLOW}~${saved_mb}MB${NC}"
    echo ""
}

analyze_python_packages() {
    echo -e "${BLUE}🐍 Python Packages Analysis${NC}"
    echo -e "${CYAN}────────────────────────────────────────${NC}"
    echo ""
    echo -e "${YELLOW}Note:${NC} Python package cleanup requires manual review"
    echo -e "Use 'pip list' to see installed packages"
    echo ""
    
    for pyver in python3.11 python3.12; do
        py_dir="$LOCAL_LIB/$pyver/site-packages"
        if [ ! -d "$py_dir" ]; then
            continue
        fi
        
        echo -e "${GREEN}$pyver packages:${NC}"
        echo -e "  Location: $py_dir"
        echo -e "  To list packages: ${CYAN}pip${pyver#python} list${NC}"
        echo -e "  To uninstall: ${CYAN}pip${pyver#python} uninstall <package>${NC}"
        echo ""
    done
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --execute)
            DRY_RUN=false
            shift
            ;;
        --claude)
            CLEAN_CLAUDE=true
            shift
            ;;
        --cursor)
            CLEAN_CURSOR=true
            shift
            ;;
        --python)
            CLEAN_PYTHON=true
            shift
            ;;
        --all)
            CLEAN_CLAUDE=true
            CLEAN_CURSOR=true
            shift
            ;;
        --help)
            show_usage
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            show_usage
            exit 1
            ;;
    esac
done

# Main execution
print_header

if [ "$DRY_RUN" = true ]; then
    echo -e "${YELLOW}⚠️  DRY-RUN MODE${NC} - No files will be deleted"
    echo -e "Use ${CYAN}--execute${NC} to actually perform cleanup"
    echo ""
fi

if [ "$CLEAN_CLAUDE" = true ]; then
    clean_claude_versions
fi

if [ "$CLEAN_CURSOR" = true ]; then
    clean_cursor_agent_versions
fi

if [ "$CLEAN_PYTHON" = true ]; then
    analyze_python_packages
fi

if [ "$CLEAN_CLAUDE" = false ] && [ "$CLEAN_CURSOR" = false ] && [ "$CLEAN_PYTHON" = false ]; then
    echo -e "${YELLOW}No cleanup options specified${NC}"
    echo ""
    show_usage
fi

if [ "$DRY_RUN" = false ]; then
    echo -e "${GREEN}✓ Cleanup completed!${NC}"
else
    echo -e "${CYAN}Run with --execute to perform actual cleanup${NC}"
fi
