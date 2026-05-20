#!/usr/bin/env bash
set -euo pipefail
echo '==> Removing general aliases/models'
ollama rm general || true
ollama rm general2 || true
ollama rm general-fast || true
ollama rm llama3.1:8b || true
ollama rm qwen3:7b || true
ollama rm mistral:7b || true
