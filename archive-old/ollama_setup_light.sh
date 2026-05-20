#!/usr/bin/env bash
set -euo pipefail

if ! command -v ollama >/dev/null 2>&1; then
  echo "Ollama not found. Install from https://ollama.com and rerun."
  exit 1
fi

echo "==> Pulling general/chat"
ollama pull llama3.1:8b      || true
ollama pull qwen3:7b         || true  # alt general

echo "==> Pulling reasoning"
ollama pull deepseek-r1:7b   || true

echo "==> Pulling coding"
ollama pull qwen2.5-coder:7b || true
ollama pull starcoder2:3b    || true  # tiny fast backup

echo "==> Pulling vision"
ollama pull llava:7b         || true
ollama pull gemma3:4b        || true  # light vision

echo "==> Pulling embeddings"
ollama pull nomic-embed-text || true

echo "==> (Optional) Guardrails"
ollama pull llama-guard3:8b  || true

echo "==> Creating aliases"
# General
ollama cp llama3.1:8b general   || true
ollama cp qwen3:7b    general2  || true

# Reasoning
ollama cp deepseek-r1:7b reason || true

# Coding
ollama cp qwen2.5-coder:7b code || true
ollama cp starcoder2:3b    code-tiny || true

# Vision
ollama cp llava:7b    vis      || true
ollama cp gemma3:4b   vis-light|| true

# Embedding
ollama cp nomic-embed-text embed || true

# Safety
ollama cp llama-guard3:8b guard || true

echo "==> Done."
echo "Try:"
echo "  ollama run general   \"You are TechnoMancer.\""
echo "  ollama run reason    \"Show steps for this puzzle...\""
echo "  ollama run code      \"Write a Python function...\""
