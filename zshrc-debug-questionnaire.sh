#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail

# zshrc_debug_questions.sh
# Lists all diagnostic questions needed to fully resolve Steven's zshrc & env stack.

echo ""
echo "========================================================"
echo " 🔍 ZSH / PYTHON / ENV SYSTEM DEBUG QUESTION CHECKLIST "
echo "========================================================"
echo ""

questions=(
  # ----------------- GENERAL ZSH -----------------
  "1. Do you want Oh-My-Zsh to remain the core framework, or should it be swapped for something lighter (e.g., zinit, antibody)?"
  "2. Should the zsh theme be optimized for speed (powerlevel10k) or left as-is (robbyrussell)?"
  "3. Are there any plugins you want removed or added (e.g., fzf-tab, history-search, autoswitch)?"

  # ----------------- PATH -----------------
  "4. Should PATH prioritize Homebrew first or system binaries first?"
  "5. Do you want the PATH cleanup to be strict (block Python 3.11, 3.13, 3.14 entirely) or flexible?"
  "6. Should PATH include Node, Go, Rust, PHP, or other languages you haven't activated yet?"

  # ----------------- PYTHON -----------------
  "7. Do you want Python 3.12 to remain the global default for *all* tools?"
  "8. Should Python 3.11 stay as a secondary interpreter for special projects?"
  "9. Do you want Python 3.13 or 3.14 enabled or permanently blocked?"
  "10. Should python3 ALWAYS point to python3.12 even inside venvs?"
  "11. Are your Python scripts expected to run under 3.12 only, or mixed versions?"
  "12. Should pip always run with no user site-packages, or should that be relaxed?"
  
  # ----------------- VENV SYSTEM -----------------
  "13. Should auto-activate `.venv` run silently or announce itself?"
  "14. Should auto-deactivate venvs when leaving directories remain enabled?"
  "15. Should 'tobase' also clear Node, Java, Go, Rust envs?"
  "16. Should venv creation default to 3.11 or 3.12?"
  "17. Should venv detection search beyond 3 parent directories?"

  # ----------------- MINIFORGE / CONDA -----------------
  "18. Do you want Miniforge / Conda truly dead forever?"
  "19. Should I auto-detect stray conda configs and wipe them?"
  "20. Should Mamba ever be allowed to run again?"

  # ----------------- ENV.D SYSTEM -----------------
  "21. Should env.d load LLM keys automatically at shell startup or stay manual?"
  "22. Should env.d rebuild master every time you edit an env category?"
  "23. Should env.d auto-validate env files periodically?"
  "24. Should env.d warn you if keys are missing?"

  # ----------------- AI & DEVOPS -----------------
  "25. Should the 'ai' function default to Grok, OpenAI, or ask which model?"
  "26. Should 'ai-menu' launch a GUI (osascript) or remain terminal-only?"
  "27. Should Cursor API auto-load silently or prompt?"
  "28. Should Ollama models auto-load completions?"

  # ----------------- HOME BREW -----------------
  "29. Should brew remain lazy-loaded, or loaded fully on startup?"
  "30. Should brew shellenv override preexisting PATH entries?"

  # ----------------- CLI TOOLS -----------------
  "31. Should zoxide replace 'cd' globally (alias cd='z')?"
  "32. Should fd / fzf be required for proj, or should it fallback gracefully?"
  "33. Should bat fully replace cat globally?"
  "34. Should eza become mandatory? Or fallback to ls?"

  # ----------------- GOOGLE CLOUD SDK -----------------
  "35. Should gcloud autoload only if the SDK is detected or always attempt it?"
  "36. Should gcloud completions load silently or verbosely?"

  # ----------------- USAGE ANALYTICS -----------------
  "37. Should command usage analytics run on every command or only custom commands?"
  "38. Should usage logs rotate automatically?"
  "39. Should analytics track execution time of commands?"

  # ----------------- PROJECT SYSTEM -----------------
  "40. Should proj scan only a few directories or the entire $HOME?"
  "41. Should proj allow deeply nested directories (max-depth > 2)?"
  "42. Should your ai-sites repo automation auto-push (not just commit)?"

  # ----------------- SECURITY -----------------
  "43. Should .env.d/*.env permissions be forced to chmod 600 daily or hourly?"
  "44. Should the shell warn if API keys are missing?"
  "45. Should the shell scan for insecure keys left in random files?"

  # ----------------- SUNO / AUDIO -----------------
  "46. Should Suno scripts run under python3.12 only?"
  "47. Should browser extractor copy automatically or prompt?"
  "48. Should Suno CSVs auto-merge on save?"

  # ----------------- CLEANUP / DEPRECATION -----------------
  "49. Should old env variables be automatically purged from the environment?"
  "50. Should deprecated aliases be logged to show what you never use?"
  "51. Should zsh remind you periodically which aliases were unused for 90 days?"
)

for q in "${questions[@]}"; do
  echo " - $q"
done

echo ""
echo "========================================================"
echo "  🧠 Done — Review or pipe to a file for documentation   "
echo "========================================================"
echo ""
