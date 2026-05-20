#!/usr/bin/env bash
set -euo pipefail
if ! command -v ollama >/dev/null 2>&1; then echo 'Install Ollama first: https://ollama.com'; exit 1; fi
echo '==> Installing safety models'
echo 'pull llama-guard3:8b'
ollama pull llama-guard3:8b || true
echo 'alias guard -> llama-guard3:8b'
ollama cp llama-guard3:8b guard || true
echo 'pull shieldgemma:2b'
ollama pull shieldgemma:2b || true
echo 'alias guard-light -> shieldgemma:2b'
ollama cp shieldgemma:2b guard-light || true
echo 'pull granite3-guardian:2b'
ollama pull granite3-guardian:2b || true
echo 'alias guard-granite -> granite3-guardian:2b'
ollama cp granite3-guardian:2b guard-granite || true
