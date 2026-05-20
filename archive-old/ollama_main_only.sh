#!/usr/bin/env bash
# Ollama — Main Models Only 🦙✨ (TechnoMancer)
# Intel macOS (16 GB • CPU only) — focuses on chat, coding, vision, embeddings.
set -euo pipefail

export PATH="/usr/local/bin:/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"

LOG_DIR="$HOME/Library/Logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/ollama-main.log"
: > "$LOG_FILE"

# === Model sets (minimal) ===
CHAT=("llama3.1:8b")             # fast daily driver
CHAT_HEAVY=("qwen3:14b")         # optional heavier chat
REASON=("deepseek-r1:8b")        # balanced reasoning for 16GB
CODE=("qwen2.5-coder:7b")        # safe coding assistant
CODE_HEAVY=("qwen2.5-coder:14b") # optional heavier coding
VISION=("llava:13b")             # doc/image reasoning
EMBED=("mxbai-embed-large" "nomic-embed-text")

# === NUM_CTX defaults ===
CTX_CHAT=8192
CTX_CODE=16384
CTX_VISION=8192

color() { tput setaf "$1" 2>/dev/null || true; }
bold()  { tput bold 2>/dev/null || true; }
reset() { tput sgr0 2>/dev/null || true; }

say() { printf "%s\n" "$*"; }

need_ollama() {
  if ! command -v ollama >/dev/null 2>&1; then
    say "$(color 1)❌ Ollama not found. Install with: brew install ollama$(reset)"
    exit 1
  fi
}

installed_models() { ollama list 2>/dev/null | awk 'NR>1 {print $1}'; }
is_installed()     { installed_models | grep -qx "$1"; }

spin() {
  local pid="$1"; shift
  local msg="$*"
  local frames=(⠋ ⠙ ⠹ ⠸ ⠼ ⠴ ⠦ ⠧ ⠇ ⠏)
  local i=0
  while kill -0 "$pid" 2>/dev/null; do
    printf "\r%s %s" "${frames[$((i % ${#frames[@]}))]}" "$msg"
    ((i++))
    sleep 0.1
  done
  printf "\r%-80s\r" " "
}

pull_model() {
  local tag="$1"
  if is_installed "$tag"; then
    say "✅ Already installed: $(color 2)$tag$(reset)"; return 0
  fi
  say "⬇️  Pulling $(color 6)$tag$(reset)"
  (ollama pull "$tag" >>"$LOG_FILE" 2>&1) & local pid=$!
  spin "$pid" "pulling $tag …"; wait "$pid" || {
    say "$(color 1)✖ Pull failed: $tag (see $LOG_FILE)$(reset)"; return 1; }
  say "🎉 Pulled $(color 2)$tag$(reset)"
}

pull_set() {
  local name="$1"; shift
  eval "local arr=(\"\${$name[@]}\")"
  say "$(bold)📦 Install set:$(reset) $(color 5)$name$(reset)"
  for m in "${arr[@]}"; do pull_model "$m" || true; done
}

pull_all_main() {
  pull_set CHAT
  pull_set REASON
  pull_set CODE
  pull_set VISION
  pull_set EMBED
}

prompt_list() {
  local title="$1"; shift
  eval "local arr=(\"\${$1[@]}\")"
  say "$(bold)🧩 $title$(reset)"
  local i=0; for item in "${arr[@]}"; do ((i++)); printf "  %2d) %s\n" "$i" "$item"; done
  read -rp "Select #: " idx
  [[ -z "${idx:-}" || "$idx" -lt 1 || "$idx" -gt "${#arr[@]}" ]] && { say "Invalid"; return 1; }
  echo "${arr[$((idx-1))]}"
}

run_chat() {
  local choice; choice="$(prompt_list "CHAT models" CHAT)" || return 1
  read -rp "💬 Prompt: " p
  say "▶️  Running $choice (NUM_CTX=$CTX_CHAT)"
  OLLAMA_NUM_CTX="$CTX_CHAT" ollama run "$choice" "$p"
}
run_code() {
  local choice; choice="$(prompt_list "CODE models" CODE)" || return 1
  read -rp "💬 Prompt: " p
  say "▶️  Running $choice (NUM_CTX=$CTX_CODE)"
  OLLAMA_NUM_CTX="$CTX_CODE" ollama run "$choice" "$p"
}
run_vision() {
  local choice; choice="$(prompt_list "VISION models" VISION)" || return 1
  read -rp "💬 Describe the image/doc context: " p
  say "▶️  Running $choice (NUM_CTX=$CTX_VISION)"
  OLLAMA_NUM_CTX="$CTX_VISION" ollama run "$choice" "$p"
}

disk_usage() {
  local dir="${OLLAMA_MODELS:-$HOME/.ollama/models}"
  say "$(bold)💽 Disk usage:$(reset) $dir"
  du -sh "$dir" 2>/dev/null || say "(no models yet)"
}

banner() {
  clear || true
  cat <<'EOF'
   __  __       _        _          __  ___
  / / / /__  __(_)____  (_)__  ____/  |/  /__  ____  ____ _
 / /_/ / _ \/ / / ___/ / / _ \/ __  /|_/ / _ \/ __ \/ __ `/
/ __  /  __/ / / /__  / /  __/ /_/ /  / /  __/ / / / /_/ /
\/ /_/\___/_/_/\___/ /_/\___/\__,_/_/|_/\___/_/ /_/\__,_/
EOF
  echo "🦙  Main Models Only • Intel macOS (16 GB) • $(date)"
  echo "Log: $LOG_FILE"
  echo
}

main_menu() {
  need_ollama
  while true; do
    banner
    cat <<'EOF'
1) Install ALL main models
2) Install only CHAT
3) Install only CODING
4) Install only VISION
5) Install only EMBEDDINGS
6) (Optional) Install HEAVY chat (qwen3:14b)
7) (Optional) Install HEAVY coding (qwen2.5-coder:14b)
8) Run a quick CHAT prompt
9) Run a quick CODING prompt
10) Run a quick VISION prompt
11) Show model disk usage
0) Exit
EOF
    read -rp "Choose: " a
    case "${a:-}" in
      1) pull_all_main; read -rp "Enter to continue…" ;;
      2) pull_set CHAT; read -rp "Enter to continue…" ;;
      3) pull_set CODE; read -rp "Enter to continue…" ;;
      4) pull_set VISION; read -rp "Enter to continue…" ;;
      5) pull_set EMBED; read -rp "Enter to continue…" ;;
      6) pull_set CHAT_HEAVY; read -rp "Enter to continue…" ;;
      7) pull_set CODE_HEAVY; read -rp "Enter to continue…" ;;
      8) run_chat; read -rp "Enter to continue…" ;;
      9) run_code; read -rp "Enter to continue…" ;;
      10) run_vision; read -rp "Enter to continue…" ;;
      11) disk_usage; read -rp "Enter to continue…" ;;
      0) echo "Bye 🦙"; exit 0;;
      *) echo "Invalid"; sleep 0.6;;
    esac
  done
}

main_menu
