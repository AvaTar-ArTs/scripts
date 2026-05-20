#!/usr/bin/env bash
set -euo pipefail

# v2 replacement for old x-cmd key sync.
# This script validates your API keys and current CLIs without depending on x-cmd.

ENV_FILE="${ENV_FILE:-$HOME/.env.d/llm-apis.env}"

require_cmd() {
  command -v "$1" >/dev/null 2>&1
}

mask() {
  local v="$1"
  local n=${#v}
  if [ "$n" -le 8 ]; then
    printf '********'
  else
    printf '%s****%s' "${v:0:4}" "${v:n-4:4}"
  fi
}

echo "== LLM key + CLI check (x-cmd-free) =="
echo "Env file: $ENV_FILE"

if [ -f "$ENV_FILE" ]; then
  # shellcheck disable=SC1090
  source "$ENV_FILE"
  echo "Loaded env file."
else
  echo "WARN: env file not found; checking current shell env only."
fi

check_key() {
  local name="$1"
  local value="${!name:-}"
  if [ -n "$value" ]; then
    echo "OK   $name=$(mask "$value")"
  else
    echo "MISS $name"
  fi
}

echo
check_key OPENAI_API_KEY
check_key ANTHROPIC_API_KEY
check_key GEMINI_API_KEY
check_key GROK_API_KEY
check_key XAI_API_KEY
check_key MISTRAL_API_KEY
check_key DEEPSEEK_API_KEY
check_key GROQ_API_KEY
check_key PERPLEXITY_API_KEY

echo
printf "CLI checks:\n"
if require_cmd openai; then echo "OK   openai -> $(command -v openai)"; else echo "MISS openai"; fi
if require_cmd gemini; then echo "OK   gemini -> $(command -v gemini)"; else echo "MISS gemini"; fi
if require_cmd qwen; then echo "OK   qwen -> $(command -v qwen)"; else echo "MISS qwen"; fi
if require_cmd codex; then echo "OK   codex -> $(command -v codex)"; else echo "MISS codex"; fi
if require_cmd grok; then echo "OK   grok -> $(command -v grok)"; else echo "MISS grok"; fi

echo
cat <<'EOT'
Next step examples:
  source ~/.env.d/llm-apis.env
  openai models.list          # if openai CLI is configured
  gemini --help               # if gemini CLI is installed
EOT
