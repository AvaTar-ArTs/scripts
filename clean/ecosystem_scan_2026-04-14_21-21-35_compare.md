# Ecosystem scan vs metadata (2026-04-14_21-21-35)

## Method
- **Document-class files**: same extensions as `~/clean/docs.py` dry-run, with ecosystem exclusions (see script header).
- **`du -sk`**: total disk use per directory (includes skipped trees like `.git`).
- **Master index**: keys from `filesystem_master_index_20260208_064111.txt` where a `📁 ... (/Users/steven/...)` block exists. Index **file counts are total files**, not document-class only — use for spot-check, not equality.

## 2T-Xx report (excerpt)
```

```

## Per-target

| Path | du | doc files | doc MiB | master index files | master size |
|------|-----|-----------|---------|-------------------|-------------|
| `ai_merge_auto` | 76K | 2 | 0.0 |  |  |
| `AutoTagger` | 207.9M | 356 | 62.2 |  |  |
| `claudemarketplaces.com` | 3.1M | 21 | 0.1 |  |  |
| `clean` | 74.8M | 508 | 73.8 |  |  |
| `Development` | 206.2M | 294 | 3.1 |  |  |
| `Documents` | 3.2G | 6507 | 2853.0 |  |  |
| `Downloads` | 20.5G | 27160 | 3718.8 |  |  |
| `Fixes` | 40K | 4 | 0.0 |  |  |
| `git-ai` | 0K | 0 | 0 |  |  |
| `github` | 2.5G | 3319 | 189.0 |  |  |
| `grok` | 32.1M | 79 | 29.8 |  |  |
| `iterm2` | 4.1G | 2671 | 468.7 |  |  |
| `iterm2_prompt-engineering-exploration` | 20K | 1 | 0.0 |  |  |
| `iterm2-fix` | 44.4M | 581 | 7.9 |  |  |
| `Miniforge_Mamba_Analysis` | 44K | 3 | 0.0 |  |  |
| `my-simple` | 56K | 8 | 0.0 |  |  |
| `Pictures` | 19.5G | 8138 | 413.7 |  |  |
| `pythons` | 990.9M | 4970 | 152.4 |  |  |
| `scripts` | 23.1M | 478 | 16.1 |  |  |
| `userscripts` | 42.2M | 26 | 8.0 |  |  |
| `zombot-simple-gallery` | 140K | 15 | 0.1 |  |  |
| `Zotero` | 18.1M | 739 | 10.8 |  |  |

Full CSV: `/Users/steven/clean/ecosystem_scan_2026-04-14_21-21-35.csv`