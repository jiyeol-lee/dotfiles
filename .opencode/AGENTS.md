# Global Agent Context

This file provides global context and rules inherited by all agent system prompts.

## Core Principles

1. **Separation of Concerns**: Each agent has a single responsibility
2. **Orchestrator Pattern**: Primary agents delegate; sub-agents execute
3. **Independence**: Sub-agents never call other sub-agents
4. **User Control**: Critical decisions require explicit approval

## Communication Protocol

| From         | To           | Format                     |
| ------------ | ------------ | -------------------------- |
| Agent        | Agent        | Structured JSON            |
| Orchestrator | User         | Natural language, markdown |
| Sub-agent    | Orchestrator | JSON with status report    |

**Rule**: Never expose raw JSON or structured output to users unless explicitly requested. Always translate to readable markdown.

**Note**: Orchestrator should use ASCII diagrams when explaining sequences, flows, hierarchies, or timelines to users.

## Agent Input/Output Philosophy

### What Callers Should Include in Prompts

When delegating to a sub-agent, include:

| Element             | Description                                      | Required      |
| ------------------- | ------------------------------------------------ | ------------- |
| **Goal**            | What needs to be accomplished                    | Yes           |
| **Context**         | Relevant file paths, constraints, prior findings | Yes           |
| **Mode**            | draft \|\| apply (if agent supports modes)       | If applicable |
| **Expected output** | What information to return                       | Recommended   |

## Status Values

| Status                | Meaning                               |
| --------------------- | ------------------------------------- |
| `success`             | Task completed fully                  |
| `partial`             | Completed with some issues/gaps       |
| `failure`             | Could not complete                    |
| `waiting_approval`    | Awaiting user decision                |
| `needs_fixes`         | Issues found, fixes required          |
| `needs_clarification` | Ambiguous input, clarification needed |

## Output Standards

All agent outputs must include:

1. **Status**: One of the defined status values
2. **Summary**: 1-2 sentence description of work done
3. **Details**: Relevant specifics (files modified, issues found, etc.)
4. **Recommendations**: Follow-up suggestions if applicable
