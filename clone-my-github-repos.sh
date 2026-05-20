#!/usr/bin/env zsh
# Clone all repos for AvaTar-ArTs and GPTJunkie.
# Usage: ./clone-my-github-repos.sh [BASE_DIR]
#   BASE_DIR defaults to /Volumes/2T-Xx/Github-Repos
#   Use /Users/steven/github to put everything under home instead.

set -e
BASE="${1:-/Volumes/2T-Xx/Github-Repos}"
export HOME="${HOME:-/Users/steven}"

mkdir -p "$BASE/AvaTar-ArTs" "$BASE/GPTJunkie"

AVATARTS=(
  ai-command-hub all AvaTar-ArTs.github.io AVATARARTS AVATARARTS_WEBSITE daTabase
  FastChat freeCodeCamp gemini-cli-git git-ai gorilla gumroad linear-programming-course
  llm-datasets lyra-exporter MarketMaster nano-banana-hackathon-kit nocTurneMeLoDieS
  nocTurneMeLoDieS-next nocTurneMeLoDieS-website notebooklm-mcp notebooklm-skill
  notebooklm-skill-og notebooklm-youtube-skill notebooklm-youtube-skill-og
  obsidian-image-upload-toolkit obsidian-quiz-generator PasTe-Export PopClip-Extensions
  popclipweb qwen-code run-gemini-cli sora-remover tableau-mcp tehSite tinytuner
  ToolUniverse trend-pulse-pro userscript VAULT-OPS-PRO veo-3-nano-banana-gemini-api-quickstart
  xEo xEo-Docs xEo-jobs
)

GPTJUNKIE=(
  AgentGPT ai-comic-creator aichat aider claudemarketplaces.com Comic-Smart-Panels
  comicbook ComicCreator comic_book_creator context7 dockerfiles EasyGrid Empire
  epub-manga-creator extensions harbor hostinger iterm-fish-fisher-osx LocalAGI
  LocalAI LocalAI-examples LocalRecall MCPs mistralai-cookbook MongoDB-RAG-Vercel
  obsidian-smart-connections oh-my-fish ollama peruse qwen react-komik script-commands
  skillserver SoraWatermarkCleaner talent-store-history vercel Villain Wan2.2
  whisper.cpp x-cmd xEo
)

clone_account() {
  local account="$1"
  local dest="$BASE/$account"
  shift
  local repos=("$@")
  echo "=== $account -> $dest ==="
  cd "$dest"
  for repo in "${repos[@]}"; do
    if [[ -d "$repo/.git" ]]; then
      echo "  SKIP: $repo"
    else
      echo "  CLONE: $repo"
      git clone --depth 1 "https://github.com/${account}/${repo}.git" 2>/dev/null || true
    fi
  done
}

clone_account "AvaTar-ArTs" "${AVATARTS[@]}"
clone_account "GPTJunkie" "${GPTJUNKIE[@]}"

echo ""
echo "Done. Repos under: $BASE"
ls -la "$BASE/AvaTar-ArTs" 2>/dev/null | head -20
echo "..."
ls -la "$BASE/GPTJunkie" 2>/dev/null | head -20
