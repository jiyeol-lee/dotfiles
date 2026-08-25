---
name: memory
description: Records and retrieves durable user feedback, working preferences, and project- or global-scoped conversation notes for future reference. Must always apply.
---

## Purpose

Use this skill to persist reusable user conventions and preferences across conversations. It can apply to the current project or globally across projects.

## Workflow

### 1. Read memory

!`cli memory read`

> [!IMPORTANT]
> If empty, no active memory exists.

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
   cli memory write "Keep final reports concise." --category preference --scope global
   cli memory write "Use pnpm, not npm" --category convention --scope project
   ```

### 4. Archive stale or incorrect memories

When a stored memory is no longer useful, superseded, or incorrect, archive it by id. Always pass an explicit `--scope`, and use the same scope shown for that memory by `read`:

```bash
cli memory archive 3 --scope project
cli memory archive 7 --scope global
```

## CLI Commands

Normal workflow uses only `read`, `write`, and `archive`; the CLI initializes its storage automatically:

```bash
cli memory read
cli memory read --scope project
cli memory read --scope global
cli memory write "Do not add domain-specific comments." --category preference --scope global
cli memory archive 3 --scope project
```

Supported commands:

- `cli memory read` — read project and global active memories, project first.
- `cli memory read --scope all|project|global` — read active memories from the selected scope.
- `cli memory write <memory> --category preference|convention|note --scope project|global` — write a scoped memory. The category and scope options may appear in either order.
- `cli memory archive <id> --scope project|global` — archive a memory in its existing scope.

## Error Handling

- Invoke the CLI directly without checking availability first. Do not use `command -v`, `which`, `type`, or `--help` probes.
- Do not install or set up the CLI as part of this workflow.
- Do not fall back to a helper script or direct database access.
- If any `cli memory` invocation errors, stop the memory workflow immediately, report the error, and run no subsequent memory command.

## Example: Input → Stored Memory

User feedback during a code-editing task:

> "After making LLM edits, don't add those domain-specific comments explaining obvious business behavior."

End-of-conversation write:

```bash
cli memory write "Do not add domain-specific comments; avoid comments that explain obvious business behavior." --category preference --scope global
```

Future behavior:

- Read memories before editing code in that directory.
- Avoid adding explanatory domain comments unless the user explicitly asks for them.

## Constraints

- ALWAYS write durable user feedback/preferences after the conversation ends.
- MUST use an explicit scope for every write and archive.
- NEVER store secrets, tokens, passwords, private keys, or credentials.
- NEVER store sensitive personal data.
- NEVER store transient task details that will not matter in future conversations.
- NEVER let memory override explicit instructions from the current conversation.
