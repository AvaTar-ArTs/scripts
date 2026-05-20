# Cleanup Scripts in ~/scripts — Comparison

Quick reference for which script to run and how they differ. **mac-cleanup-pro.sh** is the light, post-update option; others are heavier or focused on specific areas.

---

## At a glance

| Script | When to use | Homebrew | Yarn/npm/pip | Python .pyc / cache | ~/ scope | Backups / options |
|--------|-------------|----------|--------------|----------------------|----------|-------------------|
| **mac-cleanup-pro.sh** | After **updater-pro.sh** (light, fast) | cleanup -s, autoremove | yarn, npm, pip, **Bun** cache only | .pyc in Caches, .local, Library/Python, .cache, **miniforge3**, /usr/local, /opt/homebrew; **Extra:** Mamba/Conda, UV, cargo-cache, pnpm | Targeted + extra if present | **-v**, **--dry-run**; batched .pyc; refuses root |
| **cleanup_system.sh** | Package-manager-only cleanup | update, upgrade, cleanup, autoremove | pip cache, npm, yarn | — | — | No |
| **package_manager_cleanup.sh** | Organize + clean + get recommendations | cleanup -s, autoremove | npm cache, npm update -g | — | Writes backup lists to ~ | Yes (brew/npm/pip lists); no dry-run |
| **enhanced_cleanup.sh** | Full Mac cleanup (5–15 GB potential) | Brew cache wipe | npm, VS Code, Cursor, Rust, Bun | — | ~/Library/Caches/*, app caches | **--dry-run**, **--force** |
| **cleanup.sh** | Same family as enhanced (targeted, no sudo) | Yes | Same as enhanced | — | Same | **--force** |
| **cleanup_safe.sh** | Minimal, very safe (symlinks, small caches) | — | npm temp only | — | ~/.cache, .claude, .npm, .rustup, .env.d/backups | Archives backups; installs some pip pkgs |
| **cleanup_home.sh** | Aggressive home-dir cleanup (before/after sizes) | — | **Full** ~/.npm delete | — | .npm, .local (partial), .nvm, .x-cmd, .gemini, .qwen, .Trash, .vscode, .cursor, .claude, .bun, ruff/pytest/mypy | No |
| **back-clean.sh** | Backup then clean + new venv | cleanup, autoremove | — | — | Backs up brew/pip lists; creates new venv | Yes (brew/pip lists, new venv) |
| **automated_cleanup.sh** | One-shot disk cleanup (logs, pyc, zips, tmp) | — | npm, pip cache | **All ~/** __pycache__ and .pyc | Full ~/ for pyc/tmp/zips; **rm -rf ~/Library/Caches/*** | No |
| **final-aggressive-cleanup.sh** | Deep clean (Claude versions, UV, Jupyter) | — | — | — | Claude versions, UV cache, Jupyter (report only) | No |
| **python-env-cleanup.sh** | Python-only (caches + miniforge + pip) | — | pip cache | ~/.local, ~/Library/Python | Python envs only | **--dry-run** |
| **cleanup_large_folders.sh** | Large dirs with backups (.claude, .gemini, etc.) | — | — | — | .claude, .gemini, .ollama, .cache, .local, GitHub, .cursor, .eigent, .x-cmd, .config | Backs up important files |
| **library_cleanup.sh** | ~/Library only (browsers, Cursor, Code) | brew cleanup | — | — | Library Caches, Cursor, Code, Chrome | No |
| **cleanup_temp_files.sh** | Only *.tmp, .tmp*, tmp/ and temp/ dirs | — | — | — | Full /Users/steven | No |

---

## Overlap with mac-cleanup-pro.sh

- **cleanup_system.sh** — Same idea (Homebrew + pip + npm + Yarn) but also runs `brew update`/`upgrade`; no Python .pyc. Use **mac-cleanup-pro** after updater-pro for cache/bytecode only; use **cleanup_system** when you want package-manager cleanup without running the full updater.
- **package_manager_cleanup.sh** — Adds backups and recommendations; runs `npm update -g`. Use when you want lists saved and npm global updates; use **mac-cleanup-pro** for a quick cache/bytecode pass with no backups.
- **enhanced_cleanup.sh** / **cleanup.sh** — Wipe ~/Library/Caches and more app caches; have **--dry-run** / **--force**. Use for a big cleanup; use **mac-cleanup-pro** for a small, non-destructive follow-up after updates.
- **automated_cleanup.sh** — Cleans **all** ~/ .pyc and __pycache__, plus tmp/zips and **~/Library/Caches/***. Use for a one-off deep clean; **mac-cleanup-pro** only touches .pyc in specific roots and does **not** wipe Caches.
- **python-env-cleanup.sh** — Python caches + miniforge + pip; has **--dry-run**. Use for Python-focused cleanup; **mac-cleanup-pro** does a lighter .pyc pass in the same kinds of dirs plus system Python.

---

## Suggested workflow

1. **After updater-pro.sh:**  
   `./mac-cleanup-pro.sh`

2. **Weekly or when disk is tight:**  
   `./enhanced_cleanup.sh --dry-run` then `./enhanced_cleanup.sh` (or `./cleanup.sh`).

3. **Python/env tune-up:**  
   `./python-env-cleanup.sh --dry-run` then `./python-env-cleanup.sh`.

4. **Big home clean (aggressive):**  
   `./cleanup_home.sh` or `./cleanup_large_folders.sh` (latter backs up first).

5. **Only temp files:**  
   `./cleanup_temp_files.sh`.

---

## Other cleanup-related scripts (different focus)

- **cleanup_git.sh** — Remove .git from archived/old projects.
- **cleanup_archive_node_modules.sh** — Archive and trim node_modules in an archive dir.
- **cleanup_conda_envs.sh** — Conda env and cache cleanup.
- **cleanup_duplicates.sh** — Duplicate file handling.
- **cleanup_carbon_images.sh** — Carbon images directory.
- **Documents-cleanup.sh** — ~/Documents.
- **efficient_git_cleanup.sh** / **aggressive_git_cleanup.sh** — Git repos (e.g. AVATARARTS).
- **create_cleanup_csv.sh** / **disk_cleanup_analysis.sh** — Analysis/recommendations, not execution.
- **cleanup_local_dirs.sh** — .local/lib, .local/share/claude, cursor-agent.
- **cleanup_app_integration.sh** / **enhanced_disk_cleanup.sh** — Integration / phased disk cleanup.

---

## Suggestions and possible improvements

- **mac-cleanup-pro.sh** — Already improved with `--dry-run`, root check, duration, Bun cache, and one-line summary. Optional future ideas: optional log file (e.g. `--log`), or estimate space freed (e.g. `du` before/after for pip/npm cache dirs).
- **Unify options** — Several scripts use `--dry-run` (enhanced_cleanup, python-env-cleanup, mac-cleanup-pro); others don’t. Adding `--dry-run` to cleanup_system, package_manager_cleanup, and cleanup_home would make behavior more consistent.
- **Safety** — More scripts could refuse to run as root (like mac-cleanup-pro) to avoid accidental system-wide changes.
- **Reporting** — Scripts that delete a lot (e.g. automated_cleanup, enhanced_cleanup) could print total bytes freed (e.g. `du` before/after) or at least a short “Summary: …” line like mac-cleanup-pro.
- **Consolidation** — cleanup.sh and enhanced_cleanup.sh are very similar; one could call the other with a flag, or the comparison doc could be the single “which script when” reference (as here).
