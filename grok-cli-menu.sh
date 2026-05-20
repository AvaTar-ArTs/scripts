#!/usr/bin/env bash
# grok_menu.sh — Interactive Grok CLI Menu System
# Intel macOS • zsh • Integrates with your existing .env.d system
# Requires: Node.js, Grok CLI, jq (brew install jq)

set -eu

# -------- Colors --------
if command -v tput >/dev/null 2>&1; then
  BOLD="$(tput bold)"; DIM="$(tput dim)"; RESET="$(tput sgr0)"
  GREEN="$(tput setaf 2)"; RED="$(tput setaf 1)"; CYAN="$(tput setaf 6)"
  YELLOW="$(tput setaf 3)"; BLUE="$(tput setaf 4)"; PURPLE="$(tput setaf 5)"
else
  BOLD=""; DIM=""; RESET=""; GREEN=""; RED=""; CYAN=""; YELLOW=""; BLUE=""; PURPLE=""
fi

# -------- Configuration --------
GROK_MODELS=(
  "grok-2" "grok-code-fast-1" "grok-4-latest"
)

# -------- Trap --------
trap 'echo "\n${DIM}↩ interrupted${RESET}"; exit 1' INT

# -------- HELPERS --------
print_header() {
  echo "${CYAN}======================================${RESET}"
  echo "  🤖 ${BOLD}Grok CLI Menu${RESET} — $(date '+%H:%M:%S')"
  echo "${CYAN}======================================${RESET}"
}

check_grok() {
  if ! command -v grok &> /dev/null; then
    echo "${RED}❌ Grok CLI not found${RESET}"
    echo "${DIM}Install with: npm install -g @vibe-kit/grok-cli${RESET}"
    exit 1
  fi
}

load_environment() {
  echo "${DIM}Loading environment from ~/.env.d...${RESET}"
  if [ -f "$HOME/.env.d/loader.sh" ]; then
    source "$HOME/.env.d/loader.sh" llm-apis 2>/dev/null || true
  fi
  
  # Set GROK_API_KEY from XAI_API_KEY
  if [ -n "$XAI_API_KEY" ]; then
    export GROK_API_KEY="$XAI_API_KEY"
    echo "${GREEN}✅ API key loaded${RESET}"
  else
    echo "${YELLOW}⚠️  No XAI_API_KEY found${RESET}"
    echo "${DIM}Make sure your API key is in ~/.env.d/llm-apis.env${RESET}"
  fi
}

prompt_choice() {
  local prompt="$1"
  printf "%s" "$prompt"
  read -r choice
  echo "$choice"
}

# -------- GROK OPERATIONS --------
run_grok_prompt() {
  local model="$1"
  local prompt="$2"
  
  echo "${DIM}Running Grok with model: $model${RESET}"
  echo "${CYAN}Prompt: $prompt${RESET}"
  echo ""
  
  grok --model "$model" --print "$prompt"
}

run_grok_interactive() {
  local model="$1"
  
  echo "${DIM}Starting interactive Grok session with model: $model${RESET}"
  echo "${YELLOW}Note: Interactive mode may have limitations in this environment${RESET}"
  echo ""
  
  grok --model "$model"
}

run_grok_file() {
  local model="$1"
  local file="$2"
  
  if [ ! -f "$file" ]; then
    echo "${RED}❌ File not found: $file${RESET}"
    return 1
  fi
  
  local content
  content=$(cat "$file")
  local prompt="Analyze this file and provide insights: $content"
  
  run_grok_prompt "$model" "$prompt"
}

run_grok_code_review() {
  local model="$1"
  local file="$2"
  
  if [ ! -f "$file" ]; then
    echo "${RED}❌ File not found: $file${RESET}"
    return 1
  fi
  
  local content
  content=$(cat "$file")
  local prompt="Review this code for bugs, improvements, and best practices: $content"
  
  run_grok_prompt "$model" "$prompt"
}

run_grok_git_analysis() {
  local model="$1"
  
  if ! command -v git &> /dev/null; then
    echo "${RED}❌ Git not found${RESET}"
    return 1
  fi
  
  local git_status
  git_status=$(git status --porcelain 2>/dev/null || echo "Not a git repository")
  local git_log
  git_log=$(git log --oneline -5 2>/dev/null || echo "No git history")
  
  local prompt="Analyze this git repository status and recent commits. Provide insights and suggestions:

Git Status:
$git_status

Recent Commits:
$git_log"
  
  run_grok_prompt "$model" "$prompt"
}

# -------- MENU FUNCTIONS --------
choose_model() {
  print_header
  echo "Available Grok Models:"
  for i in "${!GROK_MODELS[@]}"; do
    printf "  %d) %s\n" $((i+1)) "${GROK_MODELS[$i]}"
  done
  echo "  b) Back   q) Quit"
  prompt_choice "${BOLD}Choice:${RESET} "
}

choose_operation() {
  local model="$1"
  print_header
  echo "Grok Operations for model: ${CYAN}$model${RESET}"
  echo ""
  echo "  1) Quick Prompt"
  echo "  2) Interactive Session"
  echo "  3) Analyze File"
  echo "  4) Code Review"
  echo "  5) Git Analysis"
  echo "  6) Custom Model Selection"
  echo "  b) Back   q) Quit"
  prompt_choice "${BOLD}Choice:${RESET} "
}

get_file_path() {
  printf "${BOLD}Enter file path:${RESET} "
  read -r filepath
  echo "$filepath"
}

get_prompt() {
  printf "${BOLD}Enter your prompt:${RESET} "
  read -r prompt
  echo "$prompt"
}

# -------- MAIN LOOP --------
main_loop() {
  check_grok
  load_environment
  
  local current_model="grok-2"
  
  while true; do
    local op_choice
    op_choice="$(choose_operation "$current_model")"
    
    case "$op_choice" in
      [qQ]) echo "👋 Bye!"; exit 0 ;;
      [bB]) break ;;
      1)
        local prompt
        prompt="$(get_prompt)"
        [ -n "$prompt" ] && run_grok_prompt "$current_model" "$prompt"
        ;;
      2)
        run_grok_interactive "$current_model"
        ;;
      3)
        local file
        file="$(get_file_path)"
        [ -n "$file" ] && run_grok_file "$current_model" "$file"
        ;;
      4)
        local file
        file="$(get_file_path)"
        [ -n "$file" ] && run_grok_code_review "$current_model" "$file"
        ;;
      5)
        run_grok_git_analysis "$current_model"
        ;;
      6)
        local model_choice
        model_choice="$(choose_model)"
        case "$model_choice" in
          [qQ]) echo "👋 Bye!"; exit 0 ;;
          [bB]) continue ;;
          *)
            if [[ "$model_choice" =~ ^[0-9]+$ ]] && [ "$model_choice" -ge 1 ] && [ "$model_choice" -le ${#GROK_MODELS[@]} ]; then
              current_model="${GROK_MODELS[$((model_choice-1))]}"
              echo "${GREEN}✅ Model changed to: $current_model${RESET}"
            else
              echo "${RED}❌ Invalid selection${RESET}"
            fi
            ;;
        esac
        ;;
      *)
        echo "${RED}❌ Invalid selection${RESET}"
        ;;
    esac
    
    echo ""
    read -r "?Press Enter to continue (${BOLD}q${RESET} to quit): " again
    [[ "${again:-}" =~ ^[qQ]$ ]] && echo "👋 Bye!" && exit 0
  done
}

# -------- QUICK ACCESS FUNCTIONS --------
quick_prompt() {
  local prompt="$1"
  local model="${2:-grok-2}"
  
  check_grok
  load_environment
  run_grok_prompt "$model" "$prompt"
}

quick_file() {
  local file="$1"
  local model="${2:-grok-2}"
  
  check_grok
  load_environment
  run_grok_file "$model" "$file"
}

# -------- SCRIPT EXECUTION --------
if [ $# -eq 0 ]; then
  main_loop
elif [ "$1" = "prompt" ] && [ -n "$2" ]; then
  quick_prompt "$2" "$3"
elif [ "$1" = "file" ] && [ -n "$2" ]; then
  quick_file "$2" "$3"
else
  echo "Usage:"
  echo "  $0                    # Interactive menu"
  echo "  $0 prompt 'text'      # Quick prompt"
  echo "  $0 file path [model]  # Analyze file"
  exit 1
fi
