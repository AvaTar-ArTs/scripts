#!/usr/bin/env bash
set -euo pipefail

###############################################################################
# Full Home Directory Backup — Clone/Copy/Consolidate to /Volumes/macBaks/GPTJunkie
# Generated: April 12, 2026
# Source: /Users/steven/
# Target: /Volumes/macBaks/GPTJunkie/home-full-backup/
###############################################################################

TARGET="/Volumes/macBaks/GPTJunkie/home-full-backup"
LOG="/Volumes/macBaks/GPTJunkie/home-full-backup.log"
START_TIME=$(date +%s)

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log() { echo -e "${BLUE}[$(date '+%H:%M:%S')]${NC} $1" | tee -a "$LOG"; }
ok()   { echo -e "${GREEN}  ✓${NC} $1" | tee -a "$LOG"; }
warn() { echo -e "${YELLOW}  ⚠${NC} $1" | tee -a "$LOG"; }
err()  { echo -e "${RED}  ✗${NC} $1" | tee -a "$LOG"; }

# Create target structure
mkdir -p "$TARGET"/{dot-dirs,projects,home-files,archives}

log "╔══════════════════════════════════════════════════════════╗"
log "║  Full Home Directory Backup — /Users/steven/ → macBaks  ║"
log "╚══════════════════════════════════════════════════════════╝"
log ""

###############################################################################
# PHASE 1: Dot Directories (~/.*) — Config, AI tools, AI platforms, env
###############################################################################
log "${YELLOW}PHASE 1: Dot Directories (70+ config/AI/env directories)${NC}"

DOT_DIRS=(
    # AI Platform Configs
    .actor .agent_events .agent_ops .agents .aider .aitk .apify
    .autotagger-lite .boltai .book_of_memory .cagent .chatgpt
    .claude .cline .codeium .codex .codexs .crewai .cursor
    .domain-catalog .eigent .gemini .git-ai .github .grok .groq
    .kimi .lingma .logseq .mcp-auth .mcp-central .mcphooker
    .openclaw .opencode .postman .qoder .qodo .qwen .raycast
    .serena .sonarlint .supremepower .tagger .tooluniverse .u2net

    # Development Environments
    .cargo .bun .bundle .gem .npm .npm-global .nvm .pixi
    .rbenv .rustup .oh-my-zsh .zsh .zsh_sessions .zshrc_archive .zshrc.d
    .mamba .venv .venv_dev .vscode .gradle .dotnet .aspnet
    .config .local .bin

    # Cloud & Services
    .android .azure .cups .gnupg .putty .ssh .streamlit
    .ServiceHub .services .harbor

    # Misc Configs
    .cache .dotfiles .file-tracker .hyper_plugins .iterm2
    .launchd .lh .lpass .matplotlib .pdf-filler-profiles
    .plural .scan_temp .secrets .spicetify .spotdl
    .update_logs .archives .cfg

    # Env & Security (CRITICAL — backed up with permissions)
    .env.d
)

COPIED=0
FAILED=0
SKIPPED=0

for dir in "${DOT_DIRS[@]}"; do
    src="/Users/steven/$dir"
    if [ -e "$src" ]; then
        size=$(du -sh "$src" 2>/dev/null | cut -f1)
        if rsync -ah --exclude='__pycache__' --exclude='*.pyc' --exclude='node_modules' --exclude='.venv' --exclude='venv' "$src/" "$TARGET/dot-dirs/$dir/" 2>/dev/null; then
            ok "$dir ($size)"
            ((COPIED++))
        else
            err "$dir — rsync failed"
            ((FAILED++))
        fi
    else
        SKIPPED=$((SKIPPED + 1))
    fi
done

log ""
log "Phase 1 complete: ${GREEN}${COPIED} copied${NC}, ${YELLOW}${SKIPPED} not found${NC}, ${RED}${FAILED} failed${NC}"

###############################################################################
# PHASE 2: Project Directories
###############################################################################
log ""
log "${YELLOW}PHASE 2: Project Directories (50+ directories)${NC}"

PROJECT_DIRS=(
    agent_forge agent-transcripts AI_Chats ai_merge_auto_setup
    aider-env AutoTagger AutoTag AvaTarArTs backups bin
    book_of_memory chromium claudemarketplaces.com clean
    Development Documents Epstein Fancy-Advanced-Med-journals
    file-tracker Fixes fuzzy-finder git-ai google-cloud-sdk
    grok ice-tracker iterm2 iterm2_prompt-engineering-exploration
    iterm2-fix kimi logs maigret-reports MarketMaster
    "Master CodeSnip dev" MasterxEo mcPHooker MCPServer_Config
    Miniforge_Mamba_Analysis my-simple NeXt-Test-app
    nocTurneMeLoDieS nocTurneMeLoDieS_HTML_Archive p-market
    PYTHON_MARKETPLACE_MASTER pythons Raycast RightFont
    scripts simplegallery upWork userscripts uv-demo
    whoosh-search-index zombot-simple-gallery Zotero
    zsh-autocomplete zsh-completions
)

# Skip directories already covered by earlier backup phase
ALREADY_BACKED_UP="github pythons MasterxEo scripts AVATARARTS AVATARARTS_ECOSYSTEM Music nocTurneMeLoDieS REVENUE_PROJECTS XEO_OPTIMIZED_PRODUCTS"

PCOPIED=0
PSKIPPED=0
PFAILED=0

for dir in "${PROJECT_DIRS[@]}"; do
    src="/Users/steven/$dir"

    # Skip if already backed up
    skip=false
    for backed in $ALREADY_BACKED_UP; do
        if [ "$dir" = "$backed" ]; then
            skip=true
            break
        fi
    done
    if $skip; then
        PSKIPPED=$((PSKIPPED + 1))
        continue
    fi

    if [ -e "$src" ]; then
        size=$(du -sh "$src" 2>/dev/null | cut -f1)
        if rsync -ah --exclude='__pycache__' --exclude='*.pyc' --exclude='node_modules' --exclude='.venv' --exclude='venv' --exclude='.git' "$src/" "$TARGET/projects/$dir/" 2>/dev/null; then
            ok "$dir ($size)"
            ((PCOPIED++))
        else
            err "$dir — rsync failed"
            ((PFAILED++))
        fi
    else
        PSKIPPED=$((PSKIPPED + 1))
    fi
done

log ""
log "Phase 2 complete: ${GREEN}${PCOPIED} copied${NC}, ${YELLOW}${PSKIPPED} skipped/backed up${NC}, ${RED}${PFAILED} failed${NC}"

###############################################################################
# PHASE 3: Home Root Files (.md, .txt, .csv, .json, .sh, .py, .log, .zip, etc.)
###############################################################################
log ""
log "${YELLOW}PHASE 3: Home Root Files (config files, reports, archives)${NC}"

# Exclude patterns for home root
EXCLUDE_PATTERNS=(
    --exclude='.DS_Store'
    --exclude='.localized'
    --exclude='.Spotlight-V100'
    --exclude='.Trashes'
    --exclude='.fseventsd'
)

# Copy all non-hidden files from home root (except Applications, Desktop, Documents, Downloads, Movies, Pictures, Public which are system dirs)
SYSTEM_DIRS="Applications Desktop Documents Downloads Movies Pictures Public iCloud"

FCOPIED=0

# Get all files/dirs in home root that aren't directories already backed up
for item in /Users/steven/*; do
    [ -e "$item" ] || continue
    base=$(basename "$item")

    # Skip system directories
    skip=false
    for sysdir in $SYSTEM_DIRS; do
        if [ "$base" = "$sysdir" ]; then
            skip=true
            break
        fi
    done
    $skip && continue

    # Skip directories already handled
    skip=false
    for backed in $ALREADY_BACKED_UP "${PROJECT_DIRS[@]}"; do
        if [ "$base" = "$backed" ]; then
            skip=true
            break
        fi
    done
    $skip && continue

    if [ -f "$item" ] || [ -L "$item" ]; then
        size=$(du -sh "$item" 2>/dev/null | cut -f1)
        cp -R "$item" "$TARGET/home-files/" 2>/dev/null && ok "$base ($size)" && ((FCOPIED++)) || err "$base — copy failed"
    elif [ -d "$item" ]; then
        size=$(du -sh "$item" 2>/dev/null | cut -f1)
        rsync -ah --exclude='__pycache__' --exclude='node_modules' "$item/" "$TARGET/projects/$base/" 2>/dev/null && ok "$base/ ($size)" && ((FCOPIED++)) || err "$base/ — rsync failed"
    fi
done

# Copy hidden files (dotfiles) from home root
for item in /Users/steven/.*; do
    [ -e "$item" ] || continue
    base=$(basename "$item")

    # Skip . and ..
    [ "$base" = "." ] || [ "$base" = ".." ] && continue

    # Skip dot directories already handled in Phase 1
    skip=false
    for ddir in "${DOT_DIRS[@]}"; do
        if [ "$base" = "$ddir" ]; then
            skip=true
            break
        fi
    done
    $skip && continue

    if [ -f "$item" ] || [ -L "$item" ]; then
        size=$(du -sh "$item" 2>/dev/null | cut -f1)
        cp -R "$item" "$TARGET/home-files/" 2>/dev/null && ok "$base ($size)" && ((FCOPIED++)) || warn "$base — skipped"
    fi
done

log ""
log "Phase 3 complete: ${GREEN}${FCOPIED} files copied${NC}"

###############################################################################
# PHASE 4: Archives (.zip, .tar.gz)
###############################################################################
log ""
log "${YELLOW}PHASE 4: Archive Files${NC}"

ACOPIED=0
for archive in /Users/steven/*.zip /Users/steven/*.tar.gz /Users/steven/*.env.d.zip; do
    [ -e "$archive" ] || continue
    base=$(basename "$archive")
    size=$(du -sh "$archive" 2>/dev/null | cut -f1)
    cp "$archive" "$TARGET/archives/" 2>/dev/null && ok "$base ($size)" && ((ACOPIED++)) || err "$base — copy failed"
done

log ""
log "Phase 4 complete: ${GREEN}${ACOPIED} archives copied${NC}"

###############################################################################
# PHASE 5: System Directories (selective — Documents, Downloads, Desktop)
###############################################################################
log ""
log "${YELLOW}PHASE 5: System Directories (Documents, Downloads, Desktop — metadata only)${NC}"

for sysdir in Desktop; do
    src="/Users/steven/$sysdir"
    if [ -d "$src" ]; then
        size=$(du -sh "$src" 2>/dev/null | cut -f1)
        log "  Copying $sysdir/ ($size)..."
        rsync -ah "$src/" "$TARGET/system-dirs/$sysdir/" 2>/dev/null && ok "$sysdir/ ($size)" || warn "$sysdir/ — skipped or failed"
    fi
done

# Documents and Downloads are huge — copy only key files
log "  Documents/ and Downloads/ are too large for full backup — copying key files only..."
mkdir -p "$TARGET/system-dirs/Documents" "$TARGET/system-dirs/Downloads"

# Key document types from Documents
for ext in md txt csv json sh py pdf; do
    find "/Users/steven/Documents" -maxdepth 2 -name "*.$ext" -type f 2>/dev/null | while read -r f; do
        cp "$f" "$TARGET/system-dirs/Documents/" 2>/dev/null
    done
done

log ""

###############################################################################
# PHASE 6: AI Config JSON files (critical for restoring AI tool state)
###############################################################################
log "${YELLOW}PHASE 6: AI Configuration Files${NC}"

for jsonfile in /Users/steven/.claude.json /Users/steven/.claude.json.backup* /Users/steven/.qwen_conversations_index.json; do
    [ -e "$jsonfile" ] || continue
    base=$(basename "$jsonfile")
    cp "$jsonfile" "$TARGET/ai-configs/" 2>/dev/null && ok "$base" || warn "$base — skipped"
done

mkdir -p "$TARGET/ai-configs"
for jsonfile in /Users/steven/.claude.json /Users/steven/.claude.json.backup* /Users/steven/.qwen_conversations_index.json /Users/steven/*.json; do
    [ -e "$jsonfile" ] || continue
    [[ "$jsonfile" == *"node_modules"* ]] && continue
    [[ "$jsonfile" == *"package.json" ]] && continue
    [[ "$jsonfile" == *"package-lock.json" ]] && continue
    base=$(basename "$jsonfile")
    cp "$jsonfile" "$TARGET/ai-configs/" 2>/dev/null && ok "$base" || true
done

###############################################################################
# FINAL SUMMARY
###############################################################################
END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))
MINS=$((DURATION / 60))
SECS=$((DURATION % 60))

TOTAL_SIZE=$(du -sh "$TARGET" 2>/dev/null | cut -f1)
TOTAL_FILES=$(find "$TARGET" -type f 2>/dev/null | wc -l | tr -d ' ')

log ""
log "╔══════════════════════════════════════════════════════════╗"
log "║              BACKUP COMPLETE — SUMMARY                  ║"
log "╚══════════════════════════════════════════════════════════╝"
log ""
log "  Total size:       ${GREEN}${TOTAL_SIZE}${NC}"
log "  Total files:      ${GREEN}${TOTAL_FILES}${NC}"
log "  Duration:         ${GREEN}${MINS}m ${SECS}s${NC}"
log "  Target:           ${GREEN}${TARGET}${NC}"
log ""
log "  Phase 1 (dot dirs):    ${GREEN}${COPIED} copied${NC}, ${RED}${FAILED} failed${NC}"
log "  Phase 2 (projects):    ${GREEN}${PCOPIED} copied${NC}, ${RED}${PFAILED} failed${NC}"
log "  Phase 3 (home files):  ${GREEN}${FCOPIED} copied${NC}"
log "  Phase 4 (archives):    ${GREEN}${ACOPIED} copied${NC}"
log ""
log "  Log file: ${TARGET}/home-full-backup.log"
log ""

# Update manifest
cat >> /Volumes/macBaks/GPTJunkie/BACKUP_MANIFEST.md << 'EOF'

---

## Full Home Backup

| Directory | Description |
|-----------|-------------|
| `home-full-backup/dot-dirs/` | 70+ dot directories (AI configs, dev envs, cloud, security) |
| `home-full-backup/projects/` | 50+ project directories |
| `home-full-backup/home-files/` | Root-level files from home (.md, .txt, .csv, .json, .sh, .py, .log, dotfiles) |
| `home-full-backup/archives/` | .zip and .tar.gz archives |
| `home-full-backup/system-dirs/` | Desktop, key Documents files |
| `home-full-backup/ai-configs/` | AI tool JSON configs (.claude.json, etc.) |
| `home-full-backup/home-full-backup.log` | Full copy log |

**Exclusions:** `node_modules/`, `__pycache__/`, `*.pyc`, `.venv/`, `venv/`, `.git/` (can re-clone)
**Full home backup size:** See summary above

*Full home backup completed: $(date)*
EOF

log "✅ Backup manifest updated."
