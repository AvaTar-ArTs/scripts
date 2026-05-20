#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail

# 🪄 TechnoMancer Hybrid Mac Maintenance Script — Emoji Art & Animation 🪄

# ========== COLOR & EMOJI ========== #
RESET='\033[0m'; BOLD='\033[1m'; CYAN='\033[36m'; YELLOW='\033[33m'; MAGENTA='\033[35m'; GREEN='\033[32m'; RED='\033[31m'
EMOJIS=("🧹" "🧙‍♂️" "✨" "📦" "⚡" "🦾" "🎉" "💾" "🪄" "🌈" "🌀" "💻")
SPINNER_FRAMES=( "⠁" "⠂" "⠄" "⡀" "⢀" "⠠" "⠐" "⠈" )

pick_emoji() { local e=${EMOJIS[$((RANDOM % ${#EMOJIS[@]}))]}; echo -n "$e"; }

# ========== ANIMATIONS & ART ========== #
banner_art() {
cat <<EOF
${MAGENTA}${BOLD}
     🪄┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓🪄
     ┃   $(pick_emoji) TechnoMancer Mac Maintenance $(pick_emoji)   ┃
     ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
                $(pick_emoji) $(pick_emoji) $(pick_emoji) $(pick_emoji) $(pick_emoji) $(pick_emoji)
${RESET}
EOF
}

wizard_art() {
cat <<EOF
${CYAN}${BOLD}
      ⠀⠀⠀⠀⠀⣀⣀⣀⣀⣀⡀⠀⠀⠀⠀⠀
      ⠀⠀⠀⠀⢸⣿⣿⣿⣿⣿⡇⠀🧙‍♂️⠀
      ⠀⠀⢀⣴⣾⣿⣿⣿⣿⣷⣦⡀⠀⠀⠀
      ⠀⠀⠈⠻⣿⣿⣿⣿⣿⣿⠟⠁⠀⠀⠀
      ⠀⠀⠀⠀⠈⠻⣿⣿⠟⠁⠀⠀⠀⠀⠀
${RESET}
EOF
}

ripple() {
  local c="$1"
  for r in "🌊" "🌊🌊" "🌊🌊🌊" "🌊🌊🌊🌊" "🌊🌊🌊🌊🌊" "🌊🌊🌊🌊" "🌊🌊🌊" "🌊🌊" "🌊"; do
    printf "${CYAN}${BOLD}%s${RESET}\r" "$r"
    sleep 0.12
  done
  printf "${CYAN}${BOLD}%s${RESET}\n" "$c"
}

spinner_start() {
  _SPIN_PID=$!
  _SPINNER_ACTIVE=1
  (
    while :; do
      for frame in "${SPINNER_FRAMES[@]}"; do
        printf "${YELLOW}${BOLD}%s${RESET}\r" "$frame"
        sleep 0.08
      done
    done
  ) &
  _SPINNER_PID=$!
}

spinner_stop() {
  if [[ $_SPINNER_ACTIVE -eq 1 ]]; then
    kill "$_SPINNER_PID" 2>/dev/null
    printf "   \r"
    _SPINNER_ACTIVE=0
  fi
}

# ========== STATUS PRINTS ========== #
step_msg() { emoji="$(pick_emoji)"; echo -e "${BOLD}$emoji $1${RESET}"; }
success_msg() { emoji="$(pick_emoji)"; echo -e "${GREEN}${BOLD}$emoji $1${RESET}"; }
fail_msg() { emoji="$(pick_emoji)"; echo -e "${RED}${BOLD}$emoji $1${RESET}"; }
divider() { echo -e "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"; }

# ========== SUDO + TOUCHID CHECK ========== #
sudo_touchid_check() {
  if grep -q pam_tid.so /etc/pam.d/sudo 2>/dev/null; then
    success_msg "TouchID for sudo is ENABLED! Tap to approve actions 🖐️"
  else
    fail_msg "TouchID for sudo is NOT enabled."
    echo -e "${CYAN}To enable: Add 'auth sufficient pam_tid.so' at the top of /etc/pam.d/sudo${RESET}"
    echo -e "More info: https://support.apple.com/en-us/HT208109"
  fi
  sudo -v
  (while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &)  # Keep-alive
}

# ========== DYNAMIC CLEANER ========== #
remove_paths() {
  local cleaned=0
  for path in "$@"; do
    if [[ -e $path ]]; then
      step_msg "Removing $path"
      spinner_start
      sudo rm -rf "$path" &>/dev/null
      spinner_stop
      cleaned=$((cleaned+1))
    fi
  done
  if [[ $cleaned -eq 0 ]]; then step_msg "No matching paths found!"; fi
}

clean_section() {
  divider; step_msg "$1"
  remove_paths "${@:2}"
  ripple " "
}

# ========== MAIN SCRIPT ========== #
clear
banner_art
wizard_art
divider
sudo_touchid_check
divider

step_msg "Starting TechnoMancer cleanup session..."; sleep 0.6

# Example cleaning (add/remove as you wish)
clean_section "Emptying Trash" /Volumes/*/.Trashes/* ~/.Trash/*
clean_section "System Cache" /Library/Caches/* /System/Library/Caches/* ~/Library/Caches/* /private/var/folders/*/*/*
clean_section "MobileSync Backups" ~/Library/Application\ Support/MobileSync/Backup

if command -v conda >/dev/null; then
  step_msg "Cleaning conda caches..."
  ripple "Running: conda clean -a -y"
  conda clean -a -y
fi

if command -v brew >/dev/null; then
  step_msg "Homebrew update & cleanup..."
  spinner_start
  brew update && brew upgrade && brew cleanup -s
  spinner_stop
  ripple "🍺"
fi

if command -v node >/dev/null; then
  if command -v npm >/dev/null; then
    step_msg "Upgrading global npm packages..."
    spinner_start
    npm update -g
    spinner_stop
    ripple "📦"
  fi
  if command -v yarn >/dev/null; then
    step_msg "Upgrading global yarn packages..."
    spinner_start
    yarn global upgrade
    spinner_stop
    ripple "🧶"
  fi
else
  fail_msg "Node.js not installed: Skipping npm/yarn update routines."
fi

divider
success_msg "🪄  Cleanup and updates complete!  🪄"
echo -e "${CYAN}${BOLD}Your Mac is shinier than a wizard's staff!${RESET}"
ripple "✨🦾✨"
divider

cat <<'EOMSG'
🎩
      "Magic is just science with style."
              — The TechnoMancer
🎩
EOMSG

# Show a log summary if you want
echo -e "${YELLOW}Session log: $(date) | User: $USER | Host: $(hostname)${RESET}"
echo

exit 0
