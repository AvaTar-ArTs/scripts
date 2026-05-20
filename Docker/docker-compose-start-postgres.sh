#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
docker compose -f compose.postgres.local.yml up -d
open http://localhost:5678
