#!/usr/bin/env bash
set -euo pipefail
log(){ printf "\n[setup] %s\n" "$*" >&2; }

# 1) Ensure conda is initialized for this shell
CONDA_BIN="$HOME/miniforge3/bin/conda"
if [ ! -x "$CONDA_BIN" ]; then
  log "Miniforge not found at $HOME/miniforge3. Install it first."; exit 1
fi

SHELL_NAME="$(basename "${SHELL:-zsh}")"
case "$SHELL_NAME" in
  zsh) eval "$("$CONDA_BIN" shell.zsh hook)";;
  bash) eval "$("$CONDA_BIN" shell.bash hook)";;
  fish) eval "$("$CONDA_BIN" shell.fish hook)";;
  *) eval "$("$CONDA_BIN" shell.zsh hook)";;
esac

# 2) Load ~/.env for this session (simple and safe)
if [ -f "$HOME/.env" ]; then
  set -a; . "$HOME/.env"; set +a
else
  log "No ~/.env found. Using defaults."
fi

ENV_NAME="${ENV_NAME:-my_project}"
PROJECT_DIR="${PROJECT_DIR:-$HOME/pythons}"

# 3) Normalize project dir
PROJECT_DIR="$(python - <<'PY'
import os
print(os.path.realpath(os.path.expanduser(os.environ.get("PROJECT_DIR",""))))
PY
)"
mkdir -p "$PROJECT_DIR"
cd "$PROJECT_DIR"

# 4) Ensure mamba exists
command -v mamba >/dev/null 2>&1 || { log "Installing mamba into base"; conda install -y -n base -c conda-forge mamba; }

# 5) Create environment.yml if missing
if [ ! -f environment.yml ]; then
  log "Writing environment.yml"
  cat > environment.yml <<'YAML'
name: my_project
channels:
  - conda-forge
channel_priority: strict
dependencies:
  - python=3.12
  - pip
  - python-dotenv
  - ipykernel
YAML
fi

# 6) Create env if needed, else update core deps
if ! conda env list | awk '{print $1}' | grep -qx "$ENV_NAME"; then
  log "Creating env $ENV_NAME from environment.yml"
  mamba env create -n "$ENV_NAME" -f environment.yml
else
  log "Env $ENV_NAME already exists; ensuring core deps"
  conda activate "$ENV_NAME"
  mamba install -y python-dotenv pip
fi

# 7) Activate and sanity check
log "Activating $ENV_NAME"
conda activate "$ENV_NAME"
python - <<'PY'
from dotenv import load_dotenv
import os
load_dotenv(os.path.expanduser("~/.env"))
print("PROJECT_DIR:", os.getenv("PROJECT_DIR"))
print("ENV_NAME:", os.getenv("ENV_NAME"))
print("YOUTUBE_API_KEY set:", bool(os.getenv("YOUTUBE_API_KEY")))
PY

log "All set."

