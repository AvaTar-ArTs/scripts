# Agent Synchronization Plan

To ensure all agents, sub-agents, and automated processes remain synchronized with the new storage and interaction standards, the following synchronization protocol is established.

## Protocol

1. **Storage Standardization (Path Adoption)**:
   - All agents are required to immediately switch to `~/.gemini/memory` for persistent storage.
   - Legacy paths (if encountered in local scripts) must be redirected via symlink or updated immediately to `~/.gemini/memory`.
   - `~/my-supremepowers` is designated as the immutable source for skills.

2. **Interaction Rhythm Enforcement**:
   - All agent interactions must follow the approved rhythm (`Request` -> `Skill Check/Invocation` -> `Announcement` -> `Execution` -> `Verification`).
   - Agent "Announcement" steps must explicitly state intended path changes or storage usage if relevant to the request.

3. **Continuous Auditing**:
   - Agents are instructed to perform a "Context Check" at the start of every session to ensure local configurations align with these established standards.
   - Any deviation found must be logged in `docs/CHANGELOG.md` and remediated.

## Implementation Steps
- [ ] Notify all active agent sessions of the new standardization.
- [ ] Agents to audit own configurations on next boot.
- [ ] Maintain adherence in all future `brainstorming -> writing-plans -> TDD -> verification` workflows.
