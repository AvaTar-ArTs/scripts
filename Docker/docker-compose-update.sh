#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
STACK="${1:-compose.postgres.local.yml}"
docker compose -f "$STACK" pull
docker compose -f "$STACK" up -d
