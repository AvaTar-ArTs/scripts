#!/usr/bin/env bash
set -e

# If you already use Homebrew "miniforge" (prefix: "$(brew --prefix)/Caskroom/miniforge/base"),
# skip this script — it installs a second full Miniforge under INSTALL_DIR and appends conda.sh to .zshrc.

# -------------------------
# Miniforge setup for /Users/steven
# -------------------------
INSTALL_DIR="/Users/steven/miniforge3"
MINIFORGE_URL="https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-MacOSX-x86_64.sh"
PROFILE_FILE="/Users/steven/.zshrc"
TMPFILE="$(mktemp)"

echo ""
echo "🍵 Installing Miniforge (conda-forge) for user: steven"
echo "Target directory: $INSTALL_DIR"
echo "---------------------------------------------------------"

# 1. Download the latest Miniforge installer
echo "⬇️  Downloading installer..."
curl -L "$MINIFORGE_URL" -o "$TMPFILE"
chmod +x "$TMPFILE"

# 2. Run the installer silently (-b = batch, -p = prefix)
echo "⚙️  Running installer..."
bash "$TMPFILE" -b -p "$INSTALL_DIR"
rm "$TMPFILE"

# 3. Source conda and add conda-forge as the main channel
echo "🧩 Initializing conda..."
source "$INSTALL_DIR/etc/profile.d/conda.sh"

conda config --add channels conda-forge
conda config --set channel_priority strict
conda install -y mamba -n base -c conda-forge

# 4. Inject Miniforge into your .zshrc if not already added
if ! grep -q "miniforge3/etc/profile.d/conda.sh" "$PROFILE_FILE" 2>/dev/null; then
    echo "" >> "$PROFILE_FILE"
    echo "# >>> Miniforge (conda-forge) initialize >>>" >> "$PROFILE_FILE"
    echo "source \"$INSTALL_DIR/etc/profile.d/conda.sh\"" >> "$PROFILE_FILE"
    echo "conda activate base" >> "$PROFILE_FILE"
    echo "# <<< Miniforge (conda-forge) initialize <<<" >> "$PROFILE_FILE"
    echo "✅ Added Miniforge init lines to $PROFILE_FILE"
else
    echo "ℹ️  Miniforge already initialized in $PROFILE_FILE"
fi

# 5. Reload ZSH
echo ""
echo "🔄 Reloading ZSH to activate Miniforge..."
exec zsh -l
