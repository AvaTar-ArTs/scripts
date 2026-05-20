#!/usr/bin/env bash
#
# Homebrew Miniforge (conda-forge) + optional micromamba — install and baseline config.
#
# This is the supported stack if you use "brew only" for conda/mamba (no ~/miniforge3
# from Miniforge3-*.sh — do not also run install-miniforge-default-env.sh on the same Mac).
#
# Usage:
#   ./install-miniforge-brew-stack.sh
#   ./install-miniforge-brew-stack.sh --upgrade              # brew upgrade --cask miniforge
#   ./install-miniforge-brew-stack.sh --with-micromamba      # brew micromamba + ~/.local/bin/micromamba (see below)
#
set -euo pipefail

UPGRADE=0
WITH_MICRO=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --upgrade) UPGRADE=1 ;;
    --with-micromamba) WITH_MICRO=1 ;;
    -h|--help)
      cat <<'EOF'
Homebrew Miniforge (+ optional micromamba). Typical:

  ./install-miniforge-brew-stack.sh
  ./install-miniforge-brew-stack.sh --upgrade
  ./install-miniforge-brew-stack.sh --with-micromamba

With Miniforge, Homebrew cannot link brew micromamba's "mamba" into PREFIX/bin (Miniforge
owns mamba). This script links only the name micromamba into ~/.local/bin.

Do not combine with ~/miniforge3 from install-miniforge-default-env.sh on the same Mac.
EOF
      exit 0
      ;;
    *)
      echo "Unknown option: $1 (try --help)" >&2
      exit 2
      ;;
  esac
  shift
done

if ! command -v brew >/dev/null 2>&1; then
  echo "Homebrew is required: https://brew.sh" >&2
  exit 1
fi

BREW_PREFIX="$(brew --prefix)"
MINIFORGE_BASE="${BREW_PREFIX}/Caskroom/miniforge/base"
CONDA_SH="${MINIFORGE_BASE}/etc/profile.d/conda.sh"

echo "==> Homebrew prefix: ${BREW_PREFIX}"

if [[ -f "$CONDA_SH" ]]; then
  if [[ "$UPGRADE" == 1 ]]; then
    echo "==> Upgrading miniforge cask..."
    brew upgrade --cask miniforge
  else
    echo "==> Miniforge base already present at: ${MINIFORGE_BASE}"
    echo "    (pass --upgrade to run: brew upgrade --cask miniforge)"
  fi
else
  echo "==> Installing miniforge cask..."
  brew install --cask miniforge
fi

if [[ ! -f "$CONDA_SH" ]]; then
  echo "Expected conda.sh at: $CONDA_SH" >&2
  exit 1
fi

# shellcheck disable=SC1090
source "$CONDA_SH"

echo "==> conda + mamba versions"
conda --version
mamba --version

echo "==> conda-forge-friendly conda/mamba policy (user ~/.condarc)"
conda config --set channel_priority strict
conda config --set solver libmamba
if conda config --show channels 2>/dev/null | grep -q '^  - defaults$'; then
  echo "WARN: channel 'defaults' is enabled — for conda-forge-first, consider: conda config --remove channels defaults" >&2
fi
echo "==> effective config (channels / channel_priority / solver)"
conda config --show channels channel_priority solver

if [[ "$WITH_MICRO" == 1 ]]; then
  echo "==> micromamba (brew formula — second stack; Miniforge keeps conda/mamba for daily use)"
  echo "    Homebrew's micromamba package also installs a binary named 'mamba', which conflicts"
  echo "    with the miniforge cask symlink at ${BREW_PREFIX}/bin/mamba. Brew link may error; we"
  echo "    still use the keg and expose only the name 'micromamba' via ~/.local/bin."

  if ! brew list micromamba &>/dev/null; then
    set +e
    brew install micromamba
    micro_st=$?
    set -e
    if [[ ! -x "${BREW_PREFIX}/opt/micromamba/bin/micromamba" ]]; then
      echo "brew install micromamba did not produce ${BREW_PREFIX}/opt/micromamba/bin/micromamba (exit ${micro_st})" >&2
      exit 1
    fi
    if [[ "$micro_st" -ne 0 ]]; then
      echo "    (brew reported a link error — expected when Miniforge owns ${BREW_PREFIX}/bin/mamba; keg is OK.)"
    fi
  else
    echo "    micromamba formula already installed."
  fi

  MICRO_BIN="${BREW_PREFIX}/opt/micromamba/bin/micromamba"
  if [[ ! -x "$MICRO_BIN" ]]; then
    echo "Expected micromamba at: $MICRO_BIN" >&2
    exit 1
  fi

  mkdir -p "${HOME}/.local/bin"
  ln -sf "$MICRO_BIN" "${HOME}/.local/bin/micromamba"
  echo "==> Linked ${HOME}/.local/bin/micromamba -> ${MICRO_BIN}"
  case ":${PATH:-}:" in *:"${HOME}/.local/bin":*) ;; *)
    echo "WARN: ~/.local/bin is not on PATH in this shell — add it to ~/.zshrc if needed." >&2
    ;;
  esac
  "${HOME}/.local/bin/micromamba" --version
fi

echo ""
echo "Done. Next steps (zsh, opt-in mamba — matches a typical ~/.zshrc mamba-on pattern):"
echo "  1) New terminal, then:  mamba-on"
echo "  2) Create an env:       mamba create -n deeptutor python=3.11 pip git -y"
echo "  3) Activate:            mamba activate deeptutor"
echo ""
echo "One-liner hook (same session, no mamba-on function):"
echo "  eval \"\$(mamba shell hook -s zsh)\""
echo ""
if [[ "$WITH_MICRO" == 1 ]]; then
  echo "micromamba CLI:  ~/.local/bin/micromamba  (or ensure ~/.local/bin is on PATH, then: micromamba)"
  echo "Init once (own line, no trailing # comment on same line):"
  echo "  micromamba shell init -s zsh -r ~/micromamba"
  echo "  micromamba config append channels conda-forge && micromamba config set channel_priority strict"
  echo "Do not run brew's suggested .../opt/micromamba/bin/mamba shell init unless you intend to replace Miniforge mamba."
  echo ""
fi
echo "Upgrade later:  brew upgrade --cask miniforge"
echo "Docs (DeepTutor):  Miniforge-Mamba-Micromamba.md / How-To.md §2"
