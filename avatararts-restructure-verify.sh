#!/usr/bin/env bash

# 🔍 AVATARARTS RESTRUCTURE VERIFICATION SCRIPT 🔍
# Validates the restructured AvatarArts directory structure
# Checks all 6 projects for completeness and integrity

set -e

WORKSPACE="/Users/steven/tehSiTes"
EXTERNAL="/Volumes/2T-Xx/AvaTarArTs"

# Color codes ✨
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# Track results
TOTAL_CHECKS=0
PASSED_CHECKS=0
FAILED_CHECKS=0

echo -e "${MAGENTA}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${MAGENTA}║  🔍 AVATARARTS RESTRUCTURE VERIFICATION SCRIPT 🔍         ║${NC}"
echo -e "${MAGENTA}╚════════════════════════════════════════════════════════════╝${NC}"

# Function to check directory existence
check_dir() {
    local dir=$1
    local name=$2
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))

    if [ -d "$dir" ]; then
        echo -e "  ${GREEN}✓${NC} $name"
        PASSED_CHECKS=$((PASSED_CHECKS + 1))
    else
        echo -e "  ${RED}✗${NC} $name (MISSING)"
        FAILED_CHECKS=$((FAILED_CHECKS + 1))
    fi
}

# Function to count files in directory
count_files() {
    local dir=$1
    if [ -d "$dir" ]; then
        find "$dir" -type f 2>/dev/null | wc -l
    else
        echo "0"
    fi
}

# Function to check README files
check_readme() {
    local dir=$1
    local name=$2
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))

    if [ -f "$dir/README_RESTRUCTURE.md" ]; then
        echo -e "  ${GREEN}✓${NC} README for $name"
        PASSED_CHECKS=$((PASSED_CHECKS + 1))
    else
        echo -e "  ${YELLOW}⚠${NC}  README missing for $name"
        FAILED_CHECKS=$((FAILED_CHECKS + 1))
    fi
}

# ===== VERIFICATION REPORT =====
echo -e "\n${CYAN}═══ PROJECT STRUCTURE VERIFICATION ═══${NC}\n"

# 1. AvatarArts_MERGED
echo -e "${BLUE}📦 AvatarArts_MERGED (Master Archive)${NC}"
check_dir "$WORKSPACE/AvatarArts_MERGED/01_Web_Assets" "01_Web_Assets"
check_dir "$WORKSPACE/AvatarArts_MERGED/02_AI_Tools" "02_AI_Tools"
check_dir "$WORKSPACE/AvatarArts_MERGED/03_Content_Strategy" "03_Content_Strategy"
check_dir "$WORKSPACE/AvatarArts_MERGED/04_Analysis_Reports" "04_Analysis_Reports"
check_dir "$WORKSPACE/AvatarArts_MERGED/05_Development_Files" "05_Development_Files"
check_dir "$WORKSPACE/AvatarArts_MERGED/06_Backup_Files" "06_Backup_Files"
check_dir "$WORKSPACE/AvatarArts_MERGED/07_Documentation" "07_Documentation"
check_dir "$WORKSPACE/AvatarArts_MERGED/08_Creative_Assets" "08_Creative_Assets"
check_dir "$WORKSPACE/AvatarArts_MERGED/09_AI_Integration" "09_AI_Integration"
check_dir "$WORKSPACE/AvatarArts_MERGED/10_Development_Workflow" "10_Development_Workflow"
check_readme "$WORKSPACE/AvatarArts_MERGED" "AvatarArts_MERGED"

echo -e "\n${BLUE}🖼️  avatararts-gallery (Gallery System)${NC}"
check_dir "$WORKSPACE/avatararts-gallery/01_Gallery_Systems" "01_Gallery_Systems"
check_dir "$WORKSPACE/avatararts-gallery/02_Web_Assets" "02_Web_Assets"
check_dir "$WORKSPACE/avatararts-gallery/03_Content" "03_Content"
check_dir "$WORKSPACE/avatararts-gallery/04_API_Integration" "04_API_Integration"
check_dir "$WORKSPACE/avatararts-gallery/05_Development" "05_Development"
check_readme "$WORKSPACE/avatararts-gallery" "avatararts-gallery"

echo -e "\n${BLUE}🌐 avatararts-hub (Central Hub)${NC}"
check_dir "$WORKSPACE/avatararts-hub/01_Core_Hub" "01_Core_Hub"
check_dir "$WORKSPACE/avatararts-hub/02_Integration" "02_Integration"
check_dir "$WORKSPACE/avatararts-hub/03_Content_Management" "03_Content_Management"
check_dir "$WORKSPACE/avatararts-hub/04_User_Interface" "04_User_Interface"
check_dir "$WORKSPACE/avatararts-hub/05_Documentation" "05_Documentation"
check_readme "$WORKSPACE/avatararts-hub" "avatararts-hub"

echo -e "\n${BLUE}💼 avatararts-portfolio (Portfolio Showcase)${NC}"
check_dir "$WORKSPACE/avatararts-portfolio/01_Portfolio_Items" "01_Portfolio_Items"
check_dir "$WORKSPACE/avatararts-portfolio/02_Profile_Pages" "02_Profile_Pages"
check_dir "$WORKSPACE/avatararts-portfolio/03_Project_Details" "03_Project_Details"
check_dir "$WORKSPACE/avatararts-portfolio/04_Analytics" "04_Analytics"
check_dir "$WORKSPACE/avatararts-portfolio/05_Design_Assets" "05_Design_Assets"
check_readme "$WORKSPACE/avatararts-portfolio" "avatararts-portfolio"

echo -e "\n${BLUE}🛠️  avatararts-tools (Development Tools)${NC}"
check_dir "$WORKSPACE/avatararts-tools/01_Development_Tools" "01_Development_Tools"
check_dir "$WORKSPACE/avatararts-tools/02_AI_Agents" "02_AI_Agents"
check_dir "$WORKSPACE/avatararts-tools/03_Content_Tools" "03_Content_Tools"
check_dir "$WORKSPACE/avatararts-tools/04_Design_Tools" "04_Design_Tools"
check_dir "$WORKSPACE/avatararts-tools/05_Configuration" "05_Configuration"
check_readme "$WORKSPACE/avatararts-tools" "avatararts-tools"

echo -e "\n${BLUE}🌍 avatararts.org (Main Organization)${NC}"
check_dir "$WORKSPACE/avatararts.org/01_Public_Website" "01_Public_Website"
check_dir "$WORKSPACE/avatararts.org/02_Brand_Assets" "02_Brand_Assets"
check_dir "$WORKSPACE/avatararts.org/03_Web_Infrastructure" "03_Web_Infrastructure"
check_dir "$WORKSPACE/avatararts.org/04_Content_Hub" "04_Content_Hub"
check_dir "$WORKSPACE/avatararts.org/05_Community" "05_Community"
check_readme "$WORKSPACE/avatararts.org" "avatararts.org"

# ===== SUMMARY =====
echo -e "\n${CYAN}═══ VERIFICATION SUMMARY ═══${NC}\n"

echo -e "Total Checks:   ${YELLOW}$TOTAL_CHECKS${NC}"
echo -e "Passed:         ${GREEN}$PASSED_CHECKS${NC} ✓"
echo -e "Failed:         ${RED}$FAILED_CHECKS${NC}"

if [ $FAILED_CHECKS -eq 0 ]; then
    echo -e "\n${GREEN}🎉 ALL CHECKS PASSED! Structure is complete.${NC}"
else
    echo -e "\n${YELLOW}⚠️  Some checks failed. Please review above.${NC}"
fi

# ===== SUBDIRECTORY COUNT =====
echo -e "\n${CYAN}═══ SUBDIRECTORY DEPTH ═══${NC}\n"

echo -e "${BLUE}AvatarArts_MERGED${NC}"
echo -e "  Subdirectories: $(find "$WORKSPACE/AvatarArts_MERGED" -maxdepth 2 -type d | wc -l)"
echo -e "  Files: $(find "$WORKSPACE/AvatarArts_MERGED" -type f 2>/dev/null | wc -l)"

echo -e "\n${BLUE}avatararts-gallery${NC}"
echo -e "  Subdirectories: $(find "$WORKSPACE/avatararts-gallery" -maxdepth 2 -type d | wc -l)"
echo -e "  Files: $(find "$WORKSPACE/avatararts-gallery" -type f 2>/dev/null | wc -l)"

echo -e "\n${BLUE}avatararts-hub${NC}"
echo -e "  Subdirectories: $(find "$WORKSPACE/avatararts-hub" -maxdepth 2 -type d | wc -l)"
echo -e "  Files: $(find "$WORKSPACE/avatararts-hub" -type f 2>/dev/null | wc -l)"

echo -e "\n${BLUE}avatararts-portfolio${NC}"
echo -e "  Subdirectories: $(find "$WORKSPACE/avatararts-portfolio" -maxdepth 2 -type d | wc -l)"
echo -e "  Files: $(find "$WORKSPACE/avatararts-portfolio" -type f 2>/dev/null | wc -l)"

echo -e "\n${BLUE}avatararts-tools${NC}"
echo -e "  Subdirectories: $(find "$WORKSPACE/avatararts-tools" -maxdepth 2 -type d | wc -l)"
echo -e "  Files: $(find "$WORKSPACE/avatararts-tools" -type f 2>/dev/null | wc -l)"

echo -e "\n${BLUE}avatararts.org${NC}"
echo -e "  Subdirectories: $(find "$WORKSPACE/avatararts.org" -maxdepth 2 -type d | wc -l)"
echo -e "  Files: $(find "$WORKSPACE/avatararts.org" -type f 2>/dev/null | wc -l)"

# ===== EXTERNAL REFERENCE =====
echo -e "\n${CYAN}═══ EXTERNAL REFERENCE ═══${NC}\n"

if [ -d "$EXTERNAL" ]; then
    echo -e "${GREEN}✓${NC} External reference found at $EXTERNAL"
    echo -e "  Main directories: $(ls -d "$EXTERNAL"/*/ 2>/dev/null | wc -l)"
else
    echo -e "${YELLOW}⚠${NC} External reference not accessible"
fi

# ===== NEXT STEPS =====
echo -e "\n${CYAN}═══ NEXT STEPS ═══${NC}\n"

if [ $FAILED_CHECKS -eq 0 ]; then
    echo -e "${GREEN}✓ All directories verified${NC}"
    echo -e "\n${YELLOW}Recommended Actions:${NC}"
    echo -e "  1. Migrate existing content to new directories"
    echo -e "  2. Update all import paths and references"
    echo -e "  3. Create project-specific setup guides"
    echo -e "  4. Test all systems thoroughly"
    echo -e "  5. Update deployment and build scripts"
    echo -e "  6. Create cross-project integration tests"
    echo -e "\n${BLUE}Documentation available:${NC}"
    echo -e "  • Master Index: AVATARARTS_RESTRUCTURING_INDEX.md"
    echo -e "  • Per-project READMEs: */README_RESTRUCTURE.md"
    echo -e "  • Integration Guide: AVATARARTS_INTEGRATION_GUIDE.md"
else
    echo -e "${RED}✗ Please fix missing directories before proceeding${NC}"
fi

echo -e "\n${MAGENTA}═══════════════════════════════════════════════════════════${NC}\n"
