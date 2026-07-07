---
name: conversation-memory
description: Records and retrieves durable user feedback, working preferences, and project-scoped conversation notes in SQLite for future reference. Use when a conversation starts or ends, when user says preferences such as "remember", "don't do that", "next time", "always", or "never", and before applying future work in a directory.
---

## Purpose

Use this skill to persist reusable user conventions and preferences across conversations. The memory database is SQLite at `~/.local/share/conversation-memory/memory.db`, and every memory row is scoped to the detected project directory.

## Workflow

### 1. Read memory first

At the start of a conversation or before doing substantive work:

1. Resolve the current project directory using the helper script's detection logic.
2. Read active memories for the detected project directory only. The helper automatically creates the database before reading.
3. Apply relevant preferences silently unless they conflict with explicit user instructions in the current conversation.

### 2. Capture memory-worthy feedback during the conversation

Store only durable guidance that should affect future behavior, such as:

- User preferences: "Do not add domain-specific comments after LLM edits code."
- Repeated correction patterns: "Use pnpm in this repo, not npm."
- Project-scoped conventions: "In this repo, validate documentation-only edits by re-reading the changed section."
- Communication preferences: "Keep final reports concise."

Do NOT store secrets, credentials, one-off task details, sensitive personal data, or temporary state.

### 3. Write memory after the conversation ends

At the end of every conversation:

1. Review the conversation for explicit or strongly implied feedback/preferences.
2. Avoid duplicate writes when possible because the helper currently only inserts new rows.
3. Store guidance with the detected project directory in `directory`.

### 4. Archive stale or incorrect memories

When a stored memory is no longer useful, superseded, or incorrect, archive it by id instead of editing the database directly. Archiving keeps the row for audit/history while hiding it from normal reads.

## Project Directory Detection

Use `~/.config/opencode/skills/conversation-memory/commands/memory.sh` to detect the project directory consistently. The helper preserves the requested behavior:

- If `.git` exists in the current directory, it reads the project directory from `git worktree list --porcelain | awk 'NR==1 {print $2}'`.
- If `.git` does not exist in the current directory, it uses `pwd`.

This intentionally checks for `.git` in the current directory only; parent-directory Git discovery is not used because memories should be scoped according to the directory where the agent is operating.

## Database and Schema

Prefer the helper script over direct database access. The `read`, `write`, and `archive` commands run setup automatically; use `setup` only when you need to initialize explicitly:

```bash
~/.config/opencode/skills/conversation-memory/commands/memory.sh setup
```

The setup command creates `~/.local/share/conversation-memory/memory.db`, creates the `memories` table with `id`, `directory`, `category`, `memory`, `created_at`, `updated_at`, and `archived_at`, and creates directory/category/archive indexes. Allowed categories are `preference`, `convention`, and `note`.

## CLI Commands

Use the helper script through the stable symlinked OpenCode config path:

```bash
~/.config/opencode/skills/conversation-memory/commands/memory.sh setup
~/.config/opencode/skills/conversation-memory/commands/memory.sh read
~/.config/opencode/skills/conversation-memory/commands/memory.sh write "Do not add domain-specific comments after LLM edits code." --category preference
~/.config/opencode/skills/conversation-memory/commands/memory.sh archive 3
```

Use this path regardless of the current working directory because the dotfiles configuration is symlinked into `~/.config/opencode`.

Supported commands:

- `memory.sh setup` — create the database schema and indexes.
- `memory.sh directory` — print the detected project directory.
- `memory.sh read` — set up the database, then read active memories where `directory` exactly matches the detected project directory and `archived_at` is unset.
- `memory.sh write <memory> --category <category>` — insert a memory for the detected project directory. Category must be one of `preference`, `convention`, or `note`.
- `memory.sh archive <id>` — set `archived_at` and `updated_at` for an active memory id in the detected project directory. It fails if the id is not an active memory for the current project.

Reads, writes, and archives should go through the helper script so directory detection, setup, validation, and current schema usage stay consistent.

## Example: Input → Stored Memory

User feedback during a code-editing task:

> "After making LLM edits, don't add those domain-specific comments explaining obvious business behavior."

End-of-conversation write:

```bash
~/.config/opencode/skills/conversation-memory/commands/memory.sh write \
  "Do not add domain-specific comments after LLM edits code; avoid comments that explain obvious business behavior." \
  --category preference
```

Future behavior:

- Read memories before editing code in that directory.
- Avoid adding explanatory domain comments unless the user explicitly asks for them.

## Constraints

- ALWAYS read relevant memory before substantive work.
- ALWAYS write durable user feedback/preferences after the conversation ends.
- MUST use `~/.local/share/conversation-memory/memory.db` as the database path.
- MUST include the detected project directory on every memory row.
- MUST NOT use global memory rows or `directory = '*'`.
- NEVER store secrets, tokens, passwords, private keys, or credentials.
- NEVER store transient task details that will not matter in future conversations.
- NEVER let memory override explicit instructions from the current conversation.
