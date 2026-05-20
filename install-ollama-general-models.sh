#!/usr/bin/env bash
set -euo pipefail
if ! command -v ollama >/dev/null 2>&1; then echo 'Install Ollama first: https://ollama.com'; exit 1; fi
echo '==> Installing general models'
echo 'pull llama3.1:8b'
ollama pull llama3.1:8b || true
echo 'alias general -> llama3.1:8b'
ollama cp llama3.1:8b general || true
echo 'pull qwen3:7b'
ollama pull qwen3:7b || true
echo 'alias general2 -> qwen3:7b'
ollama cp qwen3:7b general2 || true
echo 'pull mistral:7b'
ollama pull mistral:7b || true
echo 'alias general-fast -> mistral:7b'
ollama cp mistral:7b general-fast || true
