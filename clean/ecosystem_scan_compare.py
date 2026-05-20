#!/usr/bin/env python3
"""Scan home ecosystem dirs with ~/clean document rules (ecosystem-tuned exclusions).

Compares live ``du`` + document-type file counts to ``filesystem_master_index_*.txt``
and summarizes ``2T-Xx_inventory_report.txt``.

Exclusions mirror ``docs.py`` ``generate_dry_run_csv`` except the "Specific project
directories" regex block is omitted so roots like ``~/github`` are actually scanned.
"""

from __future__ import annotations

import csv
import os
import re
import subprocess
import sys
from datetime import datetime
from pathlib import Path

from exclude_patterns import ECOSYSTEM_EXCLUDED_PATTERNS

# Same base rules as dry-run scanners, but without media / project-specific skips
# (see exclude_patterns.py).
EXCLUDED_PATTERNS = ECOSYSTEM_EXCLUDED_PATTERNS

DOC_EXTENSIONS = {
    ".pdf",
    ".csv",
    ".html",
    ".css",
    ".js",
    ".json",
    ".sh",
    ".md",
    ".txt",
    ".doc",
    ".docx",
    ".ppt",
    ".pptx",
    ".xlsx",
    ".py",
    ".xml",
}

DEFAULT_TARGETS = [
    "/Users/steven/2T-Xx-paths-chunks",
    "/Users/steven/agent_forge",
    "/Users/steven/agent-transcripts",
    "/Users/steven/AI_Chats",
    "/Users/steven/ai_merge_auto",
    "/Users/steven/aider-env",
    "/Users/steven/Applications",
    "/Users/steven/AutoTagger",
    "/Users/steven/autotagger-lite",
    "/Users/steven/AvaTarArTs",
    "/Users/steven/backups",
    "/Users/steven/book_of_memory",
    "/Users/steven/claudemarketplaces.com",
    "/Users/steven/clean",
    "/Users/steven/codex-upgrades",
    "/Users/steven/Development",
    "/Users/steven/DOC-sorted",
    "/Users/steven/Documents",
    "/Users/steven/Downloads",
    "/Users/steven/Fancy-Advanced-Med-journals",
    "/Users/steven/file-tracker",
    "/Users/steven/Fixes",
    "/Users/steven/fuzzy-finder",
    "/Users/steven/git-ai",
    "/Users/steven/github",
    "/Users/steven/grok",
    "/Users/steven/ice-tracker",
    "/Users/steven/iterm2",
    "/Users/steven/iterm2_prompt-engineering-exploration",
    "/Users/steven/iterm2-fix",
    "/Users/steven/MarketMaster",
    "/Users/steven/Master CodeSnip dev",
    "/Users/steven/MasterxEo",
    "/Users/steven/mcPHooker",
    "/Users/steven/mcphooker-lite",
    "/Users/steven/Miniforge_Mamba_Analysis",
    "/Users/steven/my_crew",
    "/Users/steven/my-simple",
    "/Users/steven/nocTurneMeLoDieS",
    "/Users/steven/nocTurneMeLoDieS_HTML_Archive",
    "/Users/steven/p-market",
    "/Users/steven/Pictures",
    "/Users/steven/PYTHON_MARKETPLACE_MASTER",
    "/Users/steven/python_syntax_fix_report",
    "/Users/steven/python-marketplace-inventory",
    "/Users/steven/pythons",
    "/Users/steven/reports",
    "/Users/steven/scripts",
    "/Users/steven/simplegallery",
    "/Users/steven/Sora",
    "/Users/steven/sora_outputs",
    "/Users/steven/sora_outputs_master",
    "/Users/steven/sora_outputs_v3",
    "/Users/steven/sora_outputs_v4",
    "/Users/steven/sora-remover",
    "/Users/steven/test",
    "/Users/steven/tester",
    "/Users/steven/tools",
    "/Users/steven/upWork",
    "/Users/steven/userscripts",
    "/Users/steven/zombot-simple-gallery",
    "/Users/steven/Zotero",
]


def path_excluded(file_path: str) -> bool:
    return any(re.match(p, file_path) for p in EXCLUDED_PATTERNS)


def scan_doc_files(root: str) -> tuple[int, int]:
    """Return (count, total_bytes) for document-class files under root."""
    count = 0
    total_b = 0
    root = os.path.abspath(root)
    if not os.path.isdir(root):
        return 0, 0
    for walk_root, dirs, files in os.walk(root):
        dirs[:] = [
            d
            for d in dirs
            if not any(re.match(p, os.path.join(walk_root, d)) for p in EXCLUDED_PATTERNS)
        ]
        for name in files:
            fp = os.path.join(walk_root, name)
            if path_excluded(fp):
                continue
            ext = os.path.splitext(name)[1].lower()
            if ext not in DOC_EXTENSIONS:
                continue
            try:
                st = os.stat(fp, follow_symlinks=False)
                if os.path.islink(fp):
                    continue
                total_b += st.st_size
                count += 1
            except OSError:
                continue
    return count, total_b


def du_sk(path: str) -> int | None:
    try:
        r = subprocess.run(
            ["du", "-sk", path],
            capture_output=True,
            text=True,
            timeout=600,
            check=False,
        )
        if r.returncode != 0 or not r.stdout:
            return None
        return int(r.stdout.split()[0])
    except (ValueError, subprocess.TimeoutExpired, OSError):
        return None


def strip_ansi(s: str) -> str:
    return re.sub(r"\x1b\[[0-9;]*m", "", s)


def parse_master_index(path: Path) -> dict[str, dict[str, str]]:
    """Map normalized path -> {index_files, index_size_str}."""
    if not path.is_file():
        return {}
    text = strip_ansi(path.read_text(encoding="utf-8", errors="replace"))
    out: dict[str, dict[str, str]] = {}
    # 📁 ... (/Users/steven/...)
    block_re = re.compile(
        r"📁[^\n]*\((/Users/steven[^)]+)\)[^\n]*\n[^\n]*🔢 Files:\s*(\d+)\s*\|\s*Size:\s*([^\n]+)",
    )
    for m in block_re.finditer(text):
        p, n, sz = m.group(1), m.group(2), m.group(3).strip()
        out[os.path.normpath(p)] = {"index_files": n, "index_size": sz}
    return out


def parse_twot_xx_report(path: Path) -> str:
    if not path.is_file():
        return ""
    return path.read_text(encoding="utf-8", errors="replace")[:4000]


def human_kb(kb: int) -> str:
    if kb < 1024:
        return f"{kb}K"
    mb = kb / 1024
    if mb < 1024:
        return f"{mb:.1f}M"
    return f"{mb / 1024:.1f}G"


def main() -> int:
    home = Path.home()
    ts = datetime.now().strftime("%Y-%m-%d_%H-%M-%S")
    out_csv = home / "clean" / f"ecosystem_scan_{ts}.csv"
    out_md = home / "clean" / f"ecosystem_scan_{ts}_compare.md"

    targets = [os.path.expanduser(p) for p in (sys.argv[1:] or DEFAULT_TARGETS)]
    master_path = home / "filesystem_master_index_20260208_064111.txt"
    master = parse_master_index(master_path)
    twot = home / "2T-Xx_inventory_report.txt"

    rows: list[dict[str, str]] = []
    for raw in targets:
        p = Path(raw)
        if not p.exists():
            rows.append(
                {
                    "path": raw,
                    "exists": "no",
                    "du_kb": "",
                    "doc_files": "",
                    "doc_bytes": "",
                    "index_files": "",
                    "index_size": "",
                    "index_match": "n/a",
                }
            )
            continue
        if p.is_file():
            try:
                sz = p.stat().st_size
            except OSError:
                sz = 0
            rows.append(
                {
                    "path": raw,
                    "exists": "file",
                    "du_kb": str((sz + 1023) // 1024),
                    "doc_files": "0",
                    "doc_bytes": "0",
                    "index_files": "",
                    "index_size": "",
                    "index_match": "n/a",
                }
            )
            continue
        rp = os.path.normpath(str(p.resolve()))
        kb = du_sk(rp)
        dcount, dbytes = scan_doc_files(rp)
        meta = master.get(rp, {})
        idx_f = meta.get("index_files", "")
        idx_s = meta.get("index_size", "")
        match = "no_index_entry"
        if idx_f:
            # index "files" is total files in that section, not doc-class only — informational
            match = "path_in_master_index"
        rows.append(
            {
                "path": rp,
                "exists": "dir",
                "du_kb": str(kb) if kb is not None else "",
                "du_human": human_kb(kb) if kb is not None else "",
                "doc_files": str(dcount),
                "doc_bytes": str(dbytes),
                "index_files": idx_f,
                "index_size": idx_s,
                "index_match": match,
            }
        )
        print(f"OK {rp} du={kb}K docs={dcount}", flush=True)

    fieldnames = [
        "path",
        "exists",
        "du_kb",
        "du_human",
        "doc_files",
        "doc_bytes",
        "index_files",
        "index_size",
        "index_match",
    ]
    with open(out_csv, "w", newline="", encoding="utf-8") as f:
        w = csv.DictWriter(f, fieldnames=fieldnames, extrasaction="ignore")
        w.writeheader()
        for r in rows:
            w.writerow(r)

    # Markdown summary
    lines = [
        f"# Ecosystem scan vs metadata ({ts})",
        "",
        "## Method",
        "- **Document-class files**: same extensions as `~/clean/docs.py` dry-run, with ecosystem exclusions (see script header).",
        "- **`du -sk`**: total disk use per directory (includes skipped trees like `.git`).",
        "- **Master index**: keys from `filesystem_master_index_20260208_064111.txt` where a `📁 ... (/Users/steven/...)` block exists. Index **file counts are total files**, not document-class only — use for spot-check, not equality.",
        "",
        "## 2T-Xx report (excerpt)",
        "```",
        parse_twot_xx_report(twot)[:2500],
        "```",
        "",
        "## Per-target",
        "",
        "| Path | du | doc files | doc MiB | master index files | master size |",
        "|------|-----|-----------|---------|-------------------|-------------|",
    ]
    for r in rows:
        if r.get("exists") != "dir":
            continue
        dp = r["path"]
        duh = r.get("du_human") or r.get("du_kb", "")
        dc = r.get("doc_files", "")
        db = int(r.get("doc_bytes") or 0)
        dmib = f"{db / (1024 * 1024):.1f}" if db else "0"
        lines.append(
            f"| `{Path(dp).name}` | {duh} | {dc} | {dmib} | {r.get('index_files', '')} | {r.get('index_size', '')} |"
        )
    lines.append("")
    lines.append(f"Full CSV: `{out_csv}`")
    out_md.write_text("\n".join(lines), encoding="utf-8")

    print(out_csv)
    print(out_md)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
