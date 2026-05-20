#!/usr/bin/env python3
"""Generate a static HTML site for Noi AI service data.

Writes a new versioned build under `site/versions/<NNNN>/` each run.
Updates `site/latest` symlink.
"""

from __future__ import annotations
import os
import re
import sys
import subprocess
from pathlib import Path
from datetime import datetime

# Configuration
NOI_PARTITIONS_DIR = Path.home() / "Library/Application Support/Noi/Partitions/noi_main/IndexedDB"
NOI_MAIN_DB_DIR = Path.home() / "Library/Application Support/Noi/noi_user/database"
SITE_ROOT = Path("/Users/steven/MySites/noi-site")
VERSIONS_ROOT = SITE_ROOT / "versions"

# Services to track
SERVICES = [
    ("https_chatgpt.com_0.indexeddb.leveldb", "ChatGPT"),
    ("https_claude.ai_0.indexeddb.leveldb", "Claude"),
    ("https_grok.com_0.indexeddb.leveldb", "Grok"),
    ("https_z.ai_0.indexeddb.leveldb", "Z.ai"),
    ("https_www.perplexity.ai_0.indexeddb.leveldb", "Perplexity"),
    ("https_chat.deepseek.com_0.indexeddb.leveldb", "DeepSeek"),
    ("https_chat.qwen.ai_0.indexeddb.leveldb", "Qwen"),
]

def next_build_id() -> str:
    VERSIONS_ROOT.mkdir(parents=True, exist_ok=True)
    max_n = 0
    for p in VERSIONS_ROOT.iterdir():
        if p.is_dir() and re.fullmatch(r"\d{4}", p.name):
            max_n = max(max_n, int(p.name))
    return f"{max_n + 1:04d}"

def get_service_data(dir_name: str) -> dict:
    path = NOI_PARTITIONS_DIR / dir_name
    if not path.exists():
        return None
    
    size = subprocess.check_output(["du", "-sh", str(path)]).decode().split()[0]
    
    # Get last modified time of directory
    stat_info = os.stat(path)
    last_mod = datetime.fromtimestamp(stat_info.st_mtime).strftime("%Y-%m-%d %H:%M")
    
    return {
        "size": size,
        "last_mod": last_mod
    }

def main():
    build_id = next_build_id()
    BUILD_DIR = VERSIONS_ROOT / build_id
    BUILD_DIR.mkdir(parents=True, exist_ok=True)
    
    # Generate CSV Data
    csv_content = "Service,Size,LastModified\n"
    
    # Generate HTML Cards
    cards_html = ""
    
    for dir_name, display_name in SERVICES:
        data = get_service_data(dir_name)
        if data:
            csv_content += f"{display_name},{data['size']},{data['last_mod']}\n"
            cards_html += f'''
            <a href="#" class="repo-card ai">
                <div class="card-name">{display_name}</div>
                <div class="card-desc">Size: {data['size']}<br>Last Modified: {data['last_mod']}</div>
            </a>'''
            
    # Write CSV
    (BUILD_DIR / "noi_data_report.csv").write_text(csv_content)
    
    # Write HTML
    html_content = f'''<!DOCTYPE html>
<html lang="en" class="gptj">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Noi Data Dashboard - Build {build_id}</title>
    <link rel="stylesheet" href="styles.css">
</head>
<body class="home">
    <div class="hero">
        <h1><span class="brand-line">Noi</span><span class="junkie">Data Dashboard</span></h1>
        <p class="hero-sub">Build ID: {build_id} | Last updated: {datetime.now().strftime("%Y-%m-%d %H:%M")}</p>
    </div>
    <div class="theme-section">
        <div class="repo-grid">{cards_html}</div>
    </div>
</body>
</html>'''
    (BUILD_DIR / "index.html").write_text(html_content)
    
    # Copy CSS
    if (SITE_ROOT / "styles.css").exists():
        import shutil
        shutil.copy(SITE_ROOT / "styles.css", BUILD_DIR / "styles.css")
        
    print(f"Generated build {build_id} in {BUILD_DIR}")

if __name__ == "__main__":
    main()
