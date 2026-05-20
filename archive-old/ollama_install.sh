#!/usr/bin/env bash
set -euo pipefail
if ! command -v ollama >/dev/null 2>&1; then echo 'Install Ollama first: https://ollama.com'; exit 1; fi
echo '==> Installing coding models'
echo 'pull qwen2.5-coder:7b'
ollama pull qwen2.5-coder:7b || true
echo 'alias code -> qwen2.5-coder:7b'
ollama cp qwen2.5-coder:7b code || true
echo 'pull starcoder2:3b'
ollama pull starcoder2:3b || true
echo 'alias code-tiny -> starcoder2:3b'
ollama cp starcoder2:3b code-tiny || true
