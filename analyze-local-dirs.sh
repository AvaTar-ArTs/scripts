#!/usr/bin/env bash
# Analyze and manage .local/lib, .local/share/claude, and .local/share/cursor-agent
# Provides insights and cleanup recommendations

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

print_header() {
    echo -e "${CYAN}========================================${NC}"
    echo -e "  📊 ${BLUE}Local Directories Analysis${NC}"
    echo -e "${CYAN}========================================${NC}"
    echo ""
}

analyze_python_lib() {
    echo -e "${BLUE}🐍 Python Libraries Analysis${NC}"
    echo -e "${CYAN}────────────────────────────────────────${NC}"
    
    if [ ! -d "$LOCAL_LIB" ]; then
        echo -e "${RED}❌ Directory not found: $LOCAL_LIB${NC}"
        return
    fi
    
    for pyver in python3.11 python3.12; do
        py_dir="$LOCAL_LIB/$pyver"
        if [ -d "$py_dir/site-packages" ]; then
            size=$(du -sh "$py_dir" 2>/dev/null | cut -f1)
            pkg_count=$(ls "$py_dir/site-packages" 2>/dev/null | wc -l | tr -d ' ')
            
            echo -e "${GREEN}✓${NC} $pyver:"
            echo -e "  Size: ${YELLOW}$size${NC}"
            echo -e "  Packages: ${YELLOW}$pkg_count${NC}"
            
            # Find largest packages
            echo -e "  ${DIM}Top 5 largest packages:${NC}"
            du -sh "$py_dir/site-packages"/* 2>/dev/null | sort -hr | head -5 | \
                awk '{printf "    %s\n", $0}' | sed 's/^/    /'
            echo ""
        fi
    done
}

analyze_claude_versions() {
    echo -e "${BLUE}🤖 Claude Versions Analysis${NC}"
    echo -e "${CYAN}────────────────────────────────────────${NC}"
    
    if [ ! -d "$CLAUDE_DIR/versions" ]; then
        echo -e "${RED}❌ Directory not found: $CLAUDE_DIR/versions${NC}"
        return
    fi
    
    versions=($(ls -1t "$CLAUDE_DIR/versions" 2>/dev/null))
    if [ ${#versions[@]} -eq 0 ]; then
        echo -e "${YELLOW}No versions found${NC}"
        return
    fi
    
    echo -e "${GREEN}Found ${#versions[@]} version(s):${NC}"
    for i in "${!versions[@]}"; do
        ver="${versions[$i]}"
        size=$(du -sh "$CLAUDE_DIR/versions/$ver" 2>/dev/null | cut -f1)
        date=$(stat -f "%Sm" -t "%Y-%m-%d %H:%M" "$CLAUDE_DIR/versions/$ver" 2>/dev/null || echo "unknown")
        
        if [ $i -eq 0 ]; then
            echo -e "  ${GREEN}→${NC} $ver (${YELLOW}$size${NC}) - Latest - $date"
        else
            echo -e "  ${YELLOW}  ${NC} $ver (${YELLOW}$size${NC}) - $date"
        fi
    done
    
    # Calculate potential savings
    if [ ${#versions[@]} -gt 1 ]; then
        old_versions=("${versions[@]:1}")
        total_old_size=0
        for ver in "${old_versions[@]}"; do
            size_bytes=$(du -sk "$CLAUDE_DIR/versions/$ver" 2>/dev/null | cut -f1)
            total_old_size=$((total_old_size + size_bytes))
        done
        old_size_mb=$((total_old_size / 1024))
        echo -e "\n  ${CYAN}Potential savings: ${YELLOW}~${old_size_mb}MB${NC} (keeping only latest)"
    fi
    echo ""
}

analyze_cursor_agent_versions() {
    echo -e "${BLUE}🖱️  Cursor Agent Versions Analysis${NC}"
    echo -e "${CYAN}────────────────────────────────────────${NC}"
    
    if [ ! -d "$CURSOR_AGENT_DIR/versions" ]; then
        echo -e "${RED}❌ Directory not found: $CURSOR_AGENT_DIR/versions${NC}"
        return
    fi
    
    versions=($(ls -1t "$CURSOR_AGENT_DIR/versions" 2>/dev/null))
    if [ ${#versions[@]} -eq 0 ]; then
        echo -e "${YELLOW}No versions found${NC}"
        return
    fi
    
    echo -e "${GREEN}Found ${#versions[@]} version(s):${NC}"
    for i in "${!versions[@]}"; do
        ver="${versions[$i]}"
        size=$(du -sh "$CURSOR_AGENT_DIR/versions/$ver" 2>/dev/null | cut -f1)
        date=$(stat -f "%Sm" -t "%Y-%m-%d %H:%M" "$CURSOR_AGENT_DIR/versions/$ver" 2>/dev/null || echo "unknown")
        
        if [ $i -eq 0 ]; then
            echo -e "  ${GREEN}→${NC} $ver (${YELLOW}$size${NC}) - Latest - $date"
        else
            echo -e "  ${YELLOW}  ${NC} $ver (${YELLOW}$size${NC}) - $date"
        fi
    done
    
    # Calculate potential savings
    if [ ${#versions[@]} -gt 1 ]; then
        old_versions=("${versions[@]:1}")
        total_old_size=0
        for ver in "${old_versions[@]}"; do
            size_bytes=$(du -sk "$CURSOR_AGENT_DIR/versions/$ver" 2>/dev/null | cut -f1)
            total_old_size=$((total_old_size + size_bytes))
        done
        old_size_mb=$((total_old_size / 1024))
        echo -e "\n  ${CYAN}Potential savings: ${YELLOW}~${old_size_mb}MB${NC} (keeping only latest)"
    fi
    echo ""
}

show_summary() {
    echo -e "${BLUE}📊 Summary${NC}"
    echo -e "${CYAN}────────────────────────────────────────${NC}"
    
    total_size=$(du -sk "$LOCAL_LIB" "$CLAUDE_DIR" "$CURSOR_AGENT_DIR" 2>/dev/null | awk '{sum+=$1} END {print sum}')
    total_size_gb=$(echo "scale=2; $total_size / 1024 / 1024" | bc)
    
    echo -e "Total size: ${YELLOW}~${total_size_gb}GB${NC}"
    echo ""
    
    echo -e "${GREEN}Recommendations:${NC}"
    echo -e "  1. ${CYAN}Python libs${NC}: Review and remove unused packages"
    echo -e "  2. ${CYAN}Claude${NC}: Keep only latest version (saves ~330MB)"
    echo -e "  3. ${CYAN}Cursor Agent${NC}: Keep only latest version (saves ~164MB)"
    echo ""
}

# Main
print_header
analyze_python_lib
analyze_claude_versions
analyze_cursor_agent_versions
show_summary
