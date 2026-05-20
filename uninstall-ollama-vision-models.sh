#!/usr/bin/env bash
set -euo pipefail
echo '==> Removing vision aliases/models'
ollama rm vis || true
ollama rm vis-light || true
ollama rm vis-llama || true
ollama rm llava:7b || true
ollama rm gemma3:4b || true
