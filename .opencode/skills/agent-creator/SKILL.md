---
name: agent-creator
description: Creates or updates primary and sub-agents in the opencode agentic system. Use when user asks to "create an agent", "add an agent", "update an agent", "modify an agent", "configure an agent", "add a sub-agent", "add a primary agent", or needs to define a new agent role, permissions, or skill access.
---

## Quick Start

1. Determine agent type (primary vs subagent)
2. Gather agent configuration (name, description, prompt, permissions, skills)
3. Create/update prompt file in `.opencode/prompts/agent/{type}/{name}.md`
4. Register agent in `.opencode/opencode.json`
5. Validate the configuration

## Agent Types

| Type     | Mode       | Purpose                                                     | Prompt Location                     |
| -------- | ---------- | ----------------------------------------------------------- | ----------------------------------- |
| Primary  | `primary`  | Orchestrator - delegates to sub-agents, synthesizes results | `.opencode/prompts/agent/primary/`  |
| Subagent | `subagent` | Worker - executes specific tasks using skills               | `.opencode/prompts/agent/subagent/` |

## Workflow

### Step 1: Determine Agent Configuration

Collect or validate the following from user:

| Field         | Required | Description                                                                   |
| ------------- | -------- | ----------------------------------------------------------------------------- |
| `name`        | Yes      | kebab-case identifier (e.g., `code-reviewer`, `data-analyst`)                 |
| `description` | Yes      | Human-readable description of agent's purpose                                 |
| `type`        | Yes      | `primary` or `subagent`                                                       |
| `hidden`      | No       | Subagents only - if true, agent won't be shown in agent list (default: false) |

### Step 2: Draft the Agent Prompt

Create the prompt file at `.opencode/prompts/agent/{type}/{name}.md`:

```markdown
# {Agent Name}

You are the **{Agent Name}** agent. {Brief role description}.

## Role

{Detailed explanation of what the agent does, when to use it, and how it fits in the hierarchy}

## Responsibilities

- {Specific task areas}
- {What it should and shouldn't do}
- {Boundaries and constraints}

## Example Interactions

{Concrete examples of typical requests and how the agent should respond}

## Output Format

{Any specific output requirements, or reference the standard JSON schema}
```

### Step 3: Configure Permissions

Determine required permissions based on agent type:

**Subagent Permissions Template:**

```json
{
  "bash": "deny",
  "edit": "allow",
  "write": "allow",
  "read": "allow",
  "grep": "allow",
  "glob": "allow",
  "list": "allow",
  "patch": "deny",
  "todowrite": "deny",
  "todoread": "deny",
  "webfetch": "deny",
  "question": "deny",
  "skill": {
    "{skill-name}": "allow"
  }
}
```

**Primary Agent Permissions Template:**

```json
{
  "bash": "deny",
  "edit": "deny",
  "write": "deny",
  "read": "deny",
  "grep": "deny",
  "glob": "deny",
  "list": "deny",
  "patch": "deny",
  "todowrite": "allow",
  "todoread": "allow",
  "webfetch": "deny",
  "question": "allow",
  "task": {
    "*": "deny",
    "subagent/{subagent-name}": "allow"
  }
}
```

### Step 4: Register Agent in opencode.json

Add agent entry under `agent` section:

```json
"agent": {
  "{type}/{name}": {
    "description": "{description}",
    "mode": "{primary|subagent}",
    "prompt": "{file:./prompts/agent/{type}/{name}.md}",
    "hidden": {true|false},
    "permission": {permissions-object}
  }
}
```

### Step 5: Validate Configuration

After writing files:

1. Verify prompt file exists at correct path
2. Verify `opencode.json` is valid JSON
3. Verify agent name is unique (no duplicate keys)

## Example: Creating a Data Analyst Subagent

```
User request: "Create a sub-agent called 'data-analyst' that can run Python scripts and query databases"

Step 1 - Configuration:
  name: data-analyst
  description: Data analysis specialist for running Python scripts and database queries
  type: subagent
  hidden: false

Step 2 - Create prompt file:
  Path: .opencode/prompts/agent/subagent/data-analyst.md
  Content: Defines role as data analyst with Python and SQL expertise

Step 3 - Configure permissions:
  - Allow: bash (python, psql commands), read, write, edit
  - Deny: webfetch, question
  - Skills: check (for validation)

Step 4 - Register in opencode.json:
  Add entry under "agent" with mode: "subagent"

Step 5 - Validate:
  ✓ File created at correct path
  ✓ JSON valid
  ✓ Agent registered
```

## Updating an Existing Agent

When updating an existing agent:

1. **Read current configuration** from `opencode.json`
2. **Modify only the intended fields** (prompt, permissions, description)
3. **Never change the agent key** (the `{type}/{name}` identifier)
4. **Validate** after changes

## Constraints (Never Allowed)

- Duplicate agent names (must be unique in opencode.json)
- Invalid JSON in opencode.json
- Missing required fields (name, description, type, prompt path)
- Agent prompts outside `.opencode/prompts/agent/`
- Circular agent dependencies (agent A calling agent B calling A)
- Destructive operations without explicit user confirmation
