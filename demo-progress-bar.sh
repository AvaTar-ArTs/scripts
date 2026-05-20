#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail


# Function to print a colored progress bar
function print_progress_bar() {
  local percentage="$1"
  local width="$2"
  local color="$3"
  local emoji="$4"

  local num_chars=$((percentage * width / 100))
  local num_spaces=$((width - num_chars))

  # Set the color using ANSI escape codes
  case "$color" in
    "red")
      color_code="\e[91m" # Red
      ;;
    "green")
      color_code="\e[92m" # Green
      ;;
    "blue")
      color_code="\e[94m" # Blue
      ;;
    *)
      color_code="\e[0m"  # Default (no color)
      ;;
  esac

  # Print the progress bar
  printf "${color_code}["
  printf "%-${num_chars}s" "#"  # Progress part
  printf "%-${num_spaces}s" " " # Remaining part (spaces)
  printf "] ${percentage}% ${emoji}\e[0m\n" # Reset color
}

# Usage examples
print_progress_bar 25 20 "red" "🔴"
print_progress_bar 50 20 "green" "✅"
print_progress_bar 75 20 "blue" "🔵"
