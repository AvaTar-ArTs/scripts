# Storage Configuration

This document defines the authorized paths for persistent memory and core repository components to ensure standardization across the ecosystem.

## Authoritative Storage Locations

| Component | Path | Description |
| :--- | :--- | :--- |
| **Persistent Memory** | `~/.gemini/memory` | Authorized location for all agent-based persistent data and state. |
| **Supreme Powers** | `~/my-supremepowers` | Base directory for all specialized agent skills and functional superpowers. |

## Migration Policy
- All future development and configuration must utilize these paths.
- Temporary paths or legacy storage (`~/.gemini/tmp/scripts/memory/`) are deprecated and must not be used for new implementations.
