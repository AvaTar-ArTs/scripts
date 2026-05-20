#!/usr/bin/env python3
"""
Build manifest (path, type, size, ext) and totals from a fulltree path list.
Called by iterm2_tree_summary.sh to avoid 40k+ stat subshells; much faster.
Usage: iterm2_tree_summary_helper.py <root_dir> <fulltree.txt> <manifest.tsv> <totals.tmp> <ext_sorted.tmp>
"""
import os
import sys
from pathlib import Path

def main():
    root = Path(sys.argv[1]).resolve()
    fulltree_path = Path(sys.argv[2])
    manifest_path = Path(sys.argv[3])
    totals_path = Path(sys.argv[4])
    ext_sorted_path = Path(sys.argv[5])

    total_dirs = 0
    total_files = 0
    total_bytes = 0
    ext_count = {}

    with fulltree_path.open() as f, manifest_path.open("w") as out:
        out.write("path\ttype\tsize_bytes\text\n")
        for line in f:
            p = line.rstrip("\n")
            if not p:
                continue
            abs_p = root / p
            if abs_p.is_dir():
                out.write(f"{p}\tdir\t0\t\n")
                total_dirs += 1
            else:
                size = 0
                try:
                    if abs_p.is_file():
                        size = abs_p.stat().st_size
                except OSError:
                    pass
                ext = Path(p).suffix
                if ext and ext.startswith("."):
                    ext = ext[1:]
                out.write(f"{p}\tfile\t{size}\t{ext}\n")
                total_files += 1
                total_bytes += size
                if ext:
                    ext_count[ext] = ext_count.get(ext, 0) + 1

    totals_path.write_text(f"{total_dirs} {total_files} {total_bytes}\n")

    with ext_sorted_path.open("w") as out:
        for ext, cnt in sorted(ext_count.items(), key=lambda x: -x[1]):
            out.write(f"{cnt} {ext}\n")

if __name__ == "__main__":
    main()
