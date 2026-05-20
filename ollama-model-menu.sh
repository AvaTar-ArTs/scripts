#!/usr/bin/env bash
# ollama_menu.sh — Category → Model → Prompt (loops until you quit)
# Intel macOS • zsh • Requires: jq (brew install jq)
# Ollama server: http://localhost:11434

set -eu

API="http://localhost:11434"

# -------- Colors --------
if command -v tput >/dev/null 2>&1; then
  BOLD="$(tput bold)"; DIM="$(tput dim)"; RESET="$(tput sgr0)"
  GREEN="$(tput setaf 2)"; RED="$(tput setaf 1)"; CYAN="$(tput setaf 6)"
else
  BOLD=""; DIM=""; RESET=""; GREEN=""; RED=""; CYAN=""
fi

# -------- Trap --------
trap 'echo "\n${DIM}↩ interrupted${RESET}"; exit 1' INT

# -------- CATEGORIES & MODELS (zsh assoc arrays) --------
typeset -A MODELS_CHAT=(
  1 "llama3.1:8b-instruct"
  2 "qwen2.5:14b-instruct"
)
typeset -A MODELS_REASONING=(
  1 "deepseek-r1:8b"
  2 "deepseek-r1:14b"
)
typeset -A MODELS_CODING=(
  1 "qwen2.5-coder:7b"
  2 "qwen2.5-coder:14b"
)
typeset -A MODELS_VISION=(
  1 "llava:13b"
)
typeset -A MODELS_EMB=(
  1 "mxbai-embed-large"
  2 "nomic-embed-text"
)
typeset -A MODELS_LONG=(
  1 "mistral-nemo:12b-instruct"
)
typeset -A MODELS_ULTRA=(
  1 "phi3:mini"
)

# -------- HELPERS --------
print_header() {
  echo "${CYAN}======================================${RESET}"
  echo "  🦙 ${BOLD}Ollama Menu${RESET} — $(date '+%H:%M:%S')"
  echo "${CYAN}======================================${RESET}"
}

ensure_server() {
  if ! curl -sS "${API}/api/tags" >/dev/null 2>&1; then
    echo "${RED}❌ Ollama server not responding at ${API}${RESET}"
    echo "${DIM}Try: brew services start ollama  # or: ollama serve &${RESET}"
    exit 1
  fi
}

prompt_choice() {
  local prompt="$1"
  printf "%s" "$prompt"
  read -r choice
  echo "$choice"
}

choose_category() {
  print_header
  cat <<EOF
Pick a category:
  1) [chat]
  2) [reasoning]
  3) [coding]
  4) [vision]
  5) [embeddings]
  6) [long-context]
  7) [ultra-light]
  q) Quit
EOF
  prompt_choice "${BOLD}Choice:${RESET} "
}

# zsh: pass the *name* of an assoc array; use ${(kP)name} for keys, ${(P)name[key]} for values
choose_model_from_map() {
  local mapname="$1"
  print_header
  echo "Models:"
  local -a keys
  keys=(${(On)${(kP)mapname}})  # numeric sort
  for i in "${keys[@]}"; do
    local val="${(P)mapname[$i]}"
    printf "  %d) %s\n" "$i" "$val"
  done
  echo "  b) Back   q) Quit"
  prompt_choice "${BOLD}Choice:${RESET} "
}

ensure_model() {
  local model="$1"
  if ! ollama show "$model" >/dev/null 2>&1; then
    echo "${DIM}… pulling model: ${model}${RESET}"
    ollama pull "$model" || {
      echo "${RED}Failed to pull ${model}${RESET}"
      return 1
    }
  fi
}

# -------- API ACTIONS --------
run_generate() {
  local model="$1" prompt="$2"
  curl -s "${API}/api/generate" \
    -H "Content-Type: application/json" \
    -d "$(jq -nc --arg m "$model" --arg p "$prompt" '{model:$m, prompt:$p, stream:false}')" \
  | jq -r '.response // .error'
}

run_embeddings() {
  local model="$1" text="$2"
  curl -s "${API}/api/embeddings" \
    -H "Content-Type: application/json" \
    -d "$(jq -nc --arg m "$model" --arg p "$text" '{model:$m, prompt:$p}')" \
  | jq
}

run_vision() {
  local model="$1" prompt="$2" image="$3"
  if [[ -z "${image// }" || ! -f "$image" ]]; then
    echo "${RED}❌ Image not found:${RESET} $image"
    return 1
  fi
  local b64; b64="$(base64 -i "$image")"
  curl -s "${API}/api/generate" \
    -H "Content-Type: application/json" \
    -d "$(jq -nc --arg m "$model" --arg p "$prompt" --arg img "$b64" \
         '{model:$m, prompt:$p, images:[$img], stream:false}')" \
  | jq -r '.response // .error'
}

# -------- MAIN LOOP --------
main_loop() {
  ensure_server

  while true; do
    local cat_choice mapname category
    cat_choice="$(choose_category)"
    case "$cat_choice" in
      [qQ]) echo "👋 Bye!"; exit 0 ;;
      1) category="chat";         mapname="MODELS_CHAT" ;;
      2) category="reasoning";    mapname="MODELS_REASONING" ;;
      3) category="coding";       mapname="MODELS_CODING" ;;
      4) category="vision";       mapname="MODELS_VISION" ;;
      5) category="embeddings";   mapname="MODELS_EMB" ;;
      6) category="long-context"; mapname="MODELS_LONG" ;;
      7) category="ultra-light";  mapname="MODELS_ULTRA" ;;
      *) echo "${RED}❌ Invalid category${RESET}"; continue ;;
    esac

    while true; do
      local mdl_choice
      mdl_choice="$(choose_model_from_map "$mapname")"
      [[ "$mdl_choice" =~ ^[qQ]$ ]] && echo "👋 Bye!" && exit 0
      [[ "$mdl_choice" =~ ^[bB]$ ]] && break

      # Validate choice
      if ! [[ "$mdl_choice" =~ '^[0-9]+$' ]]; then
        echo "${RED}❌ Invalid selection${RESET}"
        continue
      fi
      local val="${(P)mapname[$mdl_choice]:-}"
      if [[ -z "$val" ]]; then
        echo "${RED}❌ Invalid selection${RESET}"
        continue
      fi

      local MODEL="$val"
      ensure_model "$MODEL" || continue

      echo ""
      printf "${BOLD}Enter your prompt:${RESET} "
      local USER_PROMPT
      read -r USER_PROMPT
      echo ""

      case "$category" in
        embeddings)
          echo "⚡ ${BOLD}Embeddings →${RESET} $MODEL"
          run_embeddings "$MODEL" "$USER_PROMPT"
          ;;
        vision)
          local IMG
          printf "${BOLD}Image path (blank to cancel):${RESET} "
          read -r IMG
          [[ -z "${IMG// }" ]] && { echo "${DIM}↩ cancelled${RESET}"; continue; }
          echo "⚡ ${BOLD}Vision →${RESET} $MODEL"
          run_vision "$MODEL" "$USER_PROMPT" "$IMG"
          ;;
        *)
          echo "⚡ ${BOLD}Generate →${RESET} $MODEL"
          run_generate "$MODEL" "$USER_PROMPT"
          ;;
      esac

      echo
      read -r "?Press Enter to continue (${BOLD}q${RESET} to quit): " again
      [[ "${again:-}" =~ ^[qQ]$ ]] && echo "👋 Bye!" && exit 0
    done
  done
}

main_loop
