# Optimizing Skill Descriptions

> Source: https://agentskills.io/skill-creation/optimizing-descriptions

## Why Descriptions Matter

The `description` field is the PRIMARY mechanism agents use to decide whether to activate a skill. An under-specified description means the skill won't trigger when it should; an over-broad description means it triggers when it shouldn't.

At startup, agents load ONLY the `name` and `description` of each skill (~100 tokens per skill). This is ALL the agent has to decide relevance.

## Description Anatomy

**Pattern:** `[What the skill does] + [When to use it]`

```yaml
# Structure
description: >
  [1-2 sentences: what the skill does].
  Use when [trigger conditions with specific phrases].
```

## Writing Effective Descriptions

### Use Imperative Phrasing

Frame as an instruction to the agent:

```yaml
# ✅ Good
description: Use this skill when the user asks to create a README...

# ❌ Bad
description: This is a skill that can help with README files...
```

### Focus on User Intent

Describe what the user is trying to achieve, not implementation:

```yaml
# ✅ Good — user intent
description: ...Use when user asks to "review my code", "check for bugs", or "is this safe to merge"

# ❌ Bad — implementation detail
description: ...Use when AST parsing and static analysis are needed
```

### Include Specific Trigger Phrases

List the actual phrases users say:

```yaml
# ✅ Good — specific triggers
description: Creates git commits following Conventional Commits. Use when user asks to "commit changes", "write a commit message", "stage and commit", or "prepare a commit".

# ❌ Bad — no triggers
description: Handles git operations.
```

### Be Explicit About Scope

Include cases where the skill applies, even if they seem obvious:

```yaml
description: >
  Writes and runs end-to-end tests using Playwright. Use when creating
  E2E test suites, validating user flows, debugging test failures,
  or when user asks to "test the login flow", "add browser tests",
  or "check if the signup works".
```

### Err on the Side of Being Pushy

Explicitly list contexts where the skill applies:

```yaml
description: >
  ...Use when working with PDF files, converting PDF to text,
  filling out PDF forms, merging PDFs, or ANY task involving
  .pdf files.
```

## Common Mistakes

| Mistake                | Example                        | Fix                                             |
| ---------------------- | ------------------------------ | ----------------------------------------------- |
| Too vague              | "Helps with code"              | Specify WHAT code tasks and WHEN                |
| No trigger phrases     | "Database management tool"     | Add "Use when..." with user phrases             |
| Implementation-focused | "Runs ESLint and Prettier"     | Focus on user intent: "check code quality"      |
| Too long               | 3 paragraphs                   | Keep to 2-4 sentences, max 1024 chars           |
| Missing "Use when"     | "Creates READMEs for projects" | Add "Use when user asks to 'write a README'..." |

## Testing Trigger Accuracy

After writing a description, mentally test with these prompts:

1. **Should trigger:** Write 3-5 prompts where this skill SHOULD activate
2. **Should NOT trigger:** Write 3-5 prompts where this skill should NOT activate
3. Adjust description if any case fails

**Example for a code-review skill:**

```
Should trigger:
- "Review this PR for me"
- "Can you check my code for bugs?"
- "Is this safe to merge?"

Should NOT trigger:
- "Write a function to sort an array"
- "Help me deploy to production"
- "Create a new React component"
```
