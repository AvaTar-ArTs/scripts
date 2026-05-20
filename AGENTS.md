# Repository Guidelines

## Project Structure & Module Organization
This repository is script-first. Most utilities live at the repo root as standalone shell scripts (`*.sh`) plus supporting docs (`*.md`) and a few Perl helpers (`*.pl`).

Naming is the main organization strategy:
- `setup_*`, `install_*`: environment/bootstrap scripts
- `cleanup_*`, `remove_*`: cleanup and maintenance
- `run_*`, `launch_*`, `start_*`: orchestration and entry points
- `test_*`: shell-based validation scripts

`psd-tools/` is a nested Python project with its own lifecycle:
- Code: `psd-tools/api/`, `psd-tools/psd/`, `psd-tools/composite/`, `psd-tools/compression/`
- Tests: `psd-tools/tests/`
- Docs: `psd-tools/docs/`

## Build, Test, and Development Commands
- `bash -n ./script_name.sh`: syntax-check a shell script.
- `shellcheck ./script_name.sh`: lint a shell script.
- `chmod +x ./script_name.sh`: mark new scripts executable.
- `cd psd-tools && pip install -e .[dev]`: install Python dev dependencies.
- `cd psd-tools && pytest`: run Python tests (`--cov=psd_tools` is enabled in config).
- `make -C psd-tools/docs html`: build docs for `psd-tools`.

## Coding Style & Naming Conventions
- Prefer `#!/usr/bin/env bash` for new shell scripts.
- Use `set -euo pipefail` in scripts that modify files or system state.
- Use 4-space indentation, quote variable expansions (`"$var"`), and `$(...)` command substitution.
- Keep filenames lowercase with underscores, action-oriented (example: `cleanup_temp_files.sh`).
- For Python under `psd-tools/`, follow PEP 8 and keep modules focused by domain.

## Testing Guidelines
- For shell changes, run both `bash -n` and `shellcheck` before opening a PR.
- Add focused shell tests as `test_<feature>.sh` when behavior is complex.
- For `psd-tools` changes, add `test_*.py` under the matching `psd-tools/tests/...` area and run `cd psd-tools && pytest`.

## Commit & Pull Request Guidelines
`/Users/steven/scripts` root has no Git metadata; the active history is in `psd-tools/.git`. Recent commit subjects there are short, imperative, and specific (examples: `Fix clip layer handling`, `Add sibling traversal methods`, `Increment version to v1.10.13`).

Use that style for new commits:
- one intent per commit
- imperative subject line
- include scope in body when touching both root scripts and `psd-tools`

PRs should include: purpose, files changed, risk level (especially for cleanup/move scripts), and exact verification commands run.

## Security & Configuration Tips
- Secrets must come from environment variables; never hardcode API keys.
- The CLI auto-loads `.env` via `dotenv/config`.
- For non-default model backends, use `--provider <name>` and ensure the matching provider API key is set.
