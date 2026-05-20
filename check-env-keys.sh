#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail

# check_env_keys.sh
# Safely identify missing API keys in ~/.env.master

ENV_FILE="$HOME/.env.master"

if [[ ! -f "$ENV_FILE" ]]; then
  echo "Error: $ENV_FILE not found."
  exit 1
fi

echo "🔍 Checking for missing API keys in $ENV_FILE..."
echo

grep -E '^[A-Z0-9_]+= *$' "$ENV_FILE" | while IFS= read -r line; do
  key=$(echo "$line" | cut -d= -f1)
  comment=$(grep "^$key=" "$ENV_FILE" | sed -n 's/.*# *//p')
  printf "❌ Missing key: %-35s | Info: %s\n" "$key" "$comment"
done

echo
echo "✅ Done. Add your missing keys manually where indicated."
