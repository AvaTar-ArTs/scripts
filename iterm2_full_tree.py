#!/usr/bin/env python3
"""
Recursively list every file and folder under given roots (unlimited depth).
Writes one sorted path per line to fulltree_<name>.txt.
Usage: python3 iterm2_full_tree.py [--out-dir DIR] [roots...]
Default roots: iterm2 target dirs (.claude, .cursor, .gemini, .git, .grok, .qodo, .qwen, agent_ops, claude-ecosystem, Codex, cursor-ecosystem, docs, gemini, scripts, superpowers-codex-product)
Default out-dir: scripts/iterm2_full_trees
"""

from __future__ import annotations

import argparse
import os
from pathlib import Path

ITERN2 = Path("/Users/steven/iterm2")
DEFAULT_ROOTS = [
    ".claude",
    ".cursor",
    ".gemini",
    ".grok",
    ".qodo",
    ".qwen",
    "agent_ops",
    "claude-ecosystem",
    "Codex",
    "cursor-ecosystem",
    "docs",
    "gemini",
    "scripts",
    "superpowers-codex-product",
]


def walk_all(root: Path) -> list[str]:
    """Recurse unlimited depth; return sorted list of relative paths (dirs and files)."""
    out: list[str] = []
    root = root.resolve()
    try:
        for dirpath, dirnames, filenames in os.walk(root, topdown=True):
            try:
                rel = Path(dirpath).relative_to(root)
            except ValueError:
                rel = Path(dirpath)
            base_rel = str(rel) if rel != Path(".") else "."
            out.append(base_rel)
            for d in sorted(dirnames):
                out.append(f"{base_rel}/{d}" if base_rel != "." else d)
            for f in sorted(filenames):
                out.append(f"{base_rel}/{f}" if base_rel != "." else f)
    except OSError as e:
        out.append(f"<error: {e}>")
    return sorted(set(out))


def main() -> int:
    ap = argparse.ArgumentParser(description="Full recursive tree of iterm2 dirs")
    ap.add_argument("--out-dir", type=Path, default=Path(__file__).resolve().parent / "iterm2_full_trees", help="Output directory for fulltree_*.txt")
    ap.add_argument("roots", nargs="*", default=DEFAULT_ROOTS, help="Subdir names under iterm2 (or absolute paths)")
    args = ap.parse_args()

    args.out_dir.mkdir(parents=True, exist_ok=True)
    base = ITERN2

    for name in args.roots:
        if os.path.isabs(name):
            root = Path(name)
            label = root.name
        else:
            root = base / name
            label = name.replace("/", "_").replace(".", "_") or "root"
        if not root.exists():
            print(f"Skip (missing): {root}")
            continue
        paths = walk_all(root)
        out_file = args.out_dir / f"fulltree_{label}.txt"
        out_file.write_text("\n".join(paths) + "\n", encoding="utf-8", errors="replace")
        print(f"{label}: {len(paths)} entries -> {out_file}")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
