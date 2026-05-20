#!/usr/bin/env bash
set -euo pipefail
echo '==> Removing embeddings aliases/models'
ollama rm embed || true
ollama rm embed-large || true
ollama rm embed-multilingual || true
ollama rm nomic-embed-text || true
ollama rm mxbai-embed-large || true
ollama rm bge-m3 || true
