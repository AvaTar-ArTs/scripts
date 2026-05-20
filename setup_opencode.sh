setup_opencode.sh

```bash
#!/usr/bin/env bash
set -euo pipefail

# OpenCode setup script for macOS Intel
# User: steven
# Installs Homebrew (if missing), git, node, python, uv
# Creates a workspace at /Users/steven/opencode

USER_HOME="/Users/steven"
WORKDIR="$USER_HOME/opencode"
BREW_BIN="/usr/local/bin/brew"

echo "==> Starting OpenCode setup..."

# Xcode Command Line Tools
if ! xcode-select -p >/dev/null 2>&1; then
  echo "==> Installing Xcode Command Line Tools..."
  xcode-select --install || true
  echo "Please complete the Xcode Command Line Tools install, then re-run this script."
  exit 1
fi

# Homebrew
if [ ! -x "$BREW_BIN" ]; then
  echo "==> Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
  echo "==> Homebrew already installed."
fi

# Ensure brew is in PATH for this script
eval "$($BREW_BIN shellenv)"

echo "==> Updating Homebrew..."
brew update

echo "==> Installing core packages..."
brew install git node python uv

echo "==> Creating workspace..."
mkdir -p "$WORKDIR"/{projects,scripts,tmp}

echo "==> Verifying installs..."
git --version
node --version
npm --version
python3 --version
uv --version

echo "==> Initializing npm project..."
cd "$WORKDIR"
if [ ! -f package.json ]; then
  npm init -y
fi

echo "==> Creating helpful files..."
cat > "$WORKDIR/README.md" <<'EOF'
# OpenCode Workspace

Folders:
- projects/  -> code projects
- scripts/   -> automation/setup scripts
- tmp/       -> temp files

Installed:
- git
- node / npm
- python3
- uv
EOF

cat > "$WORKDIR/scripts/dev_env_check.sh" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
echo "Git: $(git --version)"
echo "Node: $(node --version)"
echo "npm: $(npm --version)"
echo "Python: $(python3 --version)"
echo "uv: $(uv --version)"
EOF
chmod +x "$WORKDIR/scripts/dev_env_check.sh"

echo "==> Setup complete."
echo "Workspace created at: $WORKDIR"
echo "Run environment check with:"
echo "  $WORKDIR/scripts/dev_env_check.sh"
```

## Then run:
```bash
chmod +x /Users/steven/setup_opencode.sh
/Users/steven/setup_opencode.sh
```

## What it does
- checks/install Xcode CLI tools
- installs Homebrew if missing
- installs:
  - git
  - node
  - python
  - uv
- creates:
  - `/Users/steven/opencode/projects`
  - `/Users/steven/opencode/scripts`
  - `/Users/steven/opencode/tmp`

If by **“opencode”** you meant a specific project/tool named OpenCode, send me its GitHub URL or install docs and I’ll tailor the script exactly.