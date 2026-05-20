#!/usr/bin/env bash
# Clean UV Installation Script
# Removes duplicate uv installations and installs fresh

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}🧹 Cleaning up UV installations...${NC}"
echo ""

# 1. Remove Homebrew version if exists
if brew list uv &>/dev/null; then
    echo -e "${YELLOW}Removing Homebrew uv...${NC}"
    brew uninstall uv 2>/dev/null || true
    echo "✓ Removed Homebrew uv"
fi

# 2. Remove standalone installation if exists
if [ -f ~/.local/bin/uv ]; then
    echo -e "${YELLOW}Removing standalone uv installation...${NC}"
    rm -f ~/.local/bin/uv
    echo "✓ Removed ~/.local/bin/uv"
fi

# 3. Remove any other instances
for loc in /usr/local/bin/uv ~/bin/uv ~/.cargo/bin/uv; do
    if [ -f "$loc" ]; then
        echo -e "${YELLOW}Removing $loc...${NC}"
        rm -f "$loc"
        echo "✓ Removed $loc"
    fi
done

echo ""
echo -e "${GREEN}🚀 Installing UV via official installer...${NC}"
echo ""

# 4. Install via official standalone installer
curl -LsSf https://astral.sh/uv/install.sh | sh

echo ""
echo -e "${GREEN}✅ UV installed successfully!${NC}"
echo ""

# 5. Verify installation
if [ -f ~/.local/bin/uv ]; then
    echo "Location: ~/.local/bin/uv"
    ~/.local/bin/uv --version
    echo ""
    echo "Add to PATH (should already be in .zshrc):"
    echo "  export PATH=\"\$HOME/.local/bin:\$PATH\""
    echo ""

    # Check if already in PATH
    if ! grep -q '.local/bin' ~/.zshrc; then
        echo "Adding to .zshrc..."
        echo '' >> ~/.zshrc
        echo '# UV package manager' >> ~/.zshrc
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
        echo "✓ Added to .zshrc"
    else
        echo "✓ Already in .zshrc"
    fi

    echo ""
    echo "Run: source ~/.zshrc"
    echo "Then: uv --version"
else
    echo -e "${RED}⚠ Installation may have failed. Check output above.${NC}"
fi
