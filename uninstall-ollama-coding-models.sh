#!/usr/bin/env bash
set -euo pipefail
echo '==> Removing coding aliases/models'
ollama rm code || true
ollama rm code-tiny || true
ollama rm code-strong || true
ollama rm qwen2.5-coder:7b || true
ollama rm starcoder2:3b || true
