# Home directory audit — what we cover vs what lives elsewhere

Quick reference so nothing is "missed": **iterm2 full-tree and summaries cover only `~/iterm2`**. These are the other notable places under `~/` and how they relate.

---

## 1. What we already cover (iterm2 only)

- **Tree + summary:** All listed targets under **`~/iterm2`** are in `iterm2_full_tree.sh` and `iterm2_tree_summary.sh`. Roots: `.claude` `.cursor` `.gemini` `.git` `.grok` `.qodo` `.qwen` `agent_ops` `Ai-Merge` `Ai-Merge-GitHub` `claude-ecosystem` `Codex` `cursor-ecosystem` `docs` `gemini` `orchestrator` `scripts` `superpowers-codex-product`. Date-named dirs (e.g. `.hardening-backups-*`) are not included; add to the script if needed.
- **Docs:** `~/iterm2/docs/DEEP_DIVE_ITERM2_DIRS.md` describes each iterm2 target; `~/scripts/SCRIPTS_EXPLORATION.md` describes `~/scripts`.

So: **`~/iterm2`** and **`~/scripts`** (as a sibling) are documented and, for iterm2, fully tree’d and summarized.

---

## 2. Notable ~/ locations not under iterm2

| Path | Purpose | Relation to current tooling |
|------|---------|-----------------------------|
| **~/.agent_events/** | `hooks_events.jsonl`, `tool_use.jsonl` — agent/IDE telemetry | Tied to agent_ops / Cursor; not under iterm2. Optional: link from agent_ops docs. |
| **~/.agent_ops/** | (if present) Events/handoff logs | iterm2 has `agent_ops/` (code); user-level events may live here. scripts_context.md references `~/.agent_ops/events.jsonl`. |
| **~/.harbor/** | AI/tooling ecosystem: agent, boost, aider, open-webui, litellm, MCP, etc.; `.scripts/`, many start_*.sh | **Not** in iterm2 tree. Major “what’s in there” surface; candidate for its own tree/summary or a one-pager. |
| **~/.grok/** | Sessions (`.jsonl`), `update.sh` | iterm2 has `iterm2/.grok` (stub); **main Grok state** is here in ~. |
| **~/.qwen/** | `installation_id`, `projects/` (e.g. -Users-steven-iterm2/chats) | iterm2 has `iterm2/.qwen` (319 entries); **project/chats** may be here or linked. |
| **~/.cursor/** | User-level Cursor config; **`~/.cursor/agents/`** = subagents (e.g. tree-explorer) | iterm2 has `iterm2/.cursor` (8 entries, likely stub). **User agents** live here. |
| **~/scripts/** | Main script repo: root *.sh, agent_forge, psd-tools, tree/summary scripts | **Bridge:** iterm2/scripts → run_scripts.sh → ~/scripts. Documented in SCRIPTS_EXPLORATION.md and scripts_context.md. |
| **~/bin/** | `media-processor`, `nlma`, `nlmcho`, `xsh` — likely in PATH | Not in iterm2; useful to know for “where do runnables live?” |
| **~/.zshrc.d/** | Shell config snippets (ai, fzf, integrations, python-extra, etc.) | Referenced by cleanup/docs; not tree’d. |
| **~/.cfg/** | Config / dotfile management (37 files) | Out of scope for tree; note for “config lives here.” |
| **~/.env.d/** | API credentials and env (see CLAUDE.md) | Never in tree (secrets); already documented. |
| **~/Development/**, **~/Master CodeSnip dev/**, **~/MasterxEo/**, **~/mcPHooker/** | Project/code dirs | Not under iterm2; optional “other codebases” list. |
| **~/aider-env/** | Aider virtualenv (bin/, pyvenv.cfg) | Tooling env; cleanup scripts may reference. |

---

## 3. Cross-links (so we didn’t miss the connection)

- **agent_events ↔ agent_ops:** `~/.agent_events/` holds event streams; iterm2 `agent_ops/` is the code (handoff, tool_tracker, etc.). Docs can say “telemetry under ~/.agent_events (and optionally ~/.agent_ops).”
- **Grok:** Main content **~/.grok**; iterm2 **.grok** = stub. DEEP_DIVE already notes “Grok config may live under ~/.grok.”
- **Qwen:** iterm2 **.qwen** has 319 entries; **~/.qwen** has projects/chats. Either is “canonical” depending on usage; both noted.
- **Cursor agents:** **~/.cursor/agents/** = user subagents (e.g. tree-explorer); iterm2 **.cursor** = small/stub.
- **Scripts:** iterm2 **scripts** (4 files) = bridge; **~/scripts** = full repo. scripts_context.md and SCRIPTS_EXPLORATION.md cover this.

---

## 4. Optional next steps (if you want to “cover” more)

1. **Add optional tree roots**  
   Extend `iterm2_full_tree.sh` (or a separate script) with optional roots, e.g.:
   - `~/.harbor` → fulltree + summary (large; good candidate for Python helper).
   - `~/scripts` → fulltree + summary (so “what’s in scripts” has a summary like iterm2 targets).

2. **One-pager for ~/.harbor**  
   Even without a full tree: list top-level dirs and one-line purpose (e.g. in this file or in `~/iterm2/docs`) so “what’s in harbor” is scannable.

3. **DEEP_DIVE “See also”**  
   Add a short “See also: ~/” section that points to this audit and to key paths (e.g. ~/.harbor, ~/scripts, ~/.cursor/agents, ~/.agent_events).

4. **INDEX or README**  
   In `iterm2_full_trees/INDEX.md` or scripts README, add one line: “For the rest of ~/, see `~/scripts/HOME_DIR_AUDIT.md`.”

### Harbor one-pager + optional tree (done)

- **One-pager:** `~/scripts/HARBOR_ONE_PAGER.md` — top-level dirs and one-line purpose.
- **Full tree + summary:** From `~/scripts` run (one command per line):
  - `bash home_tree.sh`
  - `bash iterm2_tree_summary.sh harbor`
  - `cat iterm2_full_trees/summary_harbor.md` to view the summary (or open the file in an editor).

---

## 6. Summary

- **Covered:** `~/iterm2` (full tree + summaries + INDEX + DEEP_DIVE); `~/scripts` (exploration doc + bridge).
- **Not missed:** Other important ~/ dirs are listed above with purpose and relation; cross-links and optional extensions are noted.
- **Harbor:** ~/.harbor now has a one-pager (`HARBOR_ONE_PAGER.md`) and optional full tree + summary via `home_tree.sh` and `iterm2_tree_summary.sh harbor`.
