#!/usr/bin/env bash
# ai_unified_menu.sh — Unified AI Tools Menu
# Integrates all your AI tools: Grok CLI, Ollama, Python APIs
# Intel macOS • zsh • Your complete AI ecosystem

set -eu

# -------- Colors --------
if command -v tput >/dev/null 2>&1; then
  BOLD="$(tput bold)"; DIM="$(tput dim)"; RESET="$(tput sgr0)"
  GREEN="$(tput setaf 2)"; RED="$(tput setaf 1)"; CYAN="$(tput setaf 6)"
  YELLOW="$(tput setaf 3)"; BLUE="$(tput setaf 4)"; PURPLE="$(tput setaf 5)"
  MAGENTA="$(tput setaf 5)"
else
  BOLD=""; DIM=""; RESET=""; GREEN=""; RED=""; CYAN=""; YELLOW=""; BLUE=""; PURPLE=""; MAGENTA=""
fi

# -------- Configuration --------
SCRIPT_DIR="$HOME/Documents/script"
API_OPS_DIR="$SCRIPT_DIR/api-operations"

# -------- Trap --------
trap 'echo "\n${DIM}↩ interrupted${RESET}"; exit 1' INT

# -------- HELPERS --------
print_header() {
  echo "${CYAN}===============================================${RESET}"
  echo "  🤖 ${BOLD}Unified AI Tools Menu${RESET} — $(date '+%H:%M:%S')"
  echo "${CYAN}===============================================${RESET}"
}

check_tool() {
  local tool="$1"
  local install_cmd="$2"
  
  if command -v "$tool" &> /dev/null; then
    echo "${GREEN}✅ $tool${RESET}"
    return 0
  else
    echo "${RED}❌ $tool${RESET}"
    echo "${DIM}   Install: $install_cmd${RESET}"
    return 1
  fi
}

load_environment() {
  echo "${DIM}Loading AI environment...${RESET}"
  if [ -f "$HOME/.env.d/loader.sh" ]; then
    source "$HOME/.env.d/loader.sh" llm-apis 2>/dev/null || true
    echo "${GREEN}✅ Environment loaded${RESET}"
  else
    echo "${YELLOW}⚠️  No .env.d/loader.sh found${RESET}"
  fi
}

prompt_choice() {
  local prompt="$1"
  printf "%s" "$prompt"
  read -r choice
  echo "$choice"
}

# -------- TOOL CHECKS --------
check_all_tools() {
  print_header
  echo "Checking AI Tools Status:"
  echo ""
  
  local tools_available=0
  local total_tools=0
  
  # Grok CLI
  total_tools=$((total_tools + 1))
  if check_tool "grok" "npm install -g @vibe-kit/grok-cli"; then
    tools_available=$((tools_available + 1))
  fi
  
  # Ollama
  total_tools=$((total_tools + 1))
  if check_tool "ollama" "brew install ollama"; then
    tools_available=$((tools_available + 1))
  fi
  
  # Node.js
  total_tools=$((total_tools + 1))
  if check_tool "node" "brew install node"; then
    tools_available=$((tools_available + 1))
  fi
  
  # Python (for AI APIs)
  total_tools=$((total_tools + 1))
  if check_tool "python3" "brew install python"; then
    tools_available=$((tools_available + 1))
  fi
  
  # jq (for JSON processing)
  total_tools=$((total_tools + 1))
  if check_tool "jq" "brew install jq"; then
    tools_available=$((tools_available + 1))
  fi
  
  echo ""
  echo "${CYAN}Status: $tools_available/$total_tools tools available${RESET}"
  
  if [ $tools_available -eq $total_tools ]; then
    echo "${GREEN}🎉 All tools ready!${RESET}"
  else
    echo "${YELLOW}⚠️  Some tools missing. Install them to use all features.${RESET}"
  fi
  
  echo ""
  read -r "?Press Enter to continue..."
}

# -------- MAIN MENU --------
show_main_menu() {
  print_header
  echo "Choose your AI tool:"
  echo ""
  echo "  ${GREEN}1)${RESET} ${BOLD}Grok CLI${RESET}        - Cloud-based AI assistant"
  echo "  ${BLUE}2)${RESET} ${BOLD}Ollama${RESET}          - Local AI models"
  echo "  ${PURPLE}3)${RESET} ${BOLD}Python AI APIs${RESET}  - OpenAI, Claude, etc."
  echo "  ${YELLOW}4)${RESET} ${BOLD}Environment Check${RESET} - Check API keys & tools"
  echo "  ${MAGENTA}5)${RESET} ${BOLD}Quick Actions${RESET}   - Fast access to common tasks"
  echo ""
  echo "  ${DIM}q) Quit${RESET}"
  echo ""
  prompt_choice "${BOLD}Choice:${RESET} "
}

# -------- GROK CLI MENU --------
grok_menu() {
  echo ""
  echo "${GREEN}🤖 Grok CLI Options:${RESET}"
  echo ""
  echo "  1) Interactive Menu"
  echo "  2) Quick Prompt"
  echo "  3) Analyze File"
  echo "  4) Code Review"
  echo "  5) Git Analysis"
  echo "  b) Back"
  echo ""
  prompt_choice "${BOLD}Choice:${RESET} "
}

run_grok_choice() {
  local choice="$1"
  
  case "$choice" in
    1)
      echo "${DIM}Starting Grok interactive menu...${RESET}"
      "$API_OPS_DIR/grok_menu.sh"
      ;;
    2)
      printf "${BOLD}Enter your prompt:${RESET} "
      read -r prompt
      [ -n "$prompt" ] && grok --print "$prompt"
      ;;
    3)
      printf "${BOLD}Enter file path:${RESET} "
      read -r file
      if [ -f "$file" ]; then
        local content
        content=$(cat "$file")
        grok --print "Analyze this file and provide insights: $content"
      else
        echo "${RED}❌ File not found: $file${RESET}"
      fi
      ;;
    4)
      printf "${BOLD}Enter file path:${RESET} "
      read -r file
      if [ -f "$file" ]; then
        local content
        content=$(cat "$file")
        grok --print "Review this code for bugs, improvements, and best practices: $content"
      else
        echo "${RED}❌ File not found: $file${RESET}"
      fi
      ;;
    5)
      if command -v git &> /dev/null; then
        local git_status
        git_status=$(git status --porcelain 2>/dev/null || echo "Not a git repository")
        local git_log
        git_log=$(git log --oneline -5 2>/dev/null || echo "No git history")
        
        local prompt="Analyze this git repository status and recent commits. Provide insights and suggestions:

Git Status:
$git_status

Recent Commits:
$git_log"
        
        grok --print "$prompt"
      else
        echo "${RED}❌ Git not found${RESET}"
      fi
      ;;
    [bB]) return 0 ;;
    *) echo "${RED}❌ Invalid selection${RESET}" ;;
  esac
}

# -------- OLLAMA MENU --------
ollama_menu() {
  echo ""
  echo "${BLUE}🦙 Ollama Options:${RESET}"
  echo ""
  echo "  1) Interactive Menu"
  echo "  2) Quick Generate"
  echo "  3) List Models"
  echo "  4) Pull Model"
  echo "  b) Back"
  echo ""
  prompt_choice "${BOLD}Choice:${RESET} "
}

run_ollama_choice() {
  local choice="$1"
  
  case "$choice" in
    1)
      echo "${DIM}Starting Ollama interactive menu...${RESET}"
      "$API_OPS_DIR/ollama_menu.sh"
      ;;
    2)
      printf "${BOLD}Enter your prompt:${RESET} "
      read -r prompt
      printf "${BOLD}Enter model (or press Enter for llama3.1:8b):${RESET} "
      read -r model
      model="${model:-llama3.1:8b}"
      [ -n "$prompt" ] && ollama run "$model" "$prompt"
      ;;
    3)
      echo "${DIM}Available models:${RESET}"
      ollama list
      ;;
    4)
      printf "${BOLD}Enter model name to pull:${RESET} "
      read -r model
      [ -n "$model" ] && ollama pull "$model"
      ;;
    [bB]) return 0 ;;
    *) echo "${RED}❌ Invalid selection${RESET}" ;;
  esac
}

# -------- PYTHON AI APIs MENU --------
python_apis_menu() {
  echo ""
  echo "${PURPLE}🐍 Python AI APIs Options:${RESET}"
  echo ""
  echo "  1) Run Agent Script"
  echo "  2) Test APIs"
  echo "  3) Run Examples"
  echo "  4) Activate AI Environment"
  echo "  b) Back"
  echo ""
  prompt_choice "${BOLD}Choice:${RESET} "
}

run_python_choice() {
  local choice="$1"
  
  case "$choice" in
    1)
      echo "${DIM}Starting ChatGPT agent...${RESET}"
      "$SCRIPT_DIR/run_agent.sh"
      ;;
    2)
      echo "${DIM}Testing AI APIs...${RESET}"
      if [ -f "$HOME/test-apis.py" ]; then
        python3 "$HOME/test-apis.py"
      else
        echo "${YELLOW}⚠️  Test script not found. Run setup first.${RESET}"
      fi
      ;;
    3)
      echo "${DIM}Running AI examples...${RESET}"
      if [ -f "$HOME/AI_EXAMPLES.py" ]; then
        python3 "$HOME/AI_EXAMPLES.py"
      else
        echo "${YELLOW}⚠️  Examples not found. Run setup first.${RESET}"
      fi
      ;;
    4)
      echo "${DIM}Activating AI environment...${RESET}"
      if [ -f "$HOME/.activate-ai-apis.sh" ]; then
        source "$HOME/.activate-ai-apis.sh"
      else
        echo "${YELLOW}⚠️  Activation script not found. Run setup first.${RESET}"
      fi
      ;;
    [bB]) return 0 ;;
    *) echo "${RED}❌ Invalid selection${RESET}" ;;
  esac
}

# -------- QUICK ACTIONS --------
quick_actions_menu() {
  echo ""
  echo "${MAGENTA}⚡ Quick Actions:${RESET}"
  echo ""
  echo "  1) Ask Grok anything"
  echo "  2) Generate with Ollama"
  echo "  3) Check API keys"
  echo "  4) Environment status"
  echo "  b) Back"
  echo ""
  prompt_choice "${BOLD}Choice:${RESET} "
}

run_quick_choice() {
  local choice="$1"
  
  case "$choice" in
    1)
      printf "${BOLD}Ask Grok:${RESET} "
      read -r prompt
      [ -n "$prompt" ] && grok --print "$prompt"
      ;;
    2)
      printf "${BOLD}Ask Ollama:${RESET} "
      read -r prompt
      [ -n "$prompt" ] && ollama run llama3.1:8b "$prompt"
      ;;
    3)
      echo "${DIM}Checking API keys...${RESET}"
      if [ -f "$SCRIPT_DIR/monitoring/check_env_keys.sh" ]; then
        "$SCRIPT_DIR/monitoring/check_env_keys.sh"
      else
        echo "${YELLOW}⚠️  Check script not found${RESET}"
      fi
      ;;
    4)
      echo "${DIM}Environment status:${RESET}"
      echo "GROK_API_KEY: ${GROK_API_KEY:+✅ Set}${GROK_API_KEY:-❌ Not set}"
      echo "XAI_API_KEY: ${XAI_API_KEY:+✅ Set}${XAI_API_KEY:-❌ Not set}"
      echo "OPENAI_API_KEY: ${OPENAI_API_KEY:+✅ Set}${OPENAI_API_KEY:-❌ Not set}"
      ;;
    [bB]) return 0 ;;
    *) echo "${RED}❌ Invalid selection${RESET}" ;;
  esac
}

# -------- MAIN LOOP --------
main_loop() {
  load_environment
  
  while true; do
    local main_choice
    main_choice="$(show_main_menu)"
    
    case "$main_choice" in
      [qQ]) echo "👋 Bye!"; exit 0 ;;
      1)
        while true; do
          local grok_choice
          grok_choice="$(grok_menu)"
          if ! run_grok_choice "$grok_choice"; then
            break
          fi
          echo ""
          read -r "?Press Enter to continue..."
        done
        ;;
      2)
        while true; do
          local ollama_choice
          ollama_choice="$(ollama_menu)"
          if ! run_ollama_choice "$ollama_choice"; then
            break
          fi
          echo ""
          read -r "?Press Enter to continue..."
        done
        ;;
      3)
        while true; do
          local python_choice
          python_choice="$(python_apis_menu)"
          if ! run_python_choice "$python_choice"; then
            break
          fi
          echo ""
          read -r "?Press Enter to continue..."
        done
        ;;
      4)
        check_all_tools
        ;;
      5)
        while true; do
          local quick_choice
          quick_choice="$(quick_actions_menu)"
          if ! run_quick_choice "$quick_choice"; then
            break
          fi
          echo ""
          read -r "?Press Enter to continue..."
        done
        ;;
      *)
        echo "${RED}❌ Invalid selection${RESET}"
        ;;
    esac
  done
}

# -------- SCRIPT EXECUTION --------
main_loop
