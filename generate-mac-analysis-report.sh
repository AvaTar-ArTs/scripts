#!/usr/bin/env bash

set -e

NOW=$(date +%Y%m%d_%H%M%S)
REPORT="$HOME/Desktop/mac_analysis_report_$NOW.md"

USERDIRS=(Documents Desktop Downloads Pictures Movies Music)
PROJECTDIRS=(Projects Sites Code Dev AI)
DOTFILES=(.zshrc .bashrc .bash_profile .gitconfig .env .ssh .gnupg .config)
APPSYSTEM="/Applications"
APPUSER="$HOME/Applications"
FONTS="$HOME/Library/Fonts"

echo "# Mac Analysis Report - $NOW" > "$REPORT"
echo >> "$REPORT"
echo "_Run on: $(hostname), $(sw_vers | grep ProductVersion | awk '{print $2}')_" >> "$REPORT"
echo >> "$REPORT"

# --- USER FOLDERS
echo "## User Folders" >> "$REPORT"
for d in "${USERDIRS[@]}"; do
    p="$HOME/$d"
    if [ -d "$p" ]; then
        files=$(find "$p" -type f | wc -l)
        size=$(du -sh "$p" 2>/dev/null | awk '{print $1}')
        echo "- **$d**: $files files, $size" >> "$REPORT"
        if [ "$files" -eq 0 ]; then echo "  - ⚠️ Empty" >> "$REPORT"; fi
    else
        echo "- **$d**: _Missing_" >> "$REPORT"
    fi
done

# --- PROJECT FOLDERS
echo -e "\n## Project/Code Folders" >> "$REPORT"
for d in "${PROJECTDIRS[@]}"; do
    p="$HOME/$d"
    if [ -d "$p" ]; then
        files=$(find "$p" -type f | wc -l)
        size=$(du -sh "$p" 2>/dev/null | awk '{print $1}')
        echo "- **$d**: $files files, $size" >> "$REPORT"
        if [ "$files" -eq 0 ]; then echo "  - ⚠️ Empty" >> "$REPORT"; fi
    fi
done

# --- DOTFILES
echo -e "\n## Dotfiles & Configs" >> "$REPORT"
for f in "${DOTFILES[@]}"; do
    fp="$HOME/$f"
    if [ -e "$fp" ]; then
        echo "- $f: Present" >> "$REPORT"
    fi
done

# --- FONTS
if [ -d "$FONTS" ]; then
    count=$(ls "$FONTS" | wc -l)
    echo -e "\n## Custom Fonts\n- $FONTS: $count font files" >> "$REPORT"
fi

# --- APP BUNDLES
echo -e "\n## Installed Applications (.app bundles)" >> "$REPORT"
for adir in "$APPSYSTEM" "$APPUSER"; do
    if [ -d "$adir" ]; then
        num=$(find "$adir" -maxdepth 1 -name "*.app" | wc -l)
        echo "- $adir: $num apps" >> "$REPORT"
        find "$adir" -maxdepth 1 -name "*.app" -exec basename {} \; | sort | head -20 >> "$REPORT"
        [ "$num" -gt 20 ] && echo "  ...and $(($num-20)) more." >> "$REPORT"
    fi
done

# --- HOMEBREW
echo -e "\n## Homebrew Formulae & Casks" >> "$REPORT"
if command -v brew >/dev/null 2>&1; then
    countf=$(brew list | wc -l)
    countc=$(brew list --cask | wc -l)
    echo "- Formulae: $countf" >> "$REPORT"
    brew list | sort | head -10 >> "$REPORT"
    [ "$countf" -gt 10 ] && echo "  ...and $(($countf-10)) more." >> "$REPORT"
    echo "- Casks: $countc" >> "$REPORT"
    brew list --cask | sort | head -10 >> "$REPORT"
    [ "$countc" -gt 10 ] && echo "  ...and $(($countc-10)) more." >> "$REPORT"
else
    echo "- Homebrew not found" >> "$REPORT"
fi

# --- MAS APPS
echo -e "\n## Mac App Store (mas-cli) Apps" >> "$REPORT"
if command -v mas >/dev/null 2>&1; then
    num=$(mas list | wc -l)
    echo "- Installed: $num" >> "$REPORT"
    mas list | head -10 >> "$REPORT"
    [ "$num" -gt 10 ] && echo "  ...and $(($num-10)) more." >> "$REPORT"
else
    echo "- mas-cli not installed" >> "$REPORT"
fi

# --- CURSOR EXTENSIONS
echo -e "\n## Cursor Extensions" >> "$REPORT"
if command -v cursor >/dev/null 2>&1; then
    num=$(cursor --list-extensions | wc -l)
    echo "- Installed: $num" >> "$REPORT"
    cursor --list-extensions | sort | head -10 >> "$REPORT"
    [ "$num" -gt 10 ] && echo "  ...and $(($num-10)) more." >> "$REPORT"
else
    echo "- Cursor CLI not found" >> "$REPORT"
fi

# --- Python & Node packages
echo -e "\n## Python (pip) Global Packages" >> "$REPORT"
if command -v pip3 >/dev/null 2>&1; then
    pip3 list --user | head -10 >> "$REPORT"
else
    echo "- pip3 not found" >> "$REPORT"
fi

echo -e "\n## Node (npm) Global Packages" >> "$REPORT"
if command -v npm >/dev/null 2>&1; then
    npm ls -g --depth=0 | grep '──' | head -10 >> "$REPORT"
else
    echo "- npm not found" >> "$REPORT"
fi

# --- Summary
echo -e "\n## Summary & Recommendations" >> "$REPORT"
echo "- Check for any ⚠️ warnings above (empty folders, missing data)" >> "$REPORT"
echo "- For migration, see [Apple Migration Assistant](https://support.apple.com/en-us/HT204350) or manual methods." >> "$REPORT"
echo "- You can use this report as a checklist for backup, restore, or documentation." >> "$REPORT"

echo -e "\n---" >> "$REPORT"
echo "**Mac analysis complete! Report saved to:** $REPORT"
echo "Open in any Markdown viewer or editor."

# Auto-open the generated Markdown report
open "$REPORT"
