---
name: conversation-memory
description: Records and retrieves durable user feedback, working preferences, and project- or global-scoped conversation notes for future reference. Use when a conversation starts or ends, when user says preferences such as "remember", "don't do that", "next time", "always", or "never", and before applying future work in a directory.
---

## Purpose

Use this skill to persist reusable user conventions and preferences across conversations. The memory database is SQLite at `$XDG_DATA_HOME/conversation-memory/memory.db`, and can apply to the current project or globally across projects.

## Workflow

### 1. Read memory first

At the start of a conversation or before doing substantive work:

1. Run `conversation-memory read` to read active project and global memories.
2. Apply relevant memories silently. Project memories appear before global memories, and explicit instructions in the current conversation always override memory.

### 2. Capture memory-worthy feedback during the conversation

Store only durable guidance that should affect future behavior, such as:

- User preferences: "Do not add domain-specific comments."
- Repeated correction patterns: "Use pnpm, not npm."
- Project-scoped conventions: "Validate documentation-only edits by re-reading the changed section."
- Communication preferences: "Keep final reports concise."

Do NOT store secrets, credentials, one-off task details, sensitive personal data, or temporary state.

### 3. Write memory after the conversation ends

At the end of every conversation:

1. Review the conversation for explicit or strongly implied feedback/preferences.
2. Avoid duplicate writes by checking the memories already read.
3. Choose the scope deliberately:
   - Use `global` for durable preferences that should apply across projects.
   - Use `project` for repository-specific guidance.
   - Prefer `project` when uncertain.
4. Write with an explicit category and scope:

   ```bash
   conversation-memory write "Keep final reports concise." --category preference --scope global
   conversation-memory write "Use pnpm, not npm" --category convention --scope project
   ```

### 4. Archive stale or incorrect memories

When a stored memory is no longer useful, superseded, or incorrect, archive it by id. Always pass an explicit `--scope`, and use the same scope shown for that memory by `read`:

```bash
conversation-memory archive 3 --scope project
conversation-memory archive 7 --scope global
```

## CLI Commands

Normal workflow uses only `read`, `write`, and `archive`; the CLI initializes its storage automatically:

```bash
conversation-memory read
conversation-memory read --scope project
conversation-memory read --scope global
conversation-memory write "Do not add domain-specific comments." --category preference --scope global
conversation-memory archive 3 --scope project
```

Supported commands:

- `conversation-memory read` — read project and global active memories, project first.
- `conversation-memory read --scope all|project|global` — read active memories from the selected scope.
- `conversation-memory write <memory> --category preference|convention|note --scope project|global` — write a scoped memory. The category and scope options may appear in either order.
- `conversation-memory archive <id> --scope project|global` — archive a memory in its existing scope.

## Error Handling

- Invoke the CLI directly without checking availability first. Do not use `command -v`, `which`, `type`, or `--help` probes.
- Do not install or set up the CLI as part of this workflow.
- Do not fall back to a helper script or direct database access.
- If any `conversation-memory` invocation errors, stop the memory workflow immediately, report the error, and run no subsequent memory command.

## Example: Input → Stored Memory

User feedback during a code-editing task:

> "After making LLM edits, don't add those domain-specific comments explaining obvious business behavior."

End-of-conversation write:

```bash
conversation-memory write "Do not add domain-specific comments; avoid comments that explain obvious business behavior." --category preference --scope global
```

Future behavior:

- Read memories before editing code in that directory.
- Avoid adding explanatory domain comments unless the user explicitly asks for them.

## Constraints

- ALWAYS read relevant memory before substantive work.
- ALWAYS write durable user feedback/preferences after the conversation ends.
- MUST use an explicit scope for every write and archive.
- NEVER store secrets, tokens, passwords, private keys, or credentials.
- NEVER store sensitive personal data.
- NEVER store transient task details that will not matter in future conversations.
- NEVER let memory override explicit instructions from the current conversation.
