# Agent Skills Specification Reference

> Source: https://agentskills.io/specification

## Directory Structure

```
skill-name/
├── SKILL.md          # Required: metadata + instructions
├── scripts/          # Optional: executable code
├── references/       # Optional: documentation
├── assets/           # Optional: templates, resources
└── ...               # Any additional files or directories
```

## SKILL.md Format

The SKILL.md file MUST contain YAML frontmatter followed by Markdown content.

### Required Frontmatter Fields

| Field         | Required | Rules |
|---------------|----------|-------|
| `name`        | Yes      | Max 64 chars. Lowercase letters, numbers, hyphens only. Must not start/end with hyphen. No consecutive hyphens (`--`). No XML tags. Must not contain "anthropic" or "claude". |
| `description` | Yes      | Max 1024 chars. Non-empty. No XML tags. Describes what the skill does AND when to use it. |

### Optional Frontmatter Fields

| Field           | Purpose |
|-----------------|---------|
| `license`       | License identifier or filename (e.g., `Apache-2.0`) |
| `compatibility` | Runtime requirements (e.g., `Requires Python 3.14+ and uv`) |
| `metadata`      | Map of string key-value pairs for custom properties |
| `allowed-tools` | Pre-approved tools the agent can use without prompting (e.g., `Bash(git:*) Read`) |

### Name Validation Rules

```
✅ Valid names:
  pdf-processing
  code-review
  my-skill-v2
  e2e-test-runner

❌ Invalid names:
  -pdf              (starts with hyphen)
  pdf-              (ends with hyphen)
  pdf--processing   (consecutive hyphens)
  PDF_Processing    (uppercase, underscores)
  skill__code       (underscores not allowed)
  my.skill          (dots not allowed)
  claude-helper     (reserved word "claude")
```

### Description Format

The description serves as the **trigger condition** for skill activation. Agents read ONLY the name and description at startup (~100 tokens per skill) to decide relevance.

**Pattern:** `[What the skill does] + [When to use it, with specific trigger phrases]`

**Examples:**
```yaml
# Good — specific, includes trigger phrases
description: Creates and writes professional README.md files for software projects. Use when user asks to "write a README", "create a readme", "document this project", or "generate project documentation".

# Good — domain-specific with clear scope  
description: Extract PDF text, fill forms, merge files. Use when handling PDFs, converting PDF to text, or filling out PDF forms programmatically.

# Bad — too vague
description: Helps with code.

# Bad — no trigger conditions
description: A tool for managing databases.
```

## Progressive Disclosure (3-Level Loading)

```
Level 1: Discovery (~100 tokens per skill)
├── Loaded: name + description from frontmatter
├── When: Agent startup, for ALL installed skills
└── Purpose: Decide which skills are relevant

Level 2: Instructions (< 5,000 tokens recommended)
├── Loaded: Full SKILL.md body (markdown content)
├── When: Task matches skill's description
└── Purpose: Core instructions for the task

Level 3: Resources (as needed, unlimited)
├── Loaded: Files from scripts/, references/, assets/
├── When: Agent needs specific detailed information
└── Purpose: Detailed reference, executable code, templates
```

### Conditional Loading Pattern

```markdown
# ✅ Good — conditional loading with specific trigger
Read `references/api-errors.md` if the API returns a non-200 status code.

# ✅ Good — conditional loading for specific step
For selector priority when writing tests, read `references/selectors.md`.

# ❌ Bad — generic reference
See references/ for details.

# ❌ Bad — unconditional loading
Read all files in references/ before starting.
```

## Body Content

No format restrictions. Recommended sections:
- Step-by-step instructions
- Examples of inputs and outputs
- Common edge cases
- Tool usage patterns
- Constraints and guardrails

## Token Budgets

- SKILL.md body: Under 500 lines, under ~5,000 tokens
- If exceeding, split into reference files
- Each reference file: loaded on-demand, no hard limit but keep focused
