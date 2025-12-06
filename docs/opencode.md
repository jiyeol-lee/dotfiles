# Multi-Agent System Reference

## Table of Contents

1. [Agent Summary](#agent-summary)
2. [Directory Structure](#directory-structure)
3. [Agent Relationship Diagrams](#agent-relationship-diagrams)
4. [Agent Invocation Reference](#agent-invocation-reference)
5. [Workflow Diagrams](#workflow-diagrams)
6. [MCP Server Matrix](#mcp-server-matrix)
7. [Tool Permission Matrix](#tool-permission-matrix)
8. [Quick Reference](#quick-reference)

## Agent Summary

| Type    | Agent                    | Role                                    |
| ------- | ------------------------ | --------------------------------------- |
| Primary | `@primary/plan`          | Research and task planning orchestrator |
| Primary | `@primary/standard-dev`  | Structured development workflow         |
| Primary | `@primary/flexible-dev`  | Adaptive development workflow           |
| Sub     | `@subagent/research`     | Information gathering                   |
| Sub     | `@subagent/task`         | Task breakdown and planning             |
| Sub     | `@subagent/code`         | Code implementation                     |
| Sub     | `@subagent/qa`           | Testing and validation                  |
| Sub     | `@subagent/commit`       | Git commits (Draft/Apply Mode)          |
| Sub     | `@subagent/pull-request` | PR management (Draft/Apply Mode)        |
| Sub     | `@subagent/document`     | Documentation (Draft Mode)              |
| Sub     | `@subagent/devops`       | DevOps and infrastructure               |
| Sub     | `@subagent/review`       | Code review (3 focus areas)             |

## Directory Structure

```
.opencode/
├── AGENTS.md                           # Global rules (existing)
├── opencode.json                       # Configuration (existing)
│
├── agent/
│   ├── primary/                        # Primary agents (orchestrators)
│   │   ├── plan.md                     # @primary/plan
│   │   ├── standard-dev.md             # @primary/standard-dev
│   │   └── flexible-dev.md             # @primary/flexible-dev
│   │
│   └── subagent/                       # Sub-agents (specialists)
│       ├── research.md                 # @subagent/research
│       ├── task.md                     # @subagent/task
│       ├── code.md                     # @subagent/code
│       ├── qa.md                       # @subagent/qa
│       ├── commit.md                   # @subagent/commit
│       ├── pull-request.md             # @subagent/pull-request
│       ├── document.md                 # @subagent/document
│       ├── devops.md                   # @subagent/devops
│       └── review.md                   # @subagent/review
│
├── command/                            # Commands
│   ├── command__commit.md              # Shortcut for commit workflow
│   ├── command__pull-request.md        # Shortcut for PR workflow
│   └── command__review.md              # Shortcut for code review
│
├── plugin/                             # Plugins
│   └── notifications.ts
│
└── themes/                             # Themes
    └── opencode-custom.json
```

## Agent Relationship Diagrams

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                                   USER REQUEST                                      │
└─────────────────────────────────────────────────────────────────────────────────────┘
                                          │
            ┌─────────────────────────────┼─────────────────────────────┐
            ▼                             ▼                             ▼
┌─────────────────────┐       ┌─────────────────────┐       ┌─────────────────────┐
│   @primary/plan     │       │ @primary/           │       │ @primary/           │
│                     │       │ standard-dev        │       │ flexible-dev        │
│  (Research &        │       │                     │       │                     │
│   Planning)         │       │  (Structured)       │       │   (Adaptive)        │
└──────────┬──────────┘       └──────────┬──────────┘       └──────────┬──────────┘
           │                             │                             │
           │                             └──────────────┬──────────────┘
           │                                            │
           ▼                                            ▼
┌───────────────────────────────────────────────┐   ┌───────────────────────────────────────────────────────────────────────────┐
│              PLANNING SUB-AGENTS              │   │                          DEVELOPMENT SUB-AGENTS                           │
│         (Dedicated to @primary/plan)          │   │         (Shared by @primary/standard-dev & @primary/flexible-dev)         │
├───────────────────────────────────────────────┤   ├───────────────────────────────────────────────────────────────────────────┤
│                                               │   │                                                                           │
│  ┌────────────────────┐  ┌────────────────┐   │   │  ┌────────────────┐  ┌──────────────┐  ┌────────────────────┐             │
│  │ @subagent/research │  │ @subagent/task │   │   │  │ @subagent/code │  │ @subagent/qa │  │ @subagent/document │             │
│  └────────────────────┘  └────────────────┘   │   │  └────────────────┘  └──────────────┘  └────────────────────┘             │
│                                               │   │                                                                           │
│                                               │   │  ┌──────────────────┐  ┌───────────────────┐                              │
│                                               │   │  │ @subagent/devops │  │ @subagent/review* │                              │
│                                               │   │  └──────────────────┘  └───────────────────┘                              │
│                                               │   │                                                                           │
│                                               │   │  * review also available via /command__review                             │
└───────────────────────────────────────────────┘   └───────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────────────┐
│                           COMMAND-TRIGGERED SUB-AGENTS                              │
│        (Invoked ONLY via user commands - NOT by orchestrators)                      │
├─────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                     │
│    ┌────────────────────────────────────┐    ┌────────────────────────────────────┐ │
│    │      @subagent/commit              │    │      @subagent/pull-request        │ │
│    │                                    │    │                                    │ │
│    │      /command__commit              │    │      /command__pull-request        │ │
│    └────────────────────────────────────┘    └────────────────────────────────────┘ │
│                                                                                     │
│    NOTE: These agents are ONLY invoked via user commands, not automatically         │
│          by orchestrators. See "Agent Invocation Reference" section.                │
│                                                                                     │
└─────────────────────────────────────────────────────────────────────────────────────┘
```

### Key Points

- `@primary/plan` has its own dedicated sub-agents (`@subagent/research`, `@subagent/task`) and does NOT use development sub-agents
- `@primary/standard-dev` and `@primary/flexible-dev` share the same development sub-agents (`@subagent/code`, `@subagent/qa`, `@subagent/document`, `@subagent/devops`, `@subagent/review`)
- Sub-agents never call other sub-agents; they only report to their orchestrator
- `@subagent/commit` and `@subagent/pull-request` are ONLY invoked via commands (`/command__commit`, `/command__pull-request`)
- `@subagent/review` is invoked by orchestrators AND available via `/command__review` command

## Agent Invocation Reference

### Command-Triggered Only

These agents are exclusively triggered by user commands, not by orchestrators:

| Agent                    | Command                  | Flow                               |
| ------------------------ | ------------------------ | ---------------------------------- |
| `@subagent/commit`       | `/command__commit`       | Draft Mode → Approval → Apply Mode |
| `@subagent/pull-request` | `/command__pull-request` | Draft Mode → Approval → Apply Mode |

### Orchestrator-Invoked (also available via command)

| Agent              | Invoked By                                 |
| ------------------ | ------------------------------------------ |
| `@subagent/review` | Orchestrator OR `/command__review` command |

### Orchestrator-Invoked Only

These agents are invoked by primary agents as part of workflows:

| Agent                | Used By                                          |
| -------------------- | ------------------------------------------------ |
| `@subagent/research` | `@primary/plan` only                             |
| `@subagent/task`     | `@primary/plan` only                             |
| `@subagent/code`     | `@primary/standard-dev`, `@primary/flexible-dev` |
| `@subagent/qa`       | `@primary/standard-dev`, `@primary/flexible-dev` |
| `@subagent/document` | `@primary/standard-dev`, `@primary/flexible-dev` |
| `@subagent/devops`   | `@primary/standard-dev`, `@primary/flexible-dev` |

## Workflow Diagrams

### Plan Agent Workflow

```
┌───────────────────────────────────────────────────────────────────────────────┐
│                              @primary/plan                                    │
│                       (Research & Planning Orchestrator)                      │
└───────────────────────────────────────────────────────────────────────────────┘
                                        │
                                        │ 1. Receive planning request
                                        ▼
                          ┌───────────────────────────────┐
                          │     Analyze Requirements      │
                          │     Identify research needs   │
                          └───────────────────────────────┘
                                        │
              ┌─────────────────────────┴─────────────────────────┐
              │                                                   │
              │ 2. Parallel research                              │
              │    (if multiple topics)                           │
              ▼                                                   ▼
    ┌───────────────────┐                           ┌───────────────────┐
    │    @subagent/     │                           │    @subagent/     │
    │     research      │                           │     research      │
    │    (Topic A)      │                           │    (Topic B)      │
    └─────────┬─────────┘                           └─────────┬─────────┘
              │                                               │
              │ Report findings                               │ Report findings
              └───────────────────────┬───────────────────────┘
                                      │
                                      ▼
                          ┌───────────────────────────────┐
                          │     Synthesize Research       │
                          │        @primary/plan          │
                          └───────────────────────────────┘
                                        │
                                        │ 3. Delegate task breakdown
                                        ▼
                              ┌───────────────────┐
                              │    @subagent/     │
                              │       task        │
                              └─────────┬─────────┘
                                        │
                                        │ Report task plan
                                        ▼
                          ┌───────────────────────────────┐
                          │    Review & Finalize Plan     │
                          │       Present to User         │
                          └───────────────────────────────┘

LOOP LIMIT: Max 3 research ↔ task cycles before asking user
```

### Standard Dev Agent Workflow

```
┌───────────────────────────────────────────────────────────────────────────────┐
│                           @primary/standard-dev                               │
│                       (Structured Development Workflow)                       │
└───────────────────────────────────────────────────────────────────────────────┘
                                        │
                                        │ 1. Receive development task
                                        ▼
┌───────────────────────────────────────────────────────────────────────────────┐
│                              PHASE 1: WORK                                    │
├───────────────────────────────────────────────────────────────────────────────┤
│                                                                               │
│    Determine work type and delegate to ONE of:                                │
│                                                                               │
│    ┌───────────────────┐  ┌───────────────────┐  ┌───────────────────┐        │
│    │     @subagent/    │  │     @subagent/    │  │     @subagent/    │        │
│    │       code        │  │      document     │  │       devops      │        │
│    └─────────┬─────────┘  └─────────┬─────────┘  └─────────┬─────────┘        │
│              │                      │                      │                  │
│              │    work_agent =      │    work_agent =      │    work_agent =  │
│              │      "code"          │     "document"       │      "devops"    │
│              └──────────────────────┴──────────────────────┘                  │
│                                     │                                         │
│                        Work agent reports back with changes                   │
│                                                                               │
└───────────────────────────────────────────────────────────────────────────────┘
                                        │
                                        ▼
┌───────────────────────────────────────────────────────────────────────────────┐
│                     PHASE 1 → PHASE 2 ROUTING LOGIC                           │
├───────────────────────────────────────────────────────────────────────────────┤
│                                                                               │
│    ┌─────────────────────────────────────────────────────────────────────┐    │
│    │  What was the Phase 1 work_agent?                                   │    │
│    │                                                                     │    │
│    │  "document" ─► SKIP Phase 2 ──────────────────► Go to Phase 2.5     │    │
│    │                (Documentation is the work itself)                   │    │
│    │                                                                     │    │
│    │  "code" OR "devops" ─► Execute Phase 2 (Documentation Check)        │    │
│    │                                                                     │    │
│    └─────────────────────────────────────────────────────────────────────┘    │
│                                                                               │
└───────────────────────────────────────────────────────────────────────────────┘
                                        │
                        ┌───────────────┴───────────────┐
                        │                               │
            (code/devops work)                 (document work)
                        │                               │
                        ▼                               │
┌───────────────────────────────────────────────────────│───────────────────────┐
│                        PHASE 2: DOCUMENTATION CHECK   │                       │
│                   (Only for code/devops work)         │                       │
├───────────────────────────────────────────────────────│───────────────────────┤
│                                                       │                       │
│    ┌──────────────────────────────────────────────┐   │                       │
│    │  Did behavior change?                        │   │                       │
│    │                                              │   │                       │
│    │  YES ─► Draft documentation changes          │   │                       │
│    │         ┌────────────────────────────────┐   │   │                       │
│    │         │ @subagent/document (Draft Mode)│   │   │                       │
│    │         └────────────────────────────────┘   │   │                       │
│    │                                              │   │                       │
│    │         ╔═══════════════════════════════╗    │   │                       │
│    │         ║ STOP: Present draft to user   ║    │   │                       │
│    │         ║ "Apply these doc changes?"    ║    │   │                       │
│    │         ║ WAIT for explicit approval    ║    │   │                       │
│    │         ╚═══════════════════════════════╝    │   │                       │
│    │                                              │   │                       │
│    │  NO  ─► Skip to Phase 2.5                    │   │                       │
│    └──────────────────────────────────────────────┘   │                       │
│                                                       │                       │
└───────────────────────────────────────────────────────│───────────────────────┘
                        │                               │
                        └───────────────┬───────────────┘
                                        │
                                        ▼
┌───────────────────────────────────────────────────────────────────────────────┐
│                     PHASE 2.5: QA/TESTING (Conditional)                       │
├───────────────────────────────────────────────────────────────────────────────┤
│                                                                               │
│    ┌─────────────────────────────────────────────────────────────────────┐    │
│    │  What was the Phase 1 work_agent?                                   │    │
│    │                                                                     │    │
│    │  "document" ─► SKIP Phase 2.5 ──────────────────► Go to Phase 3     │    │
│    │                (No tests needed for documentation changes)          │    │
│    │                                                                     │    │
│    │  "code" OR "devops" ─► Execute Phase 2.5 (QA/Testing)               │    │
│    │                                                                     │    │
│    └─────────────────────────────────────────────────────────────────────┘    │
│                                                                               │
│    Invoke @subagent/qa to validate implementation:                            │
│                                                                               │
│    ┌─────────────────────────────────────────────────────────────────────┐    │
│    │                                                                     │    │
│    │  ┌─────────────────────────────────────────────────────────────┐    │    │
│    │  │                      @subagent/qa                           │    │    │
│    │  │                                                             │    │    │
│    │  │  • Run existing tests                                       │    │    │
│    │  │  • Write new tests if needed                                │    │    │
│    │  │  • Validate functionality                                   │    │    │
│    │  │  • Can use Playwright MCP for E2E testing                   │    │    │
│    │  │  • Can write/run scripts to verify functionality            │    │    │
│    │  └─────────────────────────────────────────────────────────────┘    │    │
│    │                                                                     │    │
│    │  ┌──────────────────────────────────────────────────────────────┐   │    │
│    │  │  Tests pass?                                                 │   │    │
│    │  │                                                              │   │    │
│    │  │  YES ─► Proceed to Review Phase                              │   │    │
│    │  │                                                              │   │    │
│    │  │  NO  ─► Report failures, recommend loop back to Phase 1      │   │    │
│    │  │         WAIT for user decision                               │   │    │
│    │  └──────────────────────────────────────────────────────────────┘   │    │
│    │                                                                     │    │
│    └─────────────────────────────────────────────────────────────────────┘    │
│                                                                               │
└───────────────────────────────────────────────────────────────────────────────┘
                                        │
                                        ▼
┌───────────────────────────────────────────────────────────────────────────────┐
│                          PHASE 3: PARALLEL REVIEW                             │
├───────────────────────────────────────────────────────────────────────────────┤
│                                                                               │
│    Run 3 reviewers in PARALLEL with assigned focus areas:                     │
│                                                                               │
│    ┌─────────────────────────────────────────────────────────────────────┐    │
│    │                                                                     │    │
│    │  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐      │    │
│    │  │   @subagent/    │  │   @subagent/    │  │   @subagent/    │      │    │
│    │  │     review      │  │     review      │  │     review      │      │    │
│    │  │                 │  │                 │  │                 │      │    │
│    │  │  Focus Area:    │  │  Focus Area:    │  │  Focus Area:    │      │    │
│    │  │    QUALITY      │  │   REGRESSION    │  │  DOCUMENTATION  │      │    │
│    │  └────────┬────────┘  └────────┬────────┘  └────────┬────────┘      │    │
│    │           │                    │                    │               │    │
│    │           └────────────────────┼────────────────────┘               │    │
│    │                                ▼                                    │    │
│    │                   Aggregate review findings                         │    │
│    │                                                                     │    │
│    └─────────────────────────────────────────────────────────────────────┘    │
│                                                                               │
└───────────────────────────────────────────────────────────────────────────────┘
                                        │
                                        ▼
┌───────────────────────────────────────────────────────────────────────────────┐
│                         PHASE 4: ISSUE RESOLUTION                             │
├───────────────────────────────────────────────────────────────────────────────┤
│                                                                               │
│    ┌─────────────────────────────────────────────────────────────────────┐    │
│    │  Issues found?                                                      │    │
│    │                                                                     │    │
│    │  YES ─► Present issues to user                                      │    │
│    │         Recommend loop back to Phase 1                              │    │
│    │         WAIT for user decision                                      │    │
│    │                                                                     │    │
│    │  NO  ─► Report success, workflow complete                           │    │
│    └─────────────────────────────────────────────────────────────────────┘    │
│                                                                               │
│    NOTE: Workflow ENDS here. Commit/PR are invoked separately via commands.   │
│                                                                               │
└───────────────────────────────────────────────────────────────────────────────┘
```

### Flexible Dev Agent Workflow

```
┌───────────────────────────────────────────────────────────────────────────────┐
│                           @primary/flexible-dev                               │
│                        (Adaptive Development Workflow)                        │
└───────────────────────────────────────────────────────────────────────────────┘
                                        │
                                        │ 1. Receive development task
                                        ▼
                          ┌───────────────────────────────┐
                          │    ASSESS TASK COMPLEXITY     │
                          │                               │
                          │    Factors considered:        │
                          │    • Scope of changes         │
                          │    • Files affected           │
                          │    • Risk level               │
                          │    • Dependencies             │
                          └───────────────────────────────┘
                                        │
              ┌─────────────────────────┴─────────────────────────┐
              │                                                   │
              ▼                                                   ▼
    ┌───────────────────────────┐               ┌───────────────────────────┐
    │       TRIVIAL TASK        │               │       COMPLEX TASK        │
    │                           │               │                           │
    │   Criteria:               │               │   Criteria:               │
    │   • Single file           │               │   • Multiple files        │
    │   • Low risk              │               │   • Breaking changes      │
    │   • No behavior change    │               │   • API changes           │
    │   • Quick fix             │               │   • New features          │
    │                           │               │   • Refactoring           │
    └─────────────┬─────────────┘               └─────────────┬─────────────┘
                  │                                           │
                  ▼                                           ▼
    ┌───────────────────────────────────┐       ┌───────────────────────────┐
    │       TRIVIAL WORKFLOW            │       │      FULL WORKFLOW        │
    │                                   │       │    (like standard-dev)    │
    │   1. Work Phase via appropriate   │       │                           │
    │      sub-agent:                   │       │   1. Work Phase           │
    │      • @subagent/code             │       │   2. Doc Check            │
    │        (for code fixes)           │       │   3. QA Phase (2.5)       │
    │      • @subagent/document         │       │   4. Review Phase         │
    │        (for doc fixes like typo)  │       │   5. Resolution           │
    │      • @subagent/devops           │       │                           │
    │        (for simple config)        │       │   Same as standard-dev    │
    │                                   │       │   workflow                │
    │   2. QA Phase (2.5)               │       │                           │
    │      SKIP if work_agent="document"│       │                           │
    │      RUN @subagent/qa otherwise   │       │                           │
    │                                   │       │                           │
    │   3. FULL 3x Review               │       │                           │
    │      Quality                      │       │                           │
    │      Regression                   │       │                           │
    │      Documentation                │       │                           │
    │                                   │       │                           │
    │   4. Report done                  │       │                           │
    │                                   │       │                           │
    │   NOTE: No Doc Check              │       │                           │
    │   (no behavior change)            │       │                           │
    └───────────────────────────────────┘       └───────────────────────────┘

    ╔═══════════════════════════════════════════════════════════════════════╗
    ║  ADAPTIVE RULES:                                                      ║
    ║                                                                       ║
    ║  • Typo fix (code)    ─► TRIVIAL (skip Doc Check, full review)        ║
    ║  • Typo fix (docs)    ─► TRIVIAL (skip Doc Check AND QA, full review) ║
    ║  • Config change      ─► TRIVIAL (single file, no behavior change)    ║
    ║  • Bug fix            ─► ASSESS (depends on scope)                    ║
    ║  • New feature        ─► COMPLEX (full workflow)                      ║
    ║  • Refactoring        ─► COMPLEX (regression risk)                    ║
    ║  • API change         ─► COMPLEX (breaking changes)                   ║
    ╚═══════════════════════════════════════════════════════════════════════╝

    NOTE: Workflow ENDS after successful review. Commit/PR are invoked
          separately via user commands (/command__commit, /command__pull-request).
```

## MCP Server Matrix

> **Note**: Short names refer to `@subagent/*` agents (e.g., "research" = `@subagent/research`).

| MCP Server      | research | task | code | qa  | commit | pull-request | document | devops | review |
| --------------- | :------: | :--: | :--: | :-: | :----: | :----------: | :------: | :----: | :----: |
| `context7`      |    ✅    |  ❌  |  ✅  | ✅  |   ❌   |      ❌      |    ✅    |   ✅   |   ❌   |
| `aws-knowledge` |    ✅    |  ❌  |  ✅  | ✅  |   ❌   |      ❌      |    ✅    |   ✅   |   ❌   |
| `linear`        |    ✅    |  ❌  |  ❌  | ❌  |   ❌   |      ✅      |    ❌    |   ❌   |   ❌   |
| `atlassian`     |    ✅    |  ❌  |  ❌  | ❌  |   ❌   |      ✅      |    ❌    |   ❌   |   ❌   |
| `playwright`    |    ❌    |  ❌  |  ❌  | ✅  |   ❌   |      ❌      |    ❌    |   ❌   |   ❌   |

### Server Purposes

| Server          | Purpose                | Use Cases                               |
| --------------- | ---------------------- | --------------------------------------- |
| `context7`      | Library/framework docs | API lookups, best practices, examples   |
| `aws-knowledge` | AWS documentation      | Service configs, IAM policies, patterns |
| `linear`        | Issue tracking         | Link PRs to issues, check task status   |
| `atlassian`     | Jira/Confluence        | Link to Jira tickets, wiki references   |
| `playwright`    | Browser automation     | E2E testing, UI validation              |

## Tool Permission Matrix

### Built-in Tools

| Tool        | Description                                                  |
| ----------- | ------------------------------------------------------------ |
| `bash`      | Execute shell commands                                       |
| `edit`      | Modify existing files using exact string replacements        |
| `write`     | Create new files or overwrite existing ones                  |
| `read`      | Read file contents                                           |
| `grep`      | Search file contents using regex                             |
| `glob`      | Find files by pattern matching                               |
| `list`      | List files and directories                                   |
| `patch`     | Apply patches to files                                       |
| `todowrite` | Manage todo lists (disabled for subagents by default)        |
| `todoread`  | Read existing todo lists (disabled for subagents by default) |
| `webfetch`  | Fetch web content                                            |

### Primary Agents Permissions

| Tool        | plan | standard-dev | flexible-dev |
| ----------- | :--: | :----------: | :----------: |
| `bash`      |  ❌  |      ❌      |      ❌      |
| `edit`      |  ❌  |      ❌      |      ❌      |
| `write`     |  ❌  |      ❌      |      ❌      |
| `read`      |  ❌  |      ❌      |      ❌      |
| `grep`      |  ❌  |      ❌      |      ❌      |
| `glob`      |  ❌  |      ❌      |      ❌      |
| `list`      |  ❌  |      ❌      |      ❌      |
| `patch`     |  ❌  |      ❌      |      ❌      |
| `todowrite` |  ✅  |      ✅      |      ✅      |
| `todoread`  |  ✅  |      ✅      |      ✅      |
| `webfetch`  |  ❌  |      ❌      |      ❌      |
| MCP tools   |  ❌  |      ❌      |      ❌      |

**Primary agents can ONLY directly use `todowrite` and `todoread`. ALL other tools must go through sub-agents.**

### Sub-Agents Permissions

> **Note**: Short names refer to `@subagent/*` agents (e.g., "research" = `@subagent/research`).

| Tool        | research | task | code | qa  | commit | pull-request | document | devops | review |
| ----------- | :------: | :--: | :--: | :-: | :----: | :----------: | :------: | :----: | :----: |
| `bash`      |    ❌    |  ❌  |  ✅  | ✅  |   ✅   |      ✅      |    ❌    |   ✅   |   ✅   |
| `edit`      |    ❌    |  ❌  |  ✅  | ✅  |   ❌   |      ❌      |    ✅    |   ✅   |   ❌   |
| `write`     |    ❌    |  ❌  |  ✅  | ✅  |   ❌   |      ❌      |    ✅    |   ✅   |   ❌   |
| `read`      |    ✅    |  ✅  |  ✅  | ✅  |   ✅   |      ✅      |    ✅    |   ✅   |   ✅   |
| `grep`      |    ✅    |  ✅  |  ✅  | ✅  |   ✅   |      ✅      |    ✅    |   ✅   |   ✅   |
| `glob`      |    ✅    |  ✅  |  ✅  | ✅  |   ✅   |      ✅      |    ✅    |   ✅   |   ✅   |
| `list`      |    ✅    |  ✅  |  ✅  | ✅  |   ✅   |      ✅      |    ✅    |   ✅   |   ✅   |
| `patch`     |    ❌    |  ❌  |  ✅  | ✅  |   ❌   |      ❌      |    ✅    |   ✅   |   ❌   |
| `todowrite` |    ❌    |  ❌  |  ❌  | ❌  |   ❌   |      ❌      |    ❌    |   ❌   |   ❌   |
| `todoread`  |    ❌    |  ❌  |  ❌  | ❌  |   ❌   |      ❌      |    ❌    |   ❌   |   ❌   |
| `webfetch`  |    ✅    |  ❌  |  ❌  | ❌  |   ❌   |      ❌      |    ✅    |   ❌   |   ❌   |
| MCP tools   |    ✅    |  ❌  |  ✅  | ✅  |   ❌   |      ✅      |    ✅    |   ✅   |   ❌   |

### Bash Permission Matrix (Granular)

Each agent has granular bash permissions configured via `permission.bash` in their YAML frontmatter, following the principle of least privilege.

#### Permission Levels

| Level   | Meaning                              |
| ------- | ------------------------------------ |
| `deny`  | Command is blocked                   |
| `allow` | Command runs without approval        |
| `ask`   | Command requires user approval first |

#### Primary Agents (Orchestrators)

All primary agents have `permission.bash: deny` - they delegate to sub-agents.

| Agent                   | Bash Permission |
| ----------------------- | --------------- |
| `@primary/plan`         | `deny`          |
| `@primary/standard-dev` | `deny`          |
| `@primary/flexible-dev` | `deny`          |

#### Sub-Agents (Specialists)

| Agent                    | Default | Allowed Commands                                                                                                                                          | Ask Commands                                  |
| ------------------------ | ------- | --------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------- |
| `@subagent/code`         | `deny`  | ls, pwd, cat, head, tail, find, npm/pnpm/yarn/bun, go, cargo, pip, poetry, make, eslint, prettier, tsc, git (read)                                        | rm, mv                                        |
| `@subagent/commit`       | `deny`  | git status/diff/log/show/branch, git add/reset, git commit                                                                                                | git push                                      |
| `@subagent/devops`       | `deny`  | ls, pwd, cat, head, tail, find, yamllint, hadolint, shellcheck, actionlint, terraform init/validate/fmt, aws validate, docker build/images/ps, git (read) | terraform plan/apply, docker run/push, rm, mv |
| `@subagent/document`     | `deny`  | (none)                                                                                                                                                    | (none)                                        |
| `@subagent/pull-request` | `deny`  | git (read), git push, gh pr list/view/diff/status/checks, gh api                                                                                          | gh pr create/edit/merge                       |
| `@subagent/qa`           | `deny`  | ls, pwd, cat, head, tail, find, npm/pnpm/yarn/bun test, jest, vitest, playwright, cypress, go test, pytest, cargo test, coverage tools, git (read)        | (none)                                        |
| `@subagent/research`     | `deny`  | (none)                                                                                                                                                    | (none)                                        |
| `@subagent/review`       | `deny`  | git status/diff/log/show/branch, gh pr diff/view/checks/api                                                                                               | (none)                                        |
| `@subagent/task`         | `deny`  | (none)                                                                                                                                                    | (none)                                        |

#### Configuration Reference

Bash permissions are configured in each agent's markdown file frontmatter:

```yaml
---
description: Agent description
mode: subagent
tools:
  bash: true
  # ... other tools
permission:
  bash:
    "*": deny
    "git status": allow
    "git push *": ask
---
```

See [OpenCode Permissions Documentation](https://opencode.ai/docs/permissions/#bash) for full syntax.

## Quick Reference

### Agent ID Reference

| Agent        | ID                       | Type    | Invocation                                  |
| ------------ | ------------------------ | ------- | ------------------------------------------- |
| Plan         | `@primary/plan`          | Primary | User selection                              |
| Standard Dev | `@primary/standard-dev`  | Primary | User selection                              |
| Flexible Dev | `@primary/flexible-dev`  | Primary | User selection                              |
| Research     | `@subagent/research`     | Sub     | Orchestrator                                |
| Task         | `@subagent/task`         | Sub     | Orchestrator                                |
| Code         | `@subagent/code`         | Sub     | Orchestrator                                |
| QA           | `@subagent/qa`           | Sub     | Orchestrator                                |
| Commit       | `@subagent/commit`       | Sub     | **Command only** (`/command__commit`)       |
| Pull Request | `@subagent/pull-request` | Sub     | **Command only** (`/command__pull-request`) |
| Document     | `@subagent/document`     | Sub     | Orchestrator                                |
| DevOps       | `@subagent/devops`       | Sub     | Orchestrator                                |
| Review       | `@subagent/review`       | Sub     | Orchestrator or `/command__review`          |

### Mode Reference

| Mode          | Applies To           | Description                                  |
| ------------- | -------------------- | -------------------------------------------- |
| Draft Mode    | commit, pull-request | Analyze and propose                          |
| Apply Mode    | commit, pull-request | Perform operation                            |
| Draft Mode    | document             | Propose without applying                     |
| Research Mode | research             | Structured findings for planning             |
| Question Mode | research             | Conversational answers (no workflow trigger) |

### Phase Reference (Standard/Flexible Dev)

| Phase     | Description                      | Conditional?                                          |
| --------- | -------------------------------- | ----------------------------------------------------- |
| Phase 1   | Work (code, document, or devops) | Always                                                |
| Phase 2   | Documentation Check              | Skip if work_agent == "document"                      |
| Phase 2.5 | QA/Testing                       | Skip if work_agent == "document"; run for code/devops |
| Phase 3   | Parallel Review (3x)             | Always                                                |
| Phase 4   | Issue Resolution                 | Always                                                |

### Status Reference

| Status                | Meaning                      |
| --------------------- | ---------------------------- |
| `success`             | Task completed successfully  |
| `partial`             | Task partially completed     |
| `failure`             | Task failed                  |
| `waiting_approval`    | Awaiting user decision       |
| `needs_fixes`         | Issues found requiring fixes |
| `needs_clarification` | Insufficient information     |

### Severity Reference

| Severity         | Icon | Action Required            |
| ---------------- | ---- | -------------------------- |
| Critical         |      | Must fix before proceeding |
| Major/Warning    |      | Should fix                 |
| Minor/Suggestion |      | Nice to have               |
