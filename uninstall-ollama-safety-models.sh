#!/usr/bin/env bash
set -euo pipefail
echo '==> Removing safety aliases/models'
ollama rm guard || true
ollama rm guard-light || true
ollama rm guard-granite || true
ollama rm llama-guard3:8b || true
ollama rm shieldgemma:2b || true
ollama rm granite3-guardian:2b || true
