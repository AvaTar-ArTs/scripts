# Interaction Rhythm Compliance

To ensure consistency, predictability, and high-quality outputs across all agent-driven operations, every interaction MUST follow this enforced rhythm.

## The Interaction Rhythm

1. **Request**: The clear articulation of the user's need, constraint, or intent.
2. **Skill Check/Invocation**: Identification and activation of the appropriate specialized skill(s).
3. **Announcement**: Explicit declaration of the agent's intent, scope, and plan before execution.
4. **Execution**: The performance of the task, including tool usage and internal processing.
5. **Verification**: A structured review of the results against the original request, including validation and cleanup.

## Implementation Guidelines
- **Strict Adherence**: All sub-agents must adhere to this cycle. 
- **Announce Early**: Always perform the "Announcement" step before any side-effect-inducing tool call.
- **Verify Always**: Never claim completion without a final verification step.
