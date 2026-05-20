# ~/scripts — Exploration Overview

A single map of what’s here, how it’s organized, and where to start.  
*(Generated from exploring the repo; naming and docs are the main organization.)*

---

## 1. Layout at a glance

- **Root:** 100+ shell scripts (`.sh`), a few Perl (`.pl`), and many markdown docs.
- **No top-level `analysis/` or `merge/` folders** — those are described in README as a target layout; in practice most scripts live at **root** and are grouped by **name**.
- **agent_forge/** — Python-based orchestration for AvatarArts + GPTJunkie (XEO, keyword radar, provenance, mission planner).
- **psd-tools/** — Separate Python project (PSD file handling); has its own git and lifecycle (see CLAUDE.md).

So: **flat root + agent_forge/** is the real structure; README/INDEX describe an aspirational or alternate grouping.

---

## 2. Naming patterns (root scripts)

Organization is by **prefix/suffix**. Use these to find things:

| Pattern | What it is | Examples |
|--------|------------|----------|
| `setup_*`, `install_*` | Env/bootstrap/install | setup-mamba.sh, setup_uv_project.sh, setup-ai-apis.sh, install_vision.sh |
| `cleanup_*`, `clean_*`, `remove_*` | Cleanup and maintenance | mac-cleanup-pro.sh, cleanup_home.sh, cleanup_safe.sh, remove-unused-python-packages.sh |
| `run_*`, `launch_*`, `start_*` | Entry points / orchestration | run_update.sh, RUN_ALL_PROJECTS.sh, start_analytics.sh |
| `analyze_*` | Analysis and scanning | analysis_launcher.sh, analyze_local_dirs.sh, analyze_and_integrate_clean.sh |
| `update_*`, `*updater*` | Updates | updater-pro.sh, update_enhanced.sh, evolution-updater.sh |
| `merge_*` | Merge/consolidation | merge_diff.sh, merge_similar_markdown.sh |
| `rename_*`, `*_rename*` | Renaming / content-aware rename | content_aware_rename.sh, rename_first_10.sh, safe_recursive_rename.sh |
| `*_cleanup*`, `*cleanup*` | Cleanup (various scopes) | package_manager_cleanup.sh, cleanup_archive_node_modules.sh |
| `advanced-*` | Heavier / multi-feature | advanced-system-maintenance-v5.sh (when present) |
| `*_setup*`, `setup_*` | Setup/configuration | setup_grok.sh, setup_ai_tools_config.sh |

**Key entry points:**

- **START_HERE.sh** — Intro to the “Fluid Adaptive Analysis” flow; points to analysis_launcher and docs.
- **master_script_manager.sh** — Central menu: list, run, health, maintenance (e.g. `--action menu`).
- **updater-pro.sh** — Full package update run; suggests running **mac-cleanup-pro.sh** after.
- **analysis_launcher.sh** — Analysis tasks (e.g. `current`, `help`).

---

## 3. agent_forge/ — What it is and where things live

**Purpose:** AvatarArts + GPTJunkie tooling: keywords, missions, provenance, XEO (index/SEO/entity) audits.

**Layout:**

```
agent_forge/
├── apps/          # CLI apps + shared libs
│   ├── keyword_radar.py, mission_planner.py, provenance_audit.py, xeo_audit.py
│   └── lib_gsc.py, lib_xeo.py, lib_provenance.py, lib_trends.py
├── mcp/           # MCP-style servers (keyword_intel, provenance, xeo_strategy)
├── scripts/       # Wrappers
│   ├── bootstrap_agent_forge.sh
│   ├── run_keyword_radar.sh, run_mission_planner.sh, run_provenance_audit.sh
│   └── run_xeo_suite.sh both
├── config/        # (if present) domain/agent config
├── skills/        # (if present) SKILL.md bundles
├── reports/       # (generated) audit/strategy outputs
└── subagents/     # (if present) subagent definitions
```

**Run from repo root:**

```bash
# Bootstrap
bash agent_forge/scripts/bootstrap_agent_forge.sh

# Keyword radar
python3 agent_forge/apps/keyword_radar.py --domain both --top 20 --format markdown --out agent_forge/reports/keyword_radar.md

# Mission plan
python3 agent_forge/apps/mission_planner.py --domain gptjunkie --weeks 6 --out agent_forge/reports/plan.md

# Provenance audit
python3 agent_forge/apps/provenance_audit.py --input /path/to/video.mp4 --json agent_forge/reports/provenance.json --markdown agent_forge/reports/provenance.md

# Full XEO suite
bash agent_forge/scripts/run_xeo_suite.sh both
```

Domains: `avatararts` | `gptjunkie` | `both`. Reports go under `agent_forge/reports/` (and may create the dir).

---

## 4. Cleanup and maintenance (root)

- **CLEANUP_SCRIPTS_COMPARISON.md** — Table of all cleanup scripts and when to use each.
- **mac-cleanup-pro.sh** — Post–updater-pro cleanup: Homebrew, Yarn/npm/pip/Bun, batched .pyc (incl. miniforge3), extra caches (Mamba/UV/cargo-cache/pnpm). `-v`, `--dry-run`.
- **enhanced_cleanup.sh** — Deeper clean (e.g. ~/Library/Caches, app caches); `--dry-run`, `--force`.
- **cleanup_home.sh** — Aggressive ~/ (e.g. .npm, .cursor, .Trash, .local subdirs).
- **python-env-cleanup.sh** — Python/miniforge/pip focus; `--dry-run`.
- **package_manager_cleanup.sh** — Brew/npm/pip with backups and recommendations.
- **cleanup_safe.sh** — Minimal: symlinks, small caches, .env.d/backups.

Suggested flow: after **updater-pro.sh** → **mac-cleanup-pro.sh**; for bigger cleans → **enhanced_cleanup.sh** (see CLEANUP_SCRIPTS_COMPARISON.md).

---

## 5. Docs that matter

| File | Use |
|------|-----|
| **CLAUDE.md** | Canonical repo overview, structure, commands, conventions (for AI and humans). |
| **AGENTS.md** | Project structure, build/test, style, commit/PR guidelines. |
| **README.md** | High-level org and categories (analysis/merge/organize); some paths assume subdirs that aren’t at root. |
| **INDEX.md** | Conceptual index (cleanup/, setup/, automation/, etc.); may reference ~/scripts/sh/. |
| **CLEANUP_SCRIPTS_COMPARISON.md** | Which cleanup script to run when. |
| **DOCUMENTATION.md** | Advanced system maintenance (versions, features, config). |
| **MAINTENANCE_SCRIPTS_*.md** | Maintenance scripts docs, examples, best practices. |
| **START_HERE.sh** | Points to QUICK_REFERENCE.md, INDEX.md, analysis_launcher. |

For “how is this repo meant to be used,” **CLAUDE.md** and **AGENTS.md** are the most accurate; README/INDEX are useful for intent and categories.

---

## 6. Other notable areas

- **Audio/video:** transcribe.sh, process_music.sh, mp4-txt.sh, convert_to_mp3s.sh, webm_to_mp3.sh, mp3toMp4.sh.
- **Images:** carbon_image_analyze_optimize.sh, cleanup_carbon_images.sh, optimize_pngs.sh, png.sh, split_tall_images.sh, cleanimg.sh.
- **AI/LLM:** grok_menu.sh, grok-interactive.sh, setup_grok.sh, ollama_*.sh, ai-cli-diagnostics.sh, initialize-ai-resources.sh.
- **MCP / process:** mcp-process-manager.sh, setup_mcp_servers.sh.
- **DB/backup:** mysqlbackup.pl, backup_pgsql.sh, start_postgres.sh.
- **Security/env:** enhanced_encrypt_sensitive_env_files.sh, check_env_keys.sh, setup-env-d-only.sh.
- **Git:** cleanup_git.sh, efficient_git_cleanup.sh, aggressive_git_cleanup.sh.
- **Content/rename:** content_aware_rename.sh, recursive_content_aware_rename.sh, complete_content_aware_rename_fixed.sh, safe_recursive_rename.sh.
- **AvatarArts:** avatararts.sh, AVATARARTS_RESTRUCTURING_MASTER.sh.

---

## 7. Quick commands (from ~ or ~/scripts)

```bash
# Start / explore
./scripts/START_HERE.sh
./scripts/master_script_manager.sh --action menu

# Update then cleanup
./scripts/updater-pro.sh
./scripts/mac-cleanup-pro.sh

# Analysis
./scripts/analysis_launcher.sh help
./scripts/analysis_launcher.sh current

# Agent Forge (from repo root)
bash scripts/agent_forge/scripts/run_xeo_suite.sh both
python3 scripts/agent_forge/apps/keyword_radar.py --domain both --top 20 --format markdown --out scripts/agent_forge/reports/keyword_radar.md

# Cleanup comparison
cat scripts/CLEANUP_SCRIPTS_COMPARISON.md
```

---

## 8. Summary

- **Structure:** Flat root (100+ scripts) + **agent_forge/** (Python apps + MCP + scripts); **naming** is the main organization.
- **Authoritative docs:** **CLAUDE.md**, **AGENTS.md**; README/INDEX describe categories and intent; CLEANUP_SCRIPTS_COMPARISON.md is the cleanup map.
- **Entry points:** START_HERE.sh, master_script_manager.sh, updater-pro.sh → mac-cleanup-pro.sh, analysis_launcher.sh, agent_forge/scripts/*.sh.
- **Agent Forge:** Domain-focused (AvatarArts, GPTJunkie); run via apps/*.py or scripts/run_*.sh; outputs in reports/.

Use this as a map; for exact paths and options, rely on script `--help` and CLAUDE.md.
