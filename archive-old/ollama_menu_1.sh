#!/usr/bin/env bash
# Ollama Model Manager (Intel macOS, 16 GB) — interactive TUI
# - Install (pull) recommended models
# - Uninstall (remove) models/aliases
# - Create / remove friendly aliases
# - Run a quick prompt against a chosen model/alias
#
# Safe for CPU-only; defaults sized for 16 GB RAM.

set -euo pipefail

# ---------- Config ----------
# Core sets sized for your machine
GENERAL=("llama3.1:8b" "qwen3:7b")
REASON=("deepseek-r1:7b")
CODING=("qwen2.5-coder:7b" "starcoder2:3b")
VISION=("llava:7b" "gemma3:4b")
EMBED=("nomic-embed-text")
SAFETY=("llama-guard3:8b")

# Aliases mapping: "source_tag alias_name"
ALIASES=(
  "llama3.1:8b general"
  "qwen3:7b general2"
  "deepseek-r1:7b reason"
  "qwen2.5-coder:7b code"
  "starcoder2:3b code-tiny"
  "llava:7b vis"
  "gemma3:4b vis-light"
  "nomic-embed-text embed"
  "llama-guard3:8b guard"
)

# ---------- Helpers ----------
need_ollama() {
  if ! command -v ollama >/dev/null 2>&1; then
    echo "Ollama not found. Install from https://ollama.com and rerun." >&2
    exit 1
  fi
}

pause() { read -rp "Press Enter to continue..."; }

pick_from_list() {
  # usage: pick_from_list "title" arr_name
  local title="$1"; shift
  local arr_name="$1"; shift || true
  local -n ARR="$arr_name"
  echo "==> $title"
  local i=1
  for item in "${ARR[@]}"; do
    printf "  %2d) %s\n" "$i" "$item"
    ((i++))
  done
  read -rp "Select item number: " idx
  if [[ -z "$idx" || "$idx" -lt 1 || "$idx" -gt "${#ARR[@]}" ]]; then
    echo "Invalid selection"; return 1
  fi
  echo "${ARR[$((idx-1))]}"
}

# ---------- Actions ----------
pull_set() {
  need_ollama
  local setname="$1"; shift
  local -n SET="$setname"
  echo "==> Pulling set: $setname"
  for m in "${SET[@]}"; do
    echo "---- pulling $m"
    ollama pull "$m" || echo "Failed: $m"
  done
}

pull_all() {
  pull_set GENERAL
  pull_set REASON
  pull_set CODING
  pull_set VISION
  pull_set EMBED
  pull_set SAFETY
}

uninstall_menu() {
  need_ollama
  echo "==> Currently installed models:"
  ollama list || true
  echo ""
  read -rp "Type the exact model/alias to remove (or leave blank to cancel): " tag
  if [[ -n "${tag:-}" ]]; then
    echo "Removing $tag ..."
    ollama rm "$tag" && echo "Removed $tag."
  else
    echo "Cancelled."
  fi
}

create_aliases() {
  need_ollama
  echo "==> Creating aliases"
  for pair in "${ALIASES[@]}"; do
    src="${pair%% *}"; alias="${pair##* }"
    echo "  $alias -> $src"
    ollama cp "$src" "$alias" || true
  done
  echo "Done."
}

remove_aliases() {
  need_ollama
  echo "==> Removing aliases"
  for pair in "${ALIASES[@]}"; do
    alias="${pair##* }"
    echo "  removing $alias"
    ollama rm "$alias" || true
  done
  echo "Done."
}

run_prompt() {
  need_ollama
  echo "==> Choose a model or alias to run"
  # Build a combined list from aliases + core tags
  local OPTIONS=()
  for pair in "${ALIASES[@]}"; do OPTIONS+=("${pair##* }"); done
  OPTIONS+=("${GENERAL[@]}" "${REASON[@]}" "${CODING[@]}" "${VISION[@]}" "${EMBED[@]}" "${SAFETY[@]}")
  local varname="OPTIONS"
  local choice
  choice=$(pick_from_list "Models & Aliases" varname) || return 1
  echo ""
  read -rp "Enter your prompt: " user_prompt
  echo ""
  echo "Running '$choice' ... (Ctrl+C to stop)"
  # Use --verbose to show system info if desired; keep simple here
  OLLAMA_NUM_CTX=4096 ollama run "$choice" "$user_prompt"
}

quick_lists() {
  echo "==> Recommended sets:"
  printf "  GENERAL: %s\n" "${GENERAL[*]}"
  printf "  REASON:  %s\n" "${REASON[*]}"
  printf "  CODING:  %s\n" "${CODING[*]}"
  printf "  VISION:  %s\n" "${VISION[*]}"
  printf "  EMBED:   %s\n" "${EMBED[*]}"
  printf "  SAFETY:  %s\n" "${SAFETY[*]}"
  echo "==> Aliases:"
  for pair in "${ALIASES[@]}"; do echo "  ${pair##* } -> ${pair%% *}"; done
}

# ---------- Menu ----------
main_menu() {
  need_ollama
  while true; do
    clear || true
    cat <<'EOF'
╔════════════════════════════════════════╗
║     Ollama Model Manager (TechnoMancer)║
╠════════════════════════════════════════╣
║ 1) Install ALL recommended models      ║
║ 2) Install a specific set              ║
║ 3) Create aliases                      ║
║ 4) Remove aliases                      ║
║ 5) Uninstall a model/alias             ║
║ 6) Run a prompt with a chosen model    ║
║ 7) Show recommended sets/aliases       ║
║ 0) Exit                                ║
╚════════════════════════════════════════╝
EOF
    read -rp "Choose an option: " ans
    case "${ans:-}" in
      1) pull_all; pause;;
      2)
         echo "Select set: 1) GENERAL 2) REASON 3) CODING 4) VISION 5) EMBED 6) SAFETY"
         read -rp "Set #: " s
         case "${s:-}" in
           1) pull_set GENERAL;;
           2) pull_set REASON;;
           3) pull_set CODING;;
           4) pull_set VISION;;
           5) pull_set EMBED;;
           6) pull_set SAFETY;;
           *) echo "Invalid";;
         esac
         pause;;
      3) create_aliases; pause;;
      4) remove_aliases; pause;;
      5) uninstall_menu; pause;;
      6) run_prompt; pause;;
      7) quick_lists; pause;;
      0) exit 0;;
      *) echo "Invalid option"; pause;;
    esac
  done
}

main_menu
