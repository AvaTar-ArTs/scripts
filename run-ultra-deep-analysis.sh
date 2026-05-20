#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail


# 🌌 ULTRA-DEEP INTELLIGENCE ORCHESTRATOR LAUNCHER 🌌
# ===================================================

echo "🚀 Starting Ultra-Deep Intelligence Orchestrator..."
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

# Check Python
echo -e "${CYAN}🔍 Checking Python...${NC}"
if ! command -v python3 &> /dev/null; then
    echo -e "${RED}❌ Python 3 not found!${NC}"
    exit 1
fi
echo -e "${GREEN}✅ Python found: $(python3 --version)${NC}"
echo ""

# Check/Install dependencies
echo -e "${CYAN}📦 Checking dependencies...${NC}"
REQUIRED_PACKAGES=("openai" "google-generativeai" "groq" "numpy")

for package in "${REQUIRED_PACKAGES[@]}"; do
    if python3 -c "import ${package}" 2>/dev/null; then
        echo -e "${GREEN}✅ ${package}${NC}"
    else
        echo -e "${YELLOW}⚠️  ${package} not found, installing...${NC}"
        pip3 install ${package} --quiet
    fi
done
echo ""

# Load environment variables
echo -e "${CYAN}🔑 Loading API keys...${NC}"
if [ -f "/Users/steven/env_d_all.txt" ]; then
    source <(grep -v '^#' /Users/steven/env_d_all.txt | grep '=' | sed 's/^export //' | sed 's/^/export /')
    echo -e "${GREEN}✅ API keys loaded${NC}"
else
    echo -e "${YELLOW}⚠️  env_d_all.txt not found${NC}"
fi
echo ""

# Run the orchestrator
echo -e "${MAGENTA}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${MAGENTA}🌌 LAUNCHING ULTRA-DEEP INTELLIGENCE ORCHESTRATOR 🌌${NC}"
echo -e "${MAGENTA}═══════════════════════════════════════════════════════════════${NC}"
echo ""

cd /Users/steven/Documents

python3 ULTRA_DEEP_INTELLIGENCE_ORCHESTRATOR.py

echo ""
echo -e "${GREEN}✨ Analysis complete! ✨${NC}"
echo ""
