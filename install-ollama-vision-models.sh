#!/usr/bin/env bash
set -euo pipefail
if ! command -v ollama >/dev/null 2>&1; then echo 'Install Ollama first: https://ollama.com'; exit 1; fi
echo '==> Installing vision models'
echo 'pull llava:7b'
ollama pull llava:7b || true
echo 'alias vis -> llava:7b'
ollama cp llava:7b vis || true
echo 'pull gemma3:4b'
ollama pull gemma3:4b || true
echo 'alias vis-light -> gemma3:4b'
ollama cp gemma3:4b vis-light || true
