# Changelog

All notable changes to the **AI Ops Command Center** will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [1.0.0] — 2026-04-12

### 🎉 Initial Release

#### Added — Flagship Scripts
- **`setup-ai-apis.sh`** (698 lines) — Complete API key setup wizard with validation, connectivity testing, `.env` generation, and full test suite for 6+ providers (OpenAI, Anthropic, Groq, xAI/Grok, Google, Cohere)
- **`ai-cli-diagnostics.sh`** (121 lines) — Comprehensive environment diagnostics: shell layout, Python inventory, virtual environments, Aider config, LiteLLM status, Grok CLI state, API reachability — all auto-redacted for safe sharing
- **`ai_unified_menu.sh`** (413 lines) — Interactive color-coded TUI menu providing unified access to Grok, Ollama, Python AI APIs, quick actions, and environment checks

#### Added — Resource Management
- **`ai-resource-manager.sh`** (140 lines) — CPU and memory governance per tool: configurable limits (4096 MB memory, 80% CPU), pre-flight resource checks, concurrent tool limits, auto-cleanup of stale processes
- **`ai-watchdog.sh`** (123 lines) — Continuous monitoring daemon: detects high-CPU processes (>90%), enforces runtime limits (>2 hours), identifies top resource consumers, timestamps all logs

#### Added — MCP Server Operations
- **`mcp-lifecycle-manager.sh`** (152 lines) — Full MCP server lifecycle: start, stop, restart, health checks, log tailing, configuration validation, auto-restart on failure
- **`mcp-process-manager.sh`** (149 lines) — Process-level MCP management: list running servers, monitor per-server resource usage, graceful shutdown with timeout, process tree analysis, stale cleanup

#### Added — Grok/xAI Integration
- **`grok_integration.sh`** (181 lines) — Grok CLI setup and configuration: API key validation, environment configuration, connectivity testing
- **`grok_menu.sh`** (273 lines) — Interactive Grok menu: quick prompts, file analysis, code review, git repository analysis, interactive chat mode

#### Added — Ollama Local Models
- **`ollama_install.sh`** (12 lines) — One-command Ollama installation via Homebrew
- **`ollama_menu.sh`** (214 lines) — Ollama interactive menu: quick generation, model listing, model pulling, interactive chat with context

#### Documentation
- `README.md` — Product overview, competitor comparison, usage examples, screenshots
- `INSTALL.md` — Step-by-step installation guide with API key setup for all 6+ providers
- `CHANGELOG.md` — This file
- `LICENSE` — MIT License
- `bundle-manifest.json` — Machine-readable bundle metadata

### Summary Statistics

| Metric | Value |
|--------|-------|
| Total scripts | 9 (13 files) |
| Total lines of code | 2,476 |
| AI providers supported | 6+ |
| Local model support | Ollama |
| MCP management | Full lifecycle |
| Resource monitoring | CPU, memory, runtime |
| External dependencies | Zero (pure bash) |

---

## [Unreleased]

### Planned for v1.1.0
- [ ] Support for additional MCP server configurations (SSE, HTTP, WebSocket)
- [ ] Prometheus metrics export for resource monitoring
- [ ] Slack/Discord notifications for watchdog alerts
- [ ] Docker Compose support for MCP server deployment
- [ ] Web UI dashboard option (optional, lightweight)

---

*AI Ops Command Center — Multi-Model Management*
*© 2026 — MIT License*
