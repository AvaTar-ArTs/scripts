#!/usr/bin/env python3
"""
all.py — Enhanced Universal File Scanner & Organizer
Combines: docs.py, audio.py, vids.py, img.py, other.py, cleanup_and_organize.py,
          batch-info.py, ecosystem_scan_compare.py, config.py
Plus: AutoTagger integration, SHA256 dedup, CSV-driven enforcement, progress bars
"""

# ─── Environment Loading (from all.py + batch-info.py) ───
import os
import sys
import csv
import re
import json
import hashlib
import logging
import argparse
import shutil
from pathlib import Path as PathLib
from datetime import datetime
from typing import Optional, Dict, List, Tuple
from collections import defaultdict, Counter
from concurrent.futures import ThreadPoolExecutor, as_completed

# Load ~/.env.d/ first, then ~/.env fallback
def load_env_d():
    env_d_path = PathLib.home() / ".env.d"
    if env_d_path.exists():
        for env_file in env_d_path.glob("*.env"):
            try:
                with open(env_file) as f:
                    for line in f:
                        line = line.strip()
                        if line and not line.startswith("#") and "=" in line:
                            if line.startswith("export "):
                                line = line[7:]
                            key, value = line.split("=", 1)
                            key = key.strip()
                            value = value.strip().strip("'").strip('"')
                            if not key.startswith("source"):
                                os.environ[key] = value
            except Exception as e:
                print(f"Warning: Error loading {env_file}: {e}")

load_env_d()
try:
    from dotenv import load_dotenv
    load_dotenv(os.path.expanduser("~/.env"))
except ImportError:
    pass

# ─── Logging ───
logging.basicConfig(level=logging.INFO, format="%(asctime)s - %(levelname)s - %(message)s")

# ─── Exclude Patterns (from exclude_patterns.py) ───
try:
    from exclude_patterns import FULL_EXCLUDED_PATTERNS
    _EXCLUDES = FULL_EXCLUDED_PATTERNS
except ImportError:
    _EXCLUDES = [
        r'.*\.git/.*', r'.*node_modules/.*', r'.*__pycache__/.*',
        r'.*\.venv/.*', r'.*venv/.*', r'.*site-packages/.*',
    ]

def should_skip(path: str, excludes=None) -> bool:
    patterns = excludes or _EXCLUDES
    return any(re.match(p, path) for p in patterns)

# ─── File Type Categories ───
FILE_TYPES = {
    # Documents (from docs.py)
    ".pdf": "Document", ".csv": "Data", ".html": "Web", ".css": "Web",
    ".js": "Code", ".json": "Data", ".sh": "Script", ".md": "Doc",
    ".txt": "Text", ".doc": "Document", ".docx": "Document",
    ".ppt": "Presentation", ".pptx": "Presentation",
    ".xlsx": "Spreadsheet", ".py": "Code", ".xml": "Data",
    # Audio (from audio.py)
    ".mp3": "Audio", ".wav": "Audio", ".flac": "Audio", ".ogg": "Audio",
    ".m4a": "Audio", ".aac": "Audio", ".wma": "Audio",
    # Video (from vids.py)
    ".mp4": "Video", ".mov": "Video", ".avi": "Video", ".mkv": "Video",
    ".webm": "Video", ".m4v": "Video",
    # Images (from img.py)
    ".jpg": "Image", ".jpeg": "Image", ".png": "Image", ".bmp": "Image",
    ".gif": "Image", ".tiff": "Image", ".svg": "Image", ".webp": "Image",
    # Other (from other.py)
    ".ttf": "Font", ".otf": "Font", ".woff": "Font", ".woff2": "Font",
    ".eot": "Font", ".srt": "Subtitle", ".vtt": "Subtitle",
    ".zip": "Archive", ".tar": "Archive", ".gz": "Archive",
    ".rar": "Archive", ".7z": "Archive",
}

# ─── Metadata Extractors ───

# Audio metadata (from audio.py + Mutagen)
def get_audio_metadata(filepath: str) -> Optional[Dict]:
    try:
        from mutagen.mp3 import MP3
        from mutagen.easyid3 import EasyID3
        audio = MP3(filepath, ID3=EasyID3)
        return {
            "duration_sec": audio.info.length,
            "bitrate": audio.info.bitrate,
            "sample_rate": audio.info.sample_rate,
            "channels": audio.info.channels,
        }
    except Exception:
        return None

# Video metadata (from vids.py + Mutagen MP4)
def get_video_metadata(filepath: str) -> Optional[Dict]:
    try:
        from mutagen.mp4 import MP4
        file = MP4(filepath)
        return {
            "duration_sec": file.info.length,
        }
    except Exception:
        return None

# Image metadata (from img.py + PIL)
def get_image_metadata(filepath: str) -> Optional[Dict]:
    try:
        from PIL import Image
        with Image.open(filepath) as img:
            w, h = img.size
            dpi = img.info.get("dpi", (None, None))
            return {
                "width": w, "height": h,
                "dpi_x": dpi[0] if dpi else None,
                "dpi_y": dpi[1] if dpi else None,
                "mode": img.mode,
                "format": img.format,
            }
    except Exception:
        return None

# Code metadata (from batch-info.py content analysis)
def get_code_metadata(filepath: str) -> Optional[Dict]:
    try:
        with open(filepath, 'r', encoding='utf-8', errors='ignore') as f:
            content = f.read()
        lines = content.split('\n')
        return {
            "lines": len(lines),
            "chars": len(content),
            "has_imports": 'import ' in content or 'from ' in content,
            "has_main": '__main__' in content,
            "has_class": 'class ' in content,
            "has_function": 'def ' in content,
        }
    except Exception:
        return None

# SHA256 hash for dedup (new)
def sha256_file(filepath: str, chunk_size: int = 65536) -> str:
    h = hashlib.sha256()
    try:
        with open(filepath, 'rb') as f:
            for chunk in iter(lambda: f.read(chunk_size), b""):
                h.update(chunk)
        return h.hexdigest()
    except Exception:
        return ""

# ─── Utility Functions ───

def get_creation_date(filepath: str) -> str:
    try:
        return datetime.fromtimestamp(os.path.getctime(filepath)).strftime("%m-%d-%y")
    except Exception:
        return "Unknown"

def format_file_size(size_in_bytes: int) -> str:
    for factor, suffix in [(1<<40,"TB"), (1<<30,"GB"), (1<<20,"MB"), (1<<10,"KB"), (1,"B")]:
        if size_in_bytes >= factor:
            return f"{size_in_bytes / factor:.2f} {suffix}"
    return f"{size_in_bytes} B"

def format_duration(seconds: Optional[float]) -> str:
    if seconds is None:
        return "Unknown"
    h = int(seconds // 3600)
    m = int((seconds % 3600) // 60)
    s = int(seconds % 60)
    if h > 0:
        return f"{h}:{m:02d}:{s:02d}"
    return f"{m}:{s:02d}"

# ─── Progress Bar (new) ───
def print_progress(current: int, total: int, prefix: str = "Progress", width: int = 50):
    pct = current / total if total > 0 else 0
    filled = int(width * pct)
    bar = "█" * filled + "░" * (width - filled)
    print(f"\r{prefix}: |{bar}| {current}/{total} ({pct*100:.1f}%)", end="", flush=True)
    if current == total:
        print()  # Newline when done

# ─── Main Scanner ───
def scan_directories(
    directories: List[str],
    output_csv: str,
    include_types: Optional[set] = None,
    enable_dedup: bool = False,
    enable_metadata: bool = True,
    max_workers: int = 4,
    csv_enforce_limit: Optional[int] = None,
    csv_enforce_source: Optional[str] = None,
    excludes: Optional[List[str]] = None,
):
    """Scan directories and produce comprehensive CSV with metadata."""

    print(f"🔍 Scanning {len(directories)} directories...")
    print(f"📄 Output: {output_csv}")
    if enable_dedup:
        print("🔒 SHA256 dedup enabled")
    if csv_enforce_source:
        print(f"📖 CSV enforcement: {csv_enforce_source} (max {csv_enforce_limit} rows)")

    # Load CSV enforcement list if specified
    enforce_uids = set()
    if csv_enforce_source and os.path.exists(csv_enforce_source):
        import csv as csv_mod
        with open(csv_enforce_source, "r", encoding="utf-8", errors="ignore") as f:
            for row in csv_mod.DictReader(f):
                uid = row.get("ID", "").strip()
                if uid:
                    enforce_uids.add(uid)
        print(f"📖 CSV enforcement: {len(enforce_uids)} authorized tracks")

    # Collect all files
    all_files = []
    for directory in directories:
        dir_path = PathLib(directory)
        if not dir_path.exists():
            print(f"⚠️  Directory not found: {directory}")
            continue
        for root, dirs, files in os.walk(dir_path):
            # Apply exclude patterns
            dirs[:] = [d for d in dirs if not should_skip(os.path.join(root, d), excludes)]
            for fname in files:
                fpath = os.path.join(root, fname)
                if should_skip(fpath, excludes):
                    continue
                ext = os.path.splitext(fname)[1].lower()
                if include_types and ext not in include_types:
                    continue
                all_files.append(fpath)

    print(f"📂 Found {len(all_files):,} files to scan\n")

    # Scan files with metadata extraction
    rows = []
    hash_map = defaultdict(list)  # For dedup

    with ThreadPoolExecutor(max_workers=max_workers) as executor:
        futures = {}
        for fpath in all_files:
            future = executor.submit(scan_single_file, fpath, enable_metadata, enable_dedup)
            futures[future] = fpath

        for i, future in enumerate(as_completed(futures), 1):
            fpath = futures[future]
            try:
                result = future.result()
                if result:
                    # CSV enforcement check
                    if enforce_uids:
                        uid = result.get("uuid", "")
                        if uid and uid not in enforce_uids:
                            result["_skip"] = True
                    rows.append(result)

                    # Track hashes for dedup
                    if enable_dedup and result.get("sha256"):
                        hash_map[result["sha256"]].append(fpath)

            except Exception as e:
                logging.error(f"Error scanning {fpath}: {e}")

            if i % 100 == 0 or i == len(all_files):
                print_progress(i, len(all_files), "Scanning")

    # Dedup: mark duplicates
    if enable_dedup:
        dup_count = 0
        for h, paths in hash_map.items():
            if len(paths) > 1:
                # Keep first, mark rest as duplicate
                for p in paths[1:]:
                    for row in rows:
                        if row.get("path") == p:
                            row["_duplicate"] = True
                            row["_duplicate_of"] = paths[0]
                            dup_count += 1
                            break
        print(f"🔒 Found {dup_count} duplicate files (by SHA256)")

    # Filter out enforcement skips and duplicates
    final_rows = [r for r in rows if not r.get("_skip") and not r.get("_duplicate")]

    # Write CSV
    if not final_rows:
        print("⚠️  No files matched criteria")
        return

    fieldnames = [
        "Filename", "Extension", "Category", "File Size", "Duration",
        "Creation Date", "Original Path", "SHA256", "Is Duplicate",
        "Duplicate Of", "Lines", "Chars", "Width", "Height",
        "DPI", "Mode", "Bitrate", "Sample Rate",
    ]

    with open(output_csv, "w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        for row in final_rows:
            writer.writerow({
                "Filename": row.get("filename", ""),
                "Extension": row.get("ext", ""),
                "Category": row.get("category", ""),
                "File Size": row.get("size", ""),
                "Duration": row.get("duration", ""),
                "Creation Date": row.get("creation_date", ""),
                "Original Path": row.get("path", ""),
                "SHA256": row.get("sha256", ""),
                "Is Duplicate": row.get("_duplicate", False),
                "Duplicate Of": row.get("_duplicate_of", ""),
                "Lines": row.get("lines", ""),
                "Chars": row.get("chars", ""),
                "Width": row.get("width", ""),
                "Height": row.get("height", ""),
                "DPI": row.get("dpi", ""),
                "Mode": row.get("mode", ""),
                "Bitrate": row.get("bitrate", ""),
                "Sample Rate": row.get("sample_rate", ""),
            })

    print(f"\n✅ Wrote {len(final_rows):,} rows to {output_csv}")

    # Summary stats
    categories = Counter(r.get("category", "Unknown") for r in final_rows)
    print(f"\n📊 By Category:")
    for cat, count in categories.most_common(15):
        print(f"  {cat:>15s}: {count:>7,}")

    total_size = sum(r.get("size_bytes", 0) for r in final_rows)
    print(f"\n  Total size: {format_file_size(total_size)}")
    print(f"  Files scanned: {len(all_files):,}")
    print(f"  Final rows: {len(final_rows):,}")
    if enable_dedup:
        dup_total = sum(1 for r in rows if r.get("_duplicate"))
        print(f"  Duplicates removed: {dup_total:,}")
    if enforce_uids:
        skipped = sum(1 for r in rows if r.get("_skip"))
        print(f"  CSV-enforcement skipped: {skipped:,}")


def scan_single_file(fpath: str, enable_metadata: bool, enable_dedup: bool) -> Optional[Dict]:
    """Scan a single file and extract metadata."""
    try:
        stat = os.stat(fpath)
        fname = os.path.basename(fpath)
        ext = os.path.splitext(fname)[1].lower()
        category = FILE_TYPES.get(ext, "Other")

        row = {
            "filename": fname,
            "ext": ext,
            "category": category,
            "size": format_file_size(stat.st_size),
            "size_bytes": stat.st_size,
            "duration": "",
            "creation_date": get_creation_date(fpath),
            "path": fpath,
            "sha256": "",
        }

        if enable_metadata:
            # Audio
            if category == "Audio":
                meta = get_audio_metadata(fpath)
                if meta:
                    row["duration"] = format_duration(meta.get("duration_sec"))
                    row["bitrate"] = meta.get("bitrate", "")
                    row["sample_rate"] = meta.get("sample_rate", "")

            # Video
            elif category == "Video":
                meta = get_video_metadata(fpath)
                if meta:
                    row["duration"] = format_duration(meta.get("duration_sec"))

            # Image
            elif category == "Image":
                meta = get_image_metadata(fpath)
                if meta:
                    row["width"] = meta.get("width", "")
                    row["height"] = meta.get("height", "")
                    row["dpi"] = f"{meta.get('dpi_x','')}x{meta.get('dpi_y','')}" if meta.get('dpi_x') else ""
                    row["mode"] = meta.get("mode", "")

            # Code
            elif category in ("Code", "Script"):
                meta = get_code_metadata(fpath)
                if meta:
                    row["lines"] = meta.get("lines", "")
                    row["chars"] = meta.get("chars", "")

        if enable_dedup:
            row["sha256"] = sha256_file(fpath)

        return row
    except Exception as e:
        logging.error(f"Error scanning {fpath}: {e}")
        return None


# ─── Cleanup & Organize (from cleanup_and_organize.py) ───
def cleanup_backups(directories: List[str], dry_run: bool = True):
    """Remove backup files (.bak, .backup_*, ~ duplicates)."""
    print(f"\n🧹 Cleanup backups (dry_run={dry_run})...")
    patterns = [r'.*\.bak$', r'.*\.backup_\d+$', r'.*~$']
    removed = 0
    for directory in directories:
        for root, dirs, files in os.walk(directory):
            dirs[:] = [d for d in dirs if not should_skip(os.path.join(root, d))]
            for fname in files:
                fpath = os.path.join(root, fname)
                if any(re.match(p, fname) for p in patterns):
                    if dry_run:
                        print(f"  WOULD REMOVE: {fpath}")
                    else:
                        os.remove(fpath)
                    removed += 1
    print(f"  {'Would remove' if dry_run else 'Removed'} {removed} backup files")


# ─── CLI ───
def main():
    parser = argparse.ArgumentParser(description="Enhanced Universal File Scanner & Organizer")
    parser.add_argument("directories", nargs="+", help="Directories to scan")
    parser.add_argument("--output", "-o", default="all_scan.csv", help="Output CSV path")
    parser.add_argument("--types", nargs="*", help="File extensions to include (e.g. .mp3 .py .md)")
    parser.add_argument("--no-metadata", action="store_true", help="Skip metadata extraction")
    parser.add_argument("--dedup", action="store_true", help="Enable SHA256 dedup")
    parser.add_argument("--workers", type=int, default=4, help="Parallel workers")
    parser.add_argument("--cleanup", action="store_true", help="Run backup file cleanup")
    parser.add_argument("--csv-enforce", help="CSV file to enforce row limit (suno-937.csv)")
    parser.add_argument("--dry-run", action="store_true", help="Don't delete, just report")
    parser.add_argument("--no-excludes", action="store_true", help="Skip exclude patterns (scan everything)")
    args = parser.parse_args()

    include_types = set(args.types) if args.types else None
    excludes = None if args.no_excludes else None  # None = use default _EXCLUDES

    # For Media directory scans, exclude only core patterns, not Music/Pictures
    if excludes is None and not args.no_excludes:
        # Use base-only excludes (no Media exclusions) for targeted scans
        try:
            from exclude_patterns import BASE_EXCLUDED_PATTERNS
            excludes = BASE_EXCLUDED_PATTERNS
        except ImportError:
            pass

    # Run cleanup first
    if args.cleanup:
        cleanup_backups(args.directories, dry_run=args.dry_run)

    # Run scan
    scan_directories(
        directories=args.directories,
        output_csv=args.output,
        include_types=include_types,
        enable_metadata=not args.no_metadata,
        enable_dedup=args.dedup,
        max_workers=args.workers,
        csv_enforce_limit=None,
        csv_enforce_source=args.csv_enforce,
        excludes=excludes,
    )


if __name__ == "__main__":
    main()
