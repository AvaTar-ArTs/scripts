#!/usr/bin/env bash
# ollama_prompt.sh — interactively choose a model + send a prompt
# Works on Intel macOS with Ollama running locally.

set -euo pipefail

# List of best-pick models for your Mac
MODELS=(
  "llama3.1:8b-instruct"
  "qwen2.5:14b-instruct"
  "deepseek-r1:8b"
  "deepseek-r1:14b"
  "qwen2.5-coder:7b"
  "qwen2.5-coder:14b"
  "llava:13b"
  "mxbai-embed-large"
  "nomic-embed-text"
  "mistral-nemo:12b-instruct"
  "phi3:mini"
)

echo "==============================="
echo "   🦙 Ollama Prompt Runner"
echo "==============================="
echo "Select a model:"

# Show model menu
for i in "${!MODELS[@]}"; do
  printf "%2d) %s\n" $((i+1)) "${MODELS[$i]}"
done

# Read model choice
read -rp "Enter number [1-${#MODELS[@]}]: " choice
if ! [[ "$choice" =~ ^[0-9]+$ ]] || (( choice < 1 || choice > ${#MODELS[@]} )); then
  echo "❌ Invalid choice"
  exit 1
fi

MODEL="${MODELS[$((choice-1))]}"

# Read user prompt
echo ""
read -rp "Enter your prompt: " user_prompt
echo ""

# Send to Ollama API
echo "⚡ Running model: $MODEL"
echo "==============================="
curl -s http://localhost:11434/api/generate -d "{
  \"model\": \"$MODEL\",
  \"prompt\": \"$user_prompt\"
}" | jq -r .response
echo "==============================="

