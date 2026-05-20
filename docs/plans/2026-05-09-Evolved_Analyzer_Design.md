# Evolved Analyzer Script Design Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** To develop an advanced, comprehensive, and highly integrated code analysis and remediation system that evolves beyond the initial batched scripts, incorporating enhanced analysis, automated remediation, advanced reporting, flexible configuration, and seamless integration into development workflows.

**Architecture:** The evolved analyzer will likely consist of a core analysis engine (potentially in Python for flexibility and tool integration), a robust configuration management system, a reporting module for various outputs (interactive HTML, CI/CD formats), and integration points for external systems (Git, CI/CD, issue trackers). It will maintain the batched and dynamic processing approach to handle large codebases efficiently.

**Tech Stack:** Python (for core logic, tool orchestration, reporting), integrated command-line tools (`ruff`, `bandit`, `shellcheck`, `grep`, `md5sum`/`sha256sum`, `pip-audit`/`safety`, `radon`, `shfmt`), potentially web technologies (HTML, JavaScript for interactive reports), and configuration formats (YAML/TOML).

---

## 1. Enhanced Analysis

This section details features aimed at making the analysis capabilities more sophisticated and comprehensive, going beyond basic linting.

*   **More Granular Security Checks:**
    *   **Context-aware analysis** for common injection flaws (SQLi, XSS, Command Injection) with increased precision.
    *   **Deeper vulnerability scanning** within the codebase, potentially identifying logic-based security flaws.
    *   **Hardcoded secrets detection** with advanced techniques like entropy analysis or integration with dedicated tools such as `detect-secrets`.
*   **Dependency Vulnerability Scanning:**
    *   For Python projects, **integrate tools like `pip-audit` or `safety`** to scan `requirements.txt`, `pyproject.toml`, or `Pipfile.lock` for known vulnerabilities in third-party libraries. This check would extend to other language ecosystems if supported by the script's scope.
*   **Performance Anti-patterns Detection:**
    *   **Python:** Analyze for inefficient loops, repeated database queries within loops, excessive object creation, and large data structure copies.
    *   **Shell:** Detect inefficient use of pipes, excessive external command calls in loops, and suboptimal file operations that could impact performance.
*   **Deeper Code Complexity Metrics:**
    *   Calculate metrics such as **cyclomatic complexity** (e.g., using `radon` for Python), **maintainability index**, and **cognitive complexity** to identify hard-to-understand or hard-to-maintain code sections.
*   **Code Duplication Detection:**
    *   Beyond simple file hashing, implement or integrate tools (e.g., `pylint`'s `duplicate-code` checker for Python, `simian`, `pmd` for more general code duplication) to identify duplicated code blocks across multiple files, suggesting refactoring opportunities.
*   **Custom Rule Definition:**
    *   Allow users to define their own **custom analysis rules** using simple configuration (e.g., `grep`-like patterns, regular expressions, or simple AST-based rules) to detect project-specific anti-patterns or conventions.

## 2. Automated Remediation

This section focuses on moving beyond issue identification to actively assisting in their resolution, with safety mechanisms.

*   **Safe Autofixing:**
    *   Automatically apply fixes for **easily correctable issues** identified by integrated linters and formatters. This includes:
        *   **Python:** Integrating tools like `black`, `isort`, or `ruff fix` for style issues, unused imports, etc.
        *   **Shell:** Integrating `shfmt -w` for consistent script formatting, and auto-applying safe `shellcheck` suggestions.
    *   **Configurable Autofixing:** Allow users to enable/disable specific auto-fix rules or tools.
*   **Interactive Fix Suggestions:**
    *   For more complex issues that cannot be safely autofixed, the report will provide **context-aware, step-by-step instructions** or suggested code snippets for manual correction directly within the report.
*   **Revert Mechanism:**
    *   Implement a robust mechanism to **easily revert any automated changes** made by the script. This could involve creating temporary backups of modified files (e.g., `.bak` files) or leveraging Git features (e.g., staging changes only, or creating temporary branches).
*   **"Fix" Mode with Dry Run:**
    *   Introduce a dedicated operational mode (e.g., `--fix` or `--autofix`) for the script that attempts to apply fixes. This mode should include a `--dry-run` option to preview changes before they are actually applied to the codebase.

## 3. Advanced Reporting

This section details features for presenting analysis results in a more insightful, interactive, and integrated manner.

*   **Interactive HTML Reports:**
    *   Generate a single, **self-contained HTML dashboard** that presents analysis results.
    *   This report will feature **filtering, sorting, and searching** capabilities for findings (by file, type, severity).
    *   Include **graphical representations** (charts, graphs) showing issue distribution by type, severity, or trending over time (if historical data is enabled).
    *   Provide easy navigation between summary views and detailed issue information, potentially linking to affected code lines.
*   **Historical Data & Trending:**
    *   Implement a mechanism to **store past analysis reports** (e.g., in a structured format like JSON, SQLite, or a dedicated history directory).
    *   Enable **comparison between current and previous reports** to visualize trends in code quality, highlight new issues introduced, or track the resolution of existing issues over time.
*   **Integration with Dashboards/External Systems:**
    *   Provide options to **export analysis results in formats compatible with popular code quality dashboards** (e.g., SonarQube-like JSON output, Code Climate format) or custom analytics platforms.
*   **Diff Reporting for Changes:**
    *   When the analysis is performed on a specific code change (e.g., within a Git branch or pull request), the report could be designed to **highlight only the issues introduced or fixed by that particular change**, making code reviews more focused and efficient.
*   **Customizable Report Templates:**
    *   Allow users to **customize the visual layout and specific content sections** of the generated reports using templating languages (e.g., Jinja2 for Python-based reports).

## 4. Configuration Flexibility

This section focuses on making the analyzer scripts highly customizable and adaptable to different project needs without modifying the core code.

*   **External Configuration File:**
    *   All configurable parameters (e.g., dynamic batching thresholds, tool paths, specific `grep` patterns, default exclude patterns, output file names, severity mappings, enabled/disabled rules, report options) will be moved into a **dedicated external configuration file**.
    *   Supported formats could include `pyproject.toml` (for Python projects), `setup.cfg`, `analysis_config.yaml`, or `analysis_config.json`.
    *   This enables easy customization and version control of analysis settings.
*   **Profile Management:**
    *   Allow the definition and selection of **different named analysis profiles** within the configuration file.
    *   Examples: "fast-lint" (quick checks for pre-commit), "full-security" (deep security scan for CI/CD), "readability-focus" (prioritizing style and documentation).
    *   These profiles could be activated via a simple command-line argument (e.g., `--profile full-security`).
*   **Command-line Overrides:**
    *   Ensure that any setting defined in the external configuration file can still be **overridden via command-line arguments**, providing maximum flexibility for ad-hoc analyses or CI/CD pipelines.
*   **Granular Rule Customization:**
    *   Provide fine-grained control over which specific rules from integrated tools (e.g., `shellcheck` SC codes, `ruff` rule IDs, `bandit` B-codes) are **enabled, disabled, or have their severity levels adjusted** directly within the configuration file.
    *   Facilitate the easy definition and management of **custom `grep` patterns** or other project-specific analysis rules.

## 5. Integration

This section outlines how the analyzer scripts can be seamlessly integrated into existing development workflows and systems.

*   **Git Hooks Integration:**
    *   Provide **scripts or clear documentation** for easily integrating the analyzer into Git client-side hooks (e.g., `pre-commit`, `pre-push`, `post-merge`).
    *   This ensures that code quality checks are run automatically before changes are committed or pushed, preventing problematic code from entering the repository.
*   **CI/CD Pipeline Integration:**
    *   Generate analysis reports in **industry-standard formats** (e.g., JUnit XML for test results, SARIF for Static Analysis Results Interchange Format) that can be easily consumed and displayed by Continuous Integration/Continuous Deployment (CI/CD) systems (e.g., GitHub Actions, GitLab CI, Jenkins, Azure DevOps).
    *   Offer **clear documentation and example configurations** for popular CI/CD platforms to streamline integration.
*   **Issue Tracker Integration:**
    *   Implement functionality to **automatically create new issues or comments** in popular issue tracking systems (e.g., GitHub Issues, Jira, GitLab Issues) for critical or high-severity findings.
    *   The created issues would include relevant details from the analysis report (file path, line number, description, severity, suggested fix).
*   **IDE/Editor Integration (Conceptual):**
    *   As a long-term vision, outline the potential for a **lightweight IDE/editor plugin** that could run the analyzer in the background or on-demand, providing real-time feedback and inline annotations directly within the development environment. This would require a separate development effort but represents a powerful enhancement.

---

**Next Steps:**

This document serves as the high-level design for the "Evolved Analyzer Script." The next step would be to break this down into smaller, actionable implementation tasks using the `writing-plans` skill, or to select a specific feature from this design to start developing.

```
</design-document>
```
