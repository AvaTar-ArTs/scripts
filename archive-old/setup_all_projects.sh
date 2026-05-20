#!/usr/bin/env bash

# 🚀 AvaTar ArTs - Multi-Project Setup Script
# Setup script for all 4 AvaTar ArTs projects

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Projects array
declare -a PROJECTS=("avatararts-gallery" "avatararts-tools" "avatararts-portfolio" "avatararts-hub")
BASE_DIR="/Users/steven/tehSiTes"

echo -e "${MAGENTA}"
echo "╔════════════════════════════════════════════════════════════╗"
echo "║     🎨 AvaTar ArTs Multi-Project Setup Script 🎨           ║"
echo "║     Setting up 4 premium AI creative platforms              ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Function to setup a single project
setup_project() {
    local project=$1
    local project_path="$BASE_DIR/$project"
    
    echo -e "\n${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}📦 Setting up: ${YELLOW}$project${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    if [ ! -d "$project_path" ]; then
        echo -e "${RED}❌ Directory not found: $project_path${NC}"
        return 1
    fi
    
    cd "$project_path"
    
    # Clean up
    echo -e "${YELLOW}🧹 Cleaning up...${NC}"
    rm -rf node_modules yarn.lock package-lock.json .next
    
    # Install dependencies
    echo -e "${YELLOW}📥 Installing dependencies...${NC}"
    if command -v yarn &> /dev/null; then
        yarn install
    else
        npm install
    fi
    
    echo -e "${GREEN}✅ $project setup complete!${NC}"
}

# Setup all projects
setup_all() {
    echo -e "\n${BLUE}🚀 Starting setup for all projects...${NC}"
    
    local failed_projects=()
    local successful_projects=()
    
    for project in "${PROJECTS[@]}"; do
        if setup_project "$project"; then
            successful_projects+=("$project")
        else
            failed_projects+=("$project")
        fi
    done
    
    # Summary
    echo -e "\n${MAGENTA}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${MAGENTA}║             📊 Setup Summary                                ║${NC}"
    echo -e "${MAGENTA}╚════════════════════════════════════════════════════════════╝${NC}"
    
    if [ ${#successful_projects[@]} -gt 0 ]; then
        echo -e "\n${GREEN}✅ Successfully setup:${NC}"
        for project in "${successful_projects[@]}"; do
            echo -e "  ${GREEN}✓${NC} $project"
        done
    fi
    
    if [ ${#failed_projects[@]} -gt 0 ]; then
        echo -e "\n${RED}❌ Failed projects:${NC}"
        for project in "${failed_projects[@]}"; do
            echo -e "  ${RED}✗${NC} $project"
        done
    fi
    
    echo -e "\n${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "\n${YELLOW}🎉 Setup complete! Next steps:${NC}\n"
    
    echo -e "${GREEN}Gallery (Premium AI Art Showcase):${NC}"
    echo "  cd $BASE_DIR/avatararts-gallery && yarn dev"
    echo ""
    
    echo -e "${GREEN}Tools (AI Creative Tools):${NC}"
    echo "  cd $BASE_DIR/avatararts-tools && yarn dev"
    echo ""
    
    echo -e "${GREEN}Portfolio (Services & Projects):${NC}"
    echo "  cd $BASE_DIR/avatararts-portfolio && yarn dev"
    echo ""
    
    echo -e "${GREEN}Hub (Unified Platform):${NC}"
    echo "  cd $BASE_DIR/avatararts-hub && yarn dev"
    echo ""
    
    echo -e "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${MAGENTA}Each site runs on localhost with different ports!${NC}"
    echo -e "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
}

# Check if specific project was requested
if [ $# -eq 1 ]; then
    project_found=0
    for p in "${PROJECTS[@]}"; do
        if [[ "$p" == "$1" ]]; then
            project_found=1
            break
        fi
    done
    if [[ "$project_found" -eq 1 ]]; then
        setup_project "$1"
    else
        echo -e "${RED}❌ Unknown project: $1${NC}"
        echo -e "${CYAN}Available projects: ${PROJECTS[*]}${NC}"
        exit 1
    fi
else
    setup_all
fi
