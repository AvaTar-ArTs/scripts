# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

The `/Users/steven/scripts` repository is a **mixed codebase** containing:

1. **Root-level shell scripts** (`*.sh`, `*.pl`) - Automation, system maintenance, and orchestration utilities
2. **Agent Forge** (`agent_forge/`) - Python-based agent orchestration system for AvatarArts and GPTJunkie domains
3. **psd-tools** (`psd-tools/`) - Nested Python project with its own git history for PSD file format manipulation
4. **Documentation** - Multiple markdown guides describing various subsystems

The repository uses **naming as primary organization** for shell scripts. No central build system or monolithic package structure exists.

## Directory Structure & Patterns

### Root Level Scripts
- `setup_*`, `install_*`: Environment initialization and bootstrap
- `cleanup_*`, `remove_*`: Maintenance and cleanup operations
- `run_*`, `launch_*`, `start_*`: Orchestration and entry points
- `test_*`: Validation and shell-based testing
- `analyze_*`: Analysis and scanning utilities
- `advanced-*.sh`: Complex multi-feature utilities (often maintenance-focused)

### agent_forge/
Python-based agent orchestration system:
- `config/`: Domain, agent, and subagent configurations
- `apps/`: Runnable CLI applications (keyword_radar, mission_planner, provenance_audit, xeo_audit)
- `scripts/`: Launch wrappers and orchestration
- `skills/`: Reusable instruction bundles (SKILL.md format)
- `mcp/`: MCP-style server stubs
- `reports/`: Generated artifacts and audit results
- `subagents/`: Subagent definitions and coordination

### psd-tools/
Isolated Python project with git metadata:
- `psd-tools/api/`: High-level API for PSD manipulation
- `psd-tools/psd/`: Low-level binary format handling
- `psd-tools/composite/`: Compositing operations
- `psd-tools/compression/`: Compression algorithms
- `psd-tools/tests/`: Test suite
- `psd-tools/docs/`: Sphinx documentation

## Build, Test, and Development Commands

### Shell Scripts
```bash
# Syntax checking
bash -n ./script_name.sh

# Linting
shellcheck ./script_name.sh

# Make executable
chmod +x ./script_name.sh

# Run direct scripts (from repository root)
bash scripts/analysis/analysis_launcher.sh
bash agent_forge/scripts/bootstrap_agent_forge.sh
```

### Agent Forge Applications
```bash
# Run keyword radar analysis
python3 agent_forge/apps/keyword_radar.py --domain both --top 20 --format markdown --out agent_forge/reports/keyword_radar.md

# Run mission planner
python3 agent_forge/apps/mission_planner.py --domain gptjunkie --weeks 6 --out agent_forge/reports/plan.md

# Run provenance audit
python3 agent_forge/apps/provenance_audit.py --input /path/to/video.mp4 --json agent_forge/reports/provenance.json --markdown agent_forge/reports/provenance.md

# Run complete XEO suite
bash agent_forge/scripts/run_xeo_suite.sh both
# Or with options:
python3 agent_forge/apps/xeo_audit.py --domain both --live --with-gsc --out-dir agent_forge/reports

# List available domains: both | avatararts | gptjunkie
```

### psd-tools Python Project
```bash
# Install development dependencies
cd psd-tools
pip install -e .[dev]

# Run test suite (coverage enabled in config)
cd psd-tools
pytest

# Build documentation
make -C psd-tools/docs html
```

## Coding Style & Conventions

### Shell Scripts
- Use `#!/usr/bin/env bash` for new scripts
- Use `set -euo pipefail` in scripts that modify files or system state
- 4-space indentation
- Quote variable expansions: `"$var"` not `$var`
- Use command substitution: `$(...)` not backticks
- Filenames: lowercase with underscores, action-oriented (e.g., `cleanup_temp_files.sh`)

### Python (agent_forge)
- Follow PEP 8
- Modules should have focused domain responsibility
- Use argparse for CLI tools
- Common patterns in agent_forge:
  - Config-driven from `config/` directory
  - Domain filtering (avatararts, gptjunkie, both)
  - Report generation to `reports/` with markdown output
  - Optional Google Search Console integration (environment-aware fallback)

### Python (psd-tools)
- Follow PEP 8
- Keep domain-focused modules in matching test locations
- Each module handles specific binary format aspect
- Tests are co-located: `tests/test_<feature>.py`

## Key Integration Points

### Environment Variables
- All API credentials load from `~/.env.d/` (Steven's personal convention)
- Google Search Console integration via:
  - `GOOGLE_APPLICATION_CREDENTIALS`: Path to service account JSON
  - `GSC_SITE_AVATARARTS`: Site URL for AvatarArts
  - `GSC_SITE_GPTJUNKIE`: Site URL for GPTJunkie
- XEO audit supports local snapshot fallback:
  - `XEO_LOCAL_SNAPSHOT_AVATARARTS`: Path to local website export
  - `XEO_LOCAL_SNAPSHOT_GPTJUNKIE`: Path to local website export
  - `XEO_LOCAL_SNAPSHOT_ROOT`: Root directory containing `avatararts/` and `gptjunkie/` subdirs

### Domain Model (agent_forge)
- **AvatarArts**: Creative and business automation platform
- **GPTJunkie**: AI research and content platform
- Applications support `--domain avatararts | gptjunkie | both`
- Reports are domain-aware and can operate in combined mode

## Git & Version Control

### psd-tools/.git
- psd-tools has its own git history (active development)
- Recent commits are short, imperative, specific (e.g., "Fix clip layer handling", "Add sibling traversal methods")
- PR style: Include purpose, files changed, risk level, exact verification commands

### Root Level (no .git)
- Root scripts are not version-controlled in this repository
- Scripts are utility-first and may be ephemeral or frequently modified

## Common Workflows

### Running Agent Forge Analysis
1. Set environment variables if using Google Search Console
2. Run desired app from repository root:
   ```bash
   python3 agent_forge/apps/<app_name>.py [options]
   ```
3. Check `agent_forge/reports/` for output artifacts
4. Fallback modes work without GSC credentials

### Modifying Shell Scripts
1. Make changes
2. Run: `bash -n ./script_name.sh` (syntax check)
3. Run: `shellcheck ./script_name.sh` (lint)
4. Test: Run the script with appropriate test inputs

### Modifying psd-tools
1. Make code changes in appropriate module
2. Add corresponding test in `tests/test_<feature>.py`
3. Run: `cd psd-tools && pytest`
4. Check coverage with pytest config

### Adding New Agent Forge Applications
1. Create new file in `agent_forge/apps/`
2. Use existing apps as templates (e.g., `xeo_audit.py`)
3. Support `--domain` flag with validation
4. Write output to `agent_forge/reports/` with markdown support
5. Update README with usage example
6. Consider Google Search Console fallback if applicable

## Architecture Notes

### Agent Forge Design
- **Modular**: Each app is self-contained with helper libraries (e.g., `lib_xeo.py`, `lib_gsc.py`)
- **Config-driven**: Domain and agent configs in `config/` directory
- **Report-focused**: Output artifacts are primary deliverable
- **Graceful degradation**: Optional features (GSC) don't break core functionality
- **Skills framework**: Reusable instruction bundles for MCP compatibility

### psd-tools Design
- **Format-focused**: Handles Adobe PSD binary format complexity
- **API layers**: High-level API separates from low-level parsing
- **Extensible**: Composite and compression modules are plugin points
- **Well-tested**: Test suite validates behavior against real PSD files

## Special Considerations

### Provenance & Compliance
The agent_forge includes provenance tracking features, explicitly designed for **compliant disclosure workflows**. It does not support watermark removal or destructive modifications.

### Search Indexing (XEO)
XEO audit provides SEO/SEM optimization planning. It defaults to crawl-based scoring but enhances with Google Search Console data when available. Local snapshot support enables offline analysis.

### Multi-Domain Operations
When using `--domain both`, operations process both AvatarArts and GPTJunkie contexts, generating separate and combined reports.

## Testing Guidelines

### Shell Scripts
- Syntax check before any changes: `bash -n ./script.sh`
- Lint before committing: `shellcheck ./script.sh`
- Test with realistic data/inputs

### Agent Forge
- Run with sample domains first: `--domain avatararts` before `--domain both`
- Check `agent_forge/reports/` output structure
- Verify graceful fallback if optional dependencies missing (e.g., no Google API)

### psd-tools
- Required: `cd psd-tools && pytest`
- Optional: `pytest --cov=psd_tools` for coverage analysis
- Tests must cover both valid and edge-case PSD structures

## Important Notes

- No monolithic build process - scripts are run individually or through orchestration wrappers
- Agent Forge is domain-aware and production-focused
- psd-tools is a feature-complete library with its own versioning cycle
- Configuration and environment variables are critical for agent_forge functionality
- This is a mixed-tooling ecosystem - expect shell, Python, and bash patterns to coexist
