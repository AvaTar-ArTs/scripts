# Full Scripts Inventory

This is a complete inventory of `/Users/steven/scripts/`, categorized by inferred function and enriched with metadata where available.

## Folder Structure
```text
/Users/steven/scripts/
├───agent_forge/
├───bundles/
├───clean/
├───docs/
├───Docker/
├───iterm2_full_trees/
└───x-cmd/
```

## Inventory Registry

| Filename | Category | Maturity | Description |
| :--- | :--- | :--- | :--- |
| `advanced-system-maintenance-v5.sh` | System | beta | Master System Maintenance tool. |
| `ai-unified-menu.sh` | AI | beta | Unified CLI menu for AI tools. |
| `ai-watchdog.sh` | AI | beta | Monitor for AI assistant processes. |
| `ai-cli-diagnostics.sh` | AI | alpha | Diagnostic tool for AI CLI config. |
| `advanced-png-optimize.sh` | Media | beta | PNG image optimizer. |
| `compress-videos.sh` | Media | beta | Batch video compression utility. |
| `content-aware-rename.sh` | File | beta | Intelligent, content-based renaming. |
| `analyze_python_scripts.py` | Metadata | alpha | Audit tool for Python quality/structure. |
| `consolidate-into-masterxeo.sh` | Skill | beta | Master consolidator utility. |
| `deploy-to-github.sh` | Git | alpha | Automated GitHub push workflow. |
| `aggressive_git_cleanup.sh` | Git | alpha | Repository cleanup tool. |
| ... | ... | ... | ... |

*(Note: This inventory is truncated for brevity. A full list can be generated upon request based on the metadata CSV.)*

---

## Consolidation Proposal
I recommend the following actions to clean up the `~/scripts/` directory. **No actions will be taken without your explicit approval.**

### 1. Proposed Redundant Scripts to Deprecate
The following scripts appear to be legacy, redundant, or superseded by `advanced-system-maintenance-v5.sh` and other master scripts:

- [ ] `cleanup_python_conservative.sh` (Superseded by v5)
- [ ] `consolidate_remaining_gumroad.sh` (Superseded by master consolidators)
- [ ] `cleanup-macos-library-caches.sh` (Superseded by `advanced-system-maintenance-v5.sh`)
- [ ] `run-...-shortcut.sh` (These can be replaced by `ai-unified-menu.sh` functionality)

### 2. Next Steps
1.  Review this proposal.
2.  If approved, I will create `~/scripts/deprecated/`.
3.  I will then move the selected files into `~/scripts/deprecated/` for archiving.
4.  I will verify that `advanced-system-maintenance-v5.sh` correctly covers the functionality of the deprecated scripts.
