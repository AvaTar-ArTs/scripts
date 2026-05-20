#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail

# ai_menu_simple.sh — Simplified AI Tools Menu
# Works in any shell environment

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
PURPLE='\033[0;35m'
NC='\033[0m'

print_header() {
    echo -e "${CYAN}===============================================${NC}"
    echo -e "  🤖 AI Tools Menu — $(date '+%H:%M:%S')"
    echo -e "${CYAN}===============================================${NC}"
}

show_menu() {
    print_header
    echo "Choose your AI tool:"
    echo ""
    echo -e "  ${GREEN}1)${NC} ${GREEN}Grok CLI${NC}        - Cloud-based AI assistant"
    echo -e "  ${BLUE}2)${NC} ${BLUE}Ollama${NC}          - Local AI models"
    echo -e "  ${PURPLE}3)${NC} ${PURPLE}Python AI APIs${NC}  - OpenAI, Claude, etc."
    echo -e "  ${YELLOW}4)${NC} ${YELLOW}Environment Check${NC} - Check API keys & tools"
    echo -e "  ${CYAN}5)${NC} ${CYAN}Quick Actions${NC}   - Fast access to common tasks"
    echo ""
    echo -e "  ${NC}q) Quit${NC}"
    echo ""
    read -p "Choice: " choice
    echo "$choice"
}

check_tools() {
    echo -e "${CYAN}Checking AI Tools Status:${NC}"
    echo ""
    
    # Check Grok CLI
    if command -v grok &> /dev/null; then
        echo -e "${GREEN}✅ Grok CLI${NC}"
    else
        echo -e "${RED}❌ Grok CLI${NC} (install: npm install -g @vibe-kit/grok-cli)"
    fi
    
    # Check Ollama
    if command -v ollama &> /dev/null; then
        echo -e "${GREEN}✅ Ollama${NC}"
    else
        echo -e "${RED}❌ Ollama${NC} (install: brew install ollama)"
    fi
    
    # Check Node.js
    if command -v node &> /dev/null; then
        echo -e "${GREEN}✅ Node.js${NC}"
    else
        echo -e "${RED}❌ Node.js${NC} (install: brew install node)"
    fi
    
    # Check Python
    if command -v python3 &> /dev/null; then
        echo -e "${GREEN}✅ Python3${NC}"
    else
        echo -e "${RED}❌ Python3${NC} (install: brew install python)"
    fi
    
    echo ""
    read -p "Press Enter to continue..."
}

grok_quick() {
    echo -e "${GREEN}🤖 Grok CLI Quick Access${NC}"
    echo ""
    read -p "Enter your question: " prompt
    if [ -n "$prompt" ]; then
        echo -e "${CYAN}Asking Grok: $prompt${NC}"
        echo ""
        grok --print "$prompt"
    fi
    echo ""
    read -p "Press Enter to continue..."
}

ollama_quick() {
    echo -e "${BLUE}🦙 Ollama Quick Access${NC}"
    echo ""
    read -p "Enter your question: " prompt
    if [ -n "$prompt" ]; then
        echo -e "${CYAN}Asking Ollama: $prompt${NC}"
        echo ""
        ollama run llama3.1:8b "$prompt"
    fi
    echo ""
    read -p "Press Enter to continue..."
}

python_apis() {
    echo -e "${PURPLE}🐍 Python AI APIs${NC}"
    echo ""
    echo "Available options:"
    echo "  1) Run Agent Script"
    echo "  2) Test APIs"
    echo "  3) Run Examples"
    echo "  b) Back"
    echo ""
    read -p "Choice: " choice
    
    case "$choice" in
        1)
            echo -e "${CYAN}Starting ChatGPT agent...${NC}"
            if [ -f "$HOME/Documents/script/run_agent.sh" ]; then
                bash "$HOME/Documents/script/run_agent.sh"
            else
                echo -e "${RED}Agent script not found${NC}"
            fi
            ;;
        2)
            echo -e "${CYAN}Testing AI APIs...${NC}"
            if [ -f "$HOME/test-apis.py" ]; then
                python3 "$HOME/test-apis.py"
            else
                echo -e "${YELLOW}Test script not found${NC}"
            fi
            ;;
        3)
            echo -e "${CYAN}Running AI examples...${NC}"
            if [ -f "$HOME/AI_EXAMPLES.py" ]; then
                python3 "$HOME/AI_EXAMPLES.py"
            else
                echo -e "${YELLOW}Examples not found${NC}"
            fi
            ;;
        b|B) return ;;
        *) echo -e "${RED}Invalid choice${NC}" ;;
    esac
    
    echo ""
    read -p "Press Enter to continue..."
}

quick_actions() {
    echo -e "${CYAN}⚡ Quick Actions${NC}"
    echo ""
    echo "  1) Ask Grok anything"
    echo "  2) Generate with Ollama"
    echo "  3) Check API keys"
    echo "  4) Environment status"
    echo "  b) Back"
    echo ""
    read -p "Choice: " choice
    
    case "$choice" in
        1)
            read -p "Ask Grok: " prompt
            if [ -n "$prompt" ]; then
                grok --print "$prompt"
            fi
            ;;
        2)
            read -p "Ask Ollama: " prompt
            if [ -n "$prompt" ]; then
                ollama run llama3.1:8b "$prompt"
            fi
            ;;
        3)
            echo -e "${CYAN}Checking API keys...${NC}"
            if [ -f "$HOME/Documents/script/monitoring/check_env_keys.sh" ]; then
                bash "$HOME/Documents/script/monitoring/check_env_keys.sh"
            else
                echo -e "${YELLOW}Check script not found${NC}"
            fi
            ;;
        4)
            echo -e "${CYAN}Environment status:${NC}"
            echo "GROK_API_KEY: ${GROK_API_KEY:+✅ Set}${GROK_API_KEY:-❌ Not set}"
            echo "XAI_API_KEY: ${XAI_API_KEY:+✅ Set}${XAI_API_KEY:-❌ Not set}"
            echo "OPENAI_API_KEY: ${OPENAI_API_KEY:+✅ Set}${OPENAI_API_KEY:-❌ Not set}"
            ;;
        b|B) return ;;
        *) echo -e "${RED}Invalid choice${NC}" ;;
    esac
    
    echo ""
    read -p "Press Enter to continue..."
}

# Load environment
if [ -f "$HOME/.env.d/loader.sh" ]; then
    source "$HOME/.env.d/loader.sh" llm-apis 2>/dev/null || true
fi

# Main loop
while true; do
    choice=$(show_menu)
    
    case "$choice" in
        q|Q) 
            echo -e "${GREEN}👋 Bye!${NC}"
            exit 0
            ;;
        1)
            grok_quick
            ;;
        2)
            ollama_quick
            ;;
        3)
            python_apis
            ;;
        4)
            check_tools
            ;;
        5)
            quick_actions
            ;;
        *)
            echo -e "${RED}Invalid choice${NC}"
            ;;
    esac
done
