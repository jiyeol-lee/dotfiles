---
name: document
description: Creates and maintains project documentation including README files, API docs, changelogs, and architecture docs. Use when user asks to "write a README", "document this project", "update the docs", "create a changelog", "add API documentation", or "generate architecture docs".
---

## Workflow

1. **Discover existing docs** — Glob for `README*`, `CHANGELOG*`, `docs/`, `*.md` to understand what exists
2. **Analyze the project** — Read package.json, pyproject.toml, or equivalent to extract project name, description, dependencies, and scripts
3. **Draft documentation** — Propose content in Draft Mode (default) for user approval
4. **Apply on approval** — Only write files when user explicitly approves or requests Apply Mode

## Modes

- **Draft Mode** (default) — Analyze and propose documentation changes. Return draft content for user review. NEVER write files in this mode.
- **Apply Mode** — Write documentation files after user approval. Only enter this mode when user explicitly says "apply", "write it", "looks good", or similar confirmation.

## Key Patterns

### Project-Specific Discovery

Before writing any documentation, extract real project data:

```
1. Read package.json / pyproject.toml / Cargo.toml for: name, description, scripts, dependencies
2. Read existing README for: current structure, badges, links to preserve
3. Check for: .env.example (document env vars), docker-compose.yml (document containers), Makefile (document targets)
4. Scan src/ entry points for: exported APIs, CLI commands, main modules
```

This grounding step prevents generic documentation — every section should reference actual project artifacts.

### Changelog Entries

Follow [Keep a Changelog](https://keepachangelog.com/) format. Group changes under: Added, Changed, Deprecated, Removed, Fixed, Security. Read `git log` to extract changes since last version tag.

### Architecture Docs

Use ASCII diagrams (not images) for component relationships — they live in version control and render everywhere.

## Example

**User request:** "Document this project"

**Draft Mode output:**

```markdown
## Proposed README.md

Based on package.json analysis:
- Project: `my-api-service`
- Description: REST API for order management
- Scripts: `dev`, `build`, `test`, `lint`
- Key deps: express, prisma, zod

### Proposed structure:

# my-api-service

> REST API for order management

## Quick Start

\`\`\`bash
npm install
cp .env.example .env  # Configure DATABASE_URL
npm run dev
\`\`\`

## Available Scripts

| Script | Description |
|--------|-------------|
| `npm run dev` | Start development server with hot reload |
| `npm run build` | Build for production |
| `npm run test` | Run test suite |
| `npm run lint` | Lint and format check |

## Environment Variables

| Variable | Required | Description |
|----------|----------|-------------|
| `DATABASE_URL` | Yes | PostgreSQL connection string |
| `PORT` | No | Server port (default: 3000) |

---

**Shall I apply this? I can also add API endpoint documentation if you'd like.**
```

## Constraints

- **NEVER** apply changes without user approval in Draft Mode
- **NEVER** include secrets, API keys, or credentials in documentation
- **NEVER** use `sed`/`perl`/`awk`/`tr` for multi-file replacements — use grep + edit
- **NEVER** invent features or endpoints — only document what exists in the codebase
- **ALWAYS** preserve existing badges, links, and custom sections when updating a README
