#!/usr/bin/env bash
set -euo pipefail
if ! command -v ollama >/dev/null 2>&1; then echo 'Install Ollama first: https://ollama.com'; exit 1; fi
echo '==> Installing reasoning models'
echo 'pull deepseek-r1:7b'
ollama pull deepseek-r1:7b || true
echo 'alias reason -> deepseek-r1:7b'
ollama cp deepseek-r1:7b reason || true
