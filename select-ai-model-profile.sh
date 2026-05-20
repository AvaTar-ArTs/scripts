#!/usr/bin/env bash
# model_picker.sh — Category → Model picker for multi-provider models (macOS / zsh)
# Copies "<provider>:<model_id>" to clipboard via pbcopy.

set -eu

print_header() {
  echo "======================================"
  echo "  🤖 Model Picker — $(date '+%H:%M:%S')"
  echo "======================================"
}

# ---- CATEGORIES -> MODELS (Display | Provider | ModelID) ----
CHAT_MODELS=(
  "GPT-4o mini | openai | gpt-4o-mini"
  "GPT-4o | openai | gpt-4o"
  "GPT-4.1 | openai | gpt-4.1"
  "GPT-5 | openai | gpt-5"
  "Claude 3.5 Haiku | anthropic | claude-3.5-haiku"
  "Claude 4.1 Opus | anthropic | claude-4.1-opus"
  "Gemini 2.0 Flash | google | gemini-2.0-flash"
  "Gemini 2.5 Pro | google | gemini-2.5-pro"
)

REASON_MODELS=(
  "GPT-5 Reasoning | openai | gpt-5-reasoning"
  "DeepSeek-V3 | together | deepseek-v3"
  "DeepSeek-R1 | together | deepseek-r1"
  "Sonar Reasoning | perplexity | sonar-reasoning"
  "Sonar Reasoning Pro | perplexity | sonar-reasoning-pro"
)

CODING_MODELS=(
  "Grok Code Fast 1 | xai | grok-code-fast-1"
  "Qwen3-32B | groq | qwen3-32b"
  "Qwen3-235B | together | qwen3-235b-a22b-instruct"
  "Codestral (Mistral) | mistral | codestral"
)

VISION_MODELS=(
  "GPT-4.1 nano | openai | gpt-4.1-nano"
  "GPT-4.1 mini | openai | gpt-4.1-mini"
  "Gemini 2.5 Flash Lite | google | gemini-2.5-flash-lite"
  "LLaVA | together | llava"
)

LONGCTX_MODELS=(
  "Mistral Nemo | mistral | mistral-nemo"
  "Mistral Large | mistral | mistral-large"
  "Mistral Medium | mistral | mistral-medium"
  "Llama 3.1 405B (Together) | together | llama-3.1-405b"
)

SPEED_MODELS=(
  "GPT-3.5 nano | openai | gpt-3.5-nano"
  "GPT-3.5 mini | openai | gpt-3.5-mini"
  "Ray-1 | raycast | ray-1"
  "Ray-1 mini | raycast | ray-1-mini"
  "Grok-3 Mini Beta | xai | grok-3-mini-beta"
)

choose_category() {
  print_header
  cat <<EOF
Pick a category:
  1) 📝 Chat / Writing
  2) 🔍 Reasoning / Math
  3) 💻 Coding
  4) 👁  Vision / Multimodal
  5) 🧠 Long Context
  6) ⚡ Ultra-Light / Speed
  q) Quit
EOF
  printf "Choice: "
  read -r c
  echo "$c"
}

show_models() {
  local -a arr=("${(@P)1}")  # expand array by name
  print_header
  echo "Models:"
  local i=1
  for line in "${arr[@]}"; do
    echo "  $i) $line"
    ((i++))
  done
  echo "  b) Back   q) Quit"
  printf "Choice: "
}

handle_pick() {
  local line="$1"
  # split on " | "
  local label provider mid
  IFS='|' read -r label provider mid <<< "$line"
  provider="${provider// /}"
  mid="${mid// /}"
  local final="${provider}:${mid}"
  printf "%s" "$final" | pbcopy
  echo ""
  echo "✅ Selected: ${${label%% }## }"
  echo "🔗 ID: $final  (copied to clipboard)"
  echo ""
}

while true; do
  cat_choice=$(choose_category)
  case "$cat_choice" in
    q|Q) echo "👋 Bye"; exit 0 ;;
    1) CAT="CHAT_MODELS" ;;
    2) CAT="REASON_MODELS" ;;
    3) CAT="CODING_MODELS" ;;
    4) CAT="VISION_MODELS" ;;
    5) CAT="LONGCTX_MODELS" ;;
    6) CAT="SPEED_MODELS" ;;
    *) echo "❌ Invalid"; continue ;;
  esac

  while true; do
    show_models "$CAT"
    read -r m
    [[ "$m" == [qQ] ]] && echo "👋 Bye" && exit 0
    [[ "$m" == [bB] ]] && break

    local -a arr=("${(@P)CAT}")
    if ! [[ "$m" =~ '^[0-9]+$' ]] || (( m < 1 || m > ${#arr[@]} )); then
      echo "❌ Invalid"
      continue
    fi
    handle_pick "${arr[$m]}"
    printf "Press Enter to pick again (q to quit): "
    read -r again
    [[ "$again" == [qQ] ]] && echo "👋 Bye" && exit 0
  done
done
