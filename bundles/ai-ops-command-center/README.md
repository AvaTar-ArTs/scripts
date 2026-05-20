# AI Ops Command Center — Multi-Model Management

> **Manage 10+ AI models, MCP servers, and API keys from one CLI.**
> *The DevOps toolkit for the multi-model era.*

**Version:** 1.0.0
**Status:** ✅ COMPLETE
**Price:** $79 (Gumroad)
**Last Updated:** 2026-04-12

---

## 🎯 Why This Product Has ZERO Competition

No one else has built a **unified CLI ops center** for managing multiple AI providers, local models, and MCP servers simultaneously. Every competing tool focuses on a *single* provider (OpenAI CLI, Anthropic SDK) or a *single* paradigm (chat UI, playground).

**AI Ops Command Center is the only product that:**

- Manages **cloud APIs** (OpenAI, Anthropic, Groq, Grok/xAI) AND **local models** (Ollama) from one menu
- Provides **full MCP server lifecycle management** — start, stop, monitor, restart
- Includes **resource monitoring** (CPU, memory, runtime limits) to prevent runaway AI processes
- Ships with **diagnostics** that auto-redact secrets for safe troubleshooting
- Requires **zero dependencies** beyond bash — no Node.js, no Python venv needed to run the core tools

> 💡 *This is a green-ocean product. If you manage more than one AI tool, you need this.*

---

## 📦 What's Inside (9 Production Scripts)

| # | Script | Lines | Role |
|---|--------|-------|------|
| 1 | `setup-ai-apis.sh` | 698 | **Flagship** — Full API key setup, validation & test suite for 6+ providers |
| 2 | `ai-cli-diagnostics.sh` | 121 | Environment layout detection, config audit, network reachability |
| 3 | `ai-resource-manager.sh` | 140 | CPU/memory limits per tool, concurrent tool management, auto-cleanup |
| 4 | `ai-watchdog.sh` | 123 | Continuous monitoring, high-CPU detection, runaway process termination |
| 5 | `ai_unified_menu.sh` | 413 | Interactive TUI menu — access all tools from one interface |
| 6 | `grok_integration.sh` + `grok_menu.sh` | 454 | Grok/xAI setup, interactive prompts, code review, git analysis |
| 7 | `ollama_install.sh` + `ollama_menu.sh` | 226 | Local model pull, generate, list, and manage Ollama models |
| 8 | `mcp-lifecycle-manager.sh` | 152 | MCP server start/stop/restart, health checks, log tailing |
| 9 | `mcp-process-manager.sh` | 149 | MCP process monitoring, resource tracking, graceful shutdown |

**Total:** 2,476 lines of production-tested bash automation.

---

## 🚀 Quick Start

### Installation

```bash
# 1. Download and extract the bundle
unzip ai-ops-command-center.zip
cd ai-ops-command-center

# 2. Make all scripts executable
chmod +x *.sh

# 3. Run the setup wizard (guides you through API keys)
./setup-ai-apis.sh

# 4. Launch the unified menu
./ai_unified_menu.sh
```

### One-Line Install (for existing users)

```bash
curl -sL https://example.com/ai-ops-setup.sh | bash
```

---

## 🎮 Usage Examples

### Run the Unified Menu

```bash
./ai_unified_menu.sh
```

Opens an interactive terminal UI with access to Grok, Ollama, Python AI APIs, quick actions, and environment diagnostics.

```
===============================================
  🤖 Unified AI Tools Menu — 14:32:07
===============================================
Choose your AI tool:

  1) Grok CLI        - Cloud-based AI assistant
  2) Ollama          - Local AI models
  3) Python AI APIs  - OpenAI, Claude, etc.
  4) Environment Check - Check API keys & tools
  5) Quick Actions   - Fast access to common tasks

  q) Quit
```

### Run Full Diagnostics

```bash
./ai-cli-diagnostics.sh
```

Captures your entire environment: shell, PATH, Python layout, virtual environments, Aider config, LiteLLM status, Grok CLI status, API reachability — all **auto-redacted** for safe sharing.

### Start the Watchdog

```bash
# Continuous monitoring
./ai-watchdog.sh run

# Single check cycle
./ai-watchdog.sh once

# Show current status
./ai-watchdog.sh status
```

### Manage Resources

```bash
# Launch a tool with resource limits (1024 MB cap)
./ai-resource-manager.sh launch "python my_agent.py" "MyAgent" 1024

# Check active tools
./ai-resource-manager.sh status

# Cleanup all running tools
./ai-resource-manager.sh cleanup
```

### Manage MCP Servers

```bash
# Start an MCP server
./mcp-lifecycle-manager.sh start my-mcp-server

# Check health
./mcp-lifecycle-manager.sh health my-mcp-server

# View logs
./mcp-lifecycle-manager.sh logs my-mcp-server

# Stop gracefully
./mcp-lifecycle-manager.sh stop my-mcp-server
```

---

## 🌐 Supported AI Platforms

| Platform | Type | Setup Script | Status Check |
|----------|------|-------------|--------------|
| **OpenAI** | Cloud API | `setup-ai-apis.sh` | `ai_unified_menu.sh` → Option 3 |
| **Anthropic (Claude)** | Cloud API | `setup-ai-apis.sh` | `ai_unified_menu.sh` → Option 3 |
| **Groq** | Cloud API | `setup-ai-apis.sh` | `ai-cli-diagnostics.sh` |
| **Grok / xAI** | Cloud API | `grok_integration.sh` | `ai_unified_menu.sh` → Option 1 |
| **Ollama** | Local Models | `ollama_install.sh` | `ai_unified_menu.sh` → Option 2 |
| **MCP Servers** | Local/Remote | `mcp-lifecycle-manager.sh` | `mcp-process-manager.sh` |

---

## 📊 Competitor Comparison

| Feature | **AI Ops Command Center** | OpenAI CLI | Anthropic SDK | LangChain CLI | Continue.dev |
|---------|:---:|:---:|:---:|:---:|:---:|
| Multi-provider support | ✅ 6+ | ❌ 1 | ❌ 1 | ⚠️ Partial | ❌ 1 |
| Local model management | ✅ Ollama | ❌ | ❌ | ❌ | ❌ |
| MCP server lifecycle | ✅ Full | ❌ | ❌ | ❌ | ❌ |
| Resource monitoring | ✅ CPU/Mem | ❌ | ❌ | ❌ | ❌ |
| Runaway process protection | ✅ Watchdog | ❌ | ❌ | ❌ | ❌ |
| Environment diagnostics | ✅ Full audit | ❌ | ❌ | ❌ | ❌ |
| Zero dependencies | ✅ Bash only | ❌ Node | ❌ Python | ❌ Python | ❌ Node |
| Interactive TUI menu | ✅ Unified | ⚠️ Basic | ❌ | ❌ | ⚠️ IDE only |
| Price | **$79** | Free | Free | Free | Free |
| **Unique value** | **Ops center** | Chat only | Chat only | Framework | IDE plugin |

> **Bottom line:** Every free tool solves *one* problem. AI Ops Command Center solves *all of them* from one terminal.

---

## 📸 Screenshots

### Unified Menu Interface

```
┌─────────────────────────────────────────────────┐
│  🤖  AI Ops Command Center v1.0.0              │
│  Multi-Model Management Suite                  │
├─────────────────────────────────────────────────┤
│                                                 │
│  [1] 🔧  Setup & Configure APIs                 │
│  [2] 📊  Run Diagnostics                        │
│  [3] 🛡️   Resource Manager                      │
│  [4] 🐕  Start Watchdog                         │
│  [5] 🎮  Unified Menu                           │
│  [6] 🤖  Grok CLI Tools                         │
│  [7] 🦙  Ollama Local Models                    │
│  [8] 🔌  MCP Server Lifecycle                   │
│  [9] 📋  MCP Process Manager                    │
│                                                 │
│  [q] Quit    [h] Help                           │
│                                                 │
└─────────────────────────────────────────────────┘
```

### Diagnostics Output (Redacted)

```
=== Core System Layout ===
Shell: /bin/zsh
Python: /opt/homebrew/bin/python3 (3.12.4)
Virtual Env: /Users/steven/ai-env (active)

=== API Reachability ===
OpenAI API: ✅ HTTP 200 (42ms)
Anthropic API: ✅ HTTP 200 (67ms)
xAI API: ✅ HTTP 200 (89ms)

=== Environment Variables ===
OPENAI_API_KEY: ✅ Set (sk-****...7f3a)
ANTHROPIC_API_KEY: ✅ Set (sk-ant-****...9b2c)
GROK_API_KEY: ✅ Set (xai-****...4d1e)
```

### Watchdog Alert

```
[2026-04-12 14:32:07] HIGH CPU PROCESS DETECTED: PID 8421 (94.2% CPU)
[2026-04-12 14:32:07] Process has been running for 3.2 hours
[2026-04-12 14:32:12] Terminating high CPU, long-running process: PID 8421
[2026-04-12 14:32:17] ✅ Process terminated successfully
```

---

## 📋 Requirements

- **macOS** 12+ (Monterey or later) — Intel or Apple Silicon
- **bash** 5.0+ (ships with macOS via Homebrew)
- **curl** (for API reachability checks)
- **Optional:** `jq`, `bc`, `psutil` (Python) for enhanced features

No Node.js, no Python virtual environments required for the core scripts.

---

## 🗂️ Directory Structure

```
ai-ops-command-center/
├── README.md                      # This file
├── INSTALL.md                     # Detailed installation guide
├── CHANGELOG.md                   # Version history
├── LICENSE                        # MIT License
├── bundle-manifest.json           # Machine-readable bundle metadata
│
├── setup-ai-apis.sh               # Flagship setup & validation
├── ai-cli-diagnostics.sh          # Environment diagnostics
├── ai-resource-manager.sh         # CPU/Memory resource limits
├── ai-watchdog.sh                 # Process monitoring & protection
├── ai_unified_menu.sh             # Interactive TUI menu
│
├── grok_integration.sh            # Grok/xAI setup
├── grok_menu.sh                   # Grok interactive menu
│
├── ollama_install.sh              # Ollama installation
├── ollama_menu.sh                 # Ollama interactive menu
│
├── mcp-lifecycle-manager.sh       # MCP server lifecycle
└── mcp-process-manager.sh         # MCP process management
```

---

## 🔧 Script Details

### `setup-ai-apis.sh` — Flagship (698 lines)

The crown jewel of the bundle. A comprehensive setup wizard that:

- Validates API keys for **OpenAI, Anthropic, Groq, xAI/Grok, Google, Cohere**
- Runs connectivity tests against each provider's endpoint
- Generates a `.env` template with all discovered keys
- Includes a **full test suite** that validates each integration
- Auto-detects existing configurations and merges them safely
- Produces a summary report of all configured providers

```bash
# Run interactively (recommended)
./setup-ai-apis.sh

# Non-interactive mode (for automation)
./setup-ai-apis.sh --non-interactive --env-file .env

# Validate existing setup
./setup-ai-apis.sh --validate-only
```

### `ai-cli-diagnostics.sh` — Environment Audit (121 lines)

Deep-dive diagnostics that captures your entire AI CLI environment:

- Shell, PATH, and system layout
- Python executables, versions, and active virtual environments
- Full `pip freeze` package inventory
- Aider config and transcript files
- LiteLLM proxy status
- Grok CLI installation state
- API endpoint reachability (redacted)
- Network connectivity checks

**Output is fully redacted** — safe to paste into support tickets or share with teams.

### `ai-resource-manager.sh` — Resource Governance (140 lines)

Prevents AI tools from consuming all system resources:

- **Memory limits:** 4096 MB per tool (configurable)
- **CPU caps:** 80% per tool with auto-termination at 95%
- **Concurrent tool limit:** 3 simultaneous tools (configurable)
- **Pre-flight checks:** Validates available resources before launching
- **Auto-cleanup:** Terminates and removes stale tool entries

### `ai-watchdog.sh` — Process Protection (123 lines)

Continuous monitoring daemon that protects your system from runaway AI processes:

- **CPU threshold alerts:** Warns at 90%, terminates at sustained 95%
- **Runtime limits:** Auto-terminates processes running >2 hours
- **Resource consumer identification:** Ranks top 5 resource-hogging AI processes
- **Logging:** Timestamped logs at `/tmp/ai-watchdog.log`
- **Three modes:** `run` (continuous), `once` (single check), `status` (overview)

### `ai_unified_menu.sh` — Interactive TUI (413 lines)

The central nervous system — one menu to rule them all:

- Color-coded terminal UI with bold/dim/color support
- Grok CLI submenu (interactive, quick prompt, file analysis, code review, git analysis)
- Ollama submenu (generate, list models, pull models)
- Python AI APIs submenu (agent scripts, API tests, examples)
- Quick Actions (ask any model, check keys, environment status)
- Environment auto-loading from `.env.d/` system

### `grok_integration.sh` + `grok_menu.sh` — Grok/xAI Suite (454 lines)

Complete Grok CLI management:

- Interactive prompt mode
- File analysis (read file, send to Grok)
- Code review mode with structured feedback
- Git repository analysis (status + recent commits)
- API key validation and configuration

### `ollama_install.sh` + `ollama_menu.sh` — Local Model Suite (226 lines)

Full Ollama lifecycle management:

- One-command installation via Homebrew
- Model listing and pulling
- Quick generation with model selection
- Interactive chat mode with context

### `mcp-lifecycle-manager.sh` — MCP Server Ops (152 lines)

Model Context Protocol server management:

- Start, stop, restart MCP servers
- Health check endpoints
- Log tailing and monitoring
- Server configuration validation
- Auto-restart on failure

### `mcp-process-manager.sh` — MCP Process Tracking (149 lines)

Process-level MCP management:

- List all running MCP processes
- Monitor resource usage per server
- Graceful shutdown with timeout
- Process tree analysis
- Stale process cleanup

---

## 📜 Changelog

See [`CHANGELOG.md`](./CHANGELOG.md) for full version history.

### v1.0.0 — Initial Release (2026-04-12)

- 9 production scripts, 2,476 lines total
- Multi-provider API setup (6+ providers)
- Full MCP server lifecycle management
- Resource monitoring and runaway process protection
- Interactive unified menu system
- Auto-redacted diagnostics for safe troubleshooting

---

## 📄 License

MIT License — see [`LICENSE`](./LICENSE).

**TL;DR:** Use it commercially, modify it, redistribute it. Just don't sue us if something breaks.

---

## 💬 Support & Updates

- **Documentation:** `INSTALL.md` for detailed setup instructions
- **Bug reports:** Include output from `./ai-cli-diagnostics.sh`
- **Feature requests:** Open an issue or email support

---

## 🏆 What You're Getting

| Metric | Value |
|--------|-------|
| Total scripts | 9 (13 files) |
| Total lines of code | 2,476 |
| AI providers supported | 6+ (OpenAI, Anthropic, Groq, xAI, Google, Cohere) |
| Local model support | Ollama (any model) |
| MCP server management | Full lifecycle |
| Resource monitoring | CPU, memory, runtime |
| Dependencies required | **Zero** (pure bash) |
| Platforms | macOS 12+ |
| Commercial license | ✅ MIT |

**Value at market:** Each script individually would sell for $15-29 on marketplaces.
**Bundle price today:** $79 for everything.

> 🚀 *The multi-model era demands better ops tooling. This is it.*

---

*AI Ops Command Center v1.0.0 — Built for developers who refuse to manage AI tools one at a time.*

**© 2026 — All rights reserved. MIT License.**
