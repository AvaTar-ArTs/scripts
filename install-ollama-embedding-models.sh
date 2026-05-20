#!/usr/bin/env bash
set -euo pipefail
if ! command -v ollama >/dev/null 2>&1; then echo 'Install Ollama first: https://ollama.com'; exit 1; fi
echo '==> Installing embeddings models'
echo 'pull nomic-embed-text'
ollama pull nomic-embed-text || true
echo 'alias embed -> nomic-embed-text'
ollama cp nomic-embed-text embed || true
echo 'pull mxbai-embed-large'
ollama pull mxbai-embed-large || true
echo 'alias embed-large -> mxbai-embed-large'
ollama cp mxbai-embed-large embed-large || true
echo 'pull bge-m3'
ollama pull bge-m3 || true
echo 'alias embed-multilingual -> bge-m3'
ollama cp bge-m3 embed-multilingual || true
