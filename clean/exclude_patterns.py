"""Shared regex path exclusions for ~/clean scanners.

* ``FULL_EXCLUDED_PATTERNS`` — used by docs/audio/img/other/vids dry-run tools
  (base + media dirs + project-specific skips).

* ``ECOSYSTEM_EXCLUDED_PATTERNS`` — used by ecosystem_scan_compare.py: base only,
  so roots like ~/Pictures or ~/github are not blanket-skipped.
"""

from __future__ import annotations

from typing import List

# Core: dot segments, envs, language runtimes, caches, system trees, AI tool dirs.
BASE_EXCLUDED_PATTERNS: List[str] = [
    r"^\..*",
    r".*\/\..*",
    # Virtual environments
    r".*\/venv\/.*",
    r".*\/\.venv\/.*",
    r".*\/env\/.*",
    r".*\/\.env\/.*",
    r".*\/my_global_venv\/.*",
    r".*\/\.my_global_venv\/.*",
    # Python / conda roots
    r".*\/\.conda\/.*",
    r".*\/miniconda3\/.*",
    r".*\/anaconda3\/.*",
    r".*\/mambaforge\/.*",
    r".*\/micromamba\/.*",
    r".*\/lib\/.*",
    r".*\/\.lib\/.*",
    r".*\/site-packages\/.*",
    # Python caches & build outputs
    r".*\/__pycache__\/.*",
    r".*\/\.mypy_cache\/.*",
    r".*\/\.pytest_cache\/.*",
    r".*\/\.ruff_cache\/.*",
    r".*\/\.hypothesis\/.*",
    r".*\/\.tox\/.*",
    r".*\/htmlcov\/.*",
    r".*\/\.coverage.*",
    r".*\/\.eggs\/.*",
    r".*\/[^\/]+\.egg-info\/.*",
    r".*\/build\/.*",
    r".*\/dist\/.*",
    # Node.js
    r".*\/node\/.*",
    r".*\/node_modules\/.*",
    r".*\/\.npm\/.*",
    r".*\/\.yarn\/.*",
    r".*\/\.pnpm\/.*",
    r".*\/\.pnpm-store\/.*",
    # Rust
    r".*\/\.cargo\/registry\/.*",
    r".*\/\.cargo\/git\/.*",
    r".*\/\.rustup\/.*",
    # JVM / common heavy caches
    r".*\/\.gradle\/.*",
    r".*\/\.m2\/.*",
    # System & Xcode
    r".*\/Library\/.*",
    r".*\/Applications\/.*",
    r".*\/System\/.*",
    r".*\/opt\/.*",
    r".*\/usr\/.*",
    r".*\/etc\/.*",
    r".*\/var\/.*",
    r".*\/tmp\/.*",
    r".*\/bin\/.*",
    r".*\/sbin\/.*",
    r".*\/DerivedData\/.*",
    r".*\/\.Trash\/.*",
    # Generic cache / temp (use (\/.*|$) so the dir itself matches when pruning os.walk)
    r".*\/\.cache(\/.*|$)",
    r".*\/\.tmp(\/.*|$)",
    r".*\/\.temp(\/.*|$)",
    # XDG + heavy dot dirs under $HOME (~/.config, ~/.local, containers, cloud CLIs, etc.)
    r".*\/\.config(\/.*|$)",
    r".*\/\.local(\/.*|$)",
    r".*\/\.docker(\/.*|$)",
    r".*\/\.kube(\/.*|$)",
    r".*\/\.minikube(\/.*|$)",
    r".*\/\.colima(\/.*|$)",
    r".*\/\.lima(\/.*|$)",
    r".*\/\.orbstack(\/.*|$)",
    r".*\/\.terraform(\/.*|$)",
    r".*\/\.terraform\.d(\/.*|$)",
    r".*\/\.ansible(\/.*|$)",
    r".*\/\.aws(\/.*|$)",
    r".*\/\.azure(\/.*|$)",
    r".*\/\.ollama(\/.*|$)",
    r".*\/\.steam(\/.*|$)",
    r".*\/\.mozilla(\/.*|$)",
    r".*\/\.thunderbird(\/.*|$)",
    r".*\/\.wine(\/.*|$)",
    r".*\/\.dropbox(\/.*|$)",
    r".*\/Dropbox(\/.*|$)",
    r".*\/\.parallels(\/.*|$)",
    # Secrets / key material (skip when scanning)
    r".*\/\.ssh(\/.*|$)",
    r".*\/\.gnupg(\/.*|$)",
    r".*\/\.password-store(\/.*|$)",
    # Dev dot-config (often huge or non-user content)
    r".*\/\.spicetify(\/.*|$)",
    r".*\/\.gem(\/.*|$)",
    r".*\/\.zprofile(\/.*|$)",
    r".*\/\.vscode(\/.*|$)",
    r".*\/\.idea(\/.*|$)",
    r".*\/\.git(\/.*|$)",
    r".*\/\.svn(\/.*|$)",
    r".*\/\.hg(\/.*|$)",
    # AI / agent tooling (expand as needed)
    r".*\/\.claude(\/.*|$)",
    r".*\/\.cursor(\/.*|$)",
    r".*\/\.codex(\/.*|$)",
    r".*\/\.aider(\/.*|$)",
    r".*\/\.boltai(\/.*|$)",
    r".*\/\.apify(\/.*|$)",
    r".*\/\.chatgpt(\/.*|$)",
    r".*\/\.gemini(\/.*|$)",
    r".*\/\.grok(\/.*|$)",
    r".*\/\.qwen(\/.*|$)",
]

MEDIA_EXCLUDED_PATTERNS: List[str] = [
    r".*\/Movies\/.*",
    r".*\/Pictures\/.*",
    r".*\/Music\/.*",
    r".*\/Downloads\/.*",
]

PROJECT_SPECIFIC_EXCLUDED_PATTERNS: List[str] = [
    r".*\/simplegallery\/.*",
    r".*\/avatararts\/.*",
    r".*\/github\/.*",
    r".*\/Documents\/gitHub\/.*",
    r".*\/Documents\/aGPT\/.*",
]

FULL_EXCLUDED_PATTERNS: List[str] = (
    BASE_EXCLUDED_PATTERNS + MEDIA_EXCLUDED_PATTERNS + PROJECT_SPECIFIC_EXCLUDED_PATTERNS
)

ECOSYSTEM_EXCLUDED_PATTERNS: List[str] = list(BASE_EXCLUDED_PATTERNS)
