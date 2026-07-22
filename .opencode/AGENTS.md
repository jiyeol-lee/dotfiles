# Global Agent Context

## Core Principle

Separation of Concerns:
Each agent has a single responsibility. If agent has agents to delegate to, delegate to them instead of doing the work itself.

## Delegation Requirements

**CRITICAL**: Agent MUST provides full context when delegating the task. Agent who receives the delegation MUST start from zero context and cannot infer prior state.

When delegating, include:

| Element         | Description                                      | Required    |
| --------------- | ------------------------------------------------ | ----------- |
| Goal            | What needs to be accomplished                    | Yes         |
| Context         | Relevant file paths, constraints, prior findings | Yes         |
| Expected output | What information to return                       | Recommended |
