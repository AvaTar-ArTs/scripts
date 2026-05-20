#!/usr/bin/env bash
set -euo pipefail
echo '==> Removing reasoning aliases/models'
ollama rm reason || true
ollama rm reason-big || true
ollama rm reason-14b || true
ollama rm deepseek-r1:7b || true
