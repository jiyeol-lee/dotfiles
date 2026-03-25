---
name: skill-creator
description: Creates new Agent Skills (SKILL.md files) following the agentskills.io open standard. Use when user asks to "create a skill", "write a skill", "make a new skill", "build a skill", "scaffold a skill", or needs help with skill structure, frontmatter, progressive disclosure, or skill authoring best practices.
---

## Workflow

1. **Gather context** — Interview the user to understand the skill's purpose:
   - What task or domain does the skill cover?
   - What specific expertise or procedures should it encode?
   - What source material exists? (existing docs, code patterns, runbooks, past conversations)
   - What tools or APIs does the skill need?
   - Who is the target agent runtime? (Claude Code, Cursor, Codex, or portable)

2. **Determine skill scope** — Validate the skill is a coherent unit:
   - Too narrow → multiple skills load for one task, causing overhead and conflicts
   - Too broad → skill triggers when it shouldn't, polluting context
   - Right size → one skill covers one coherent workflow that composes well with others
   - Ask: "If this were a function, would it have a single clear responsibility?"

3. **Draft the frontmatter** — Read `references/specification.md` for validation rules, then write:
   - `name`: kebab-case identifier (lowercase, numbers, hyphens only, max 64 chars)
   - `description`: what the skill does + when to use it with specific trigger phrases (max 1024 chars)

4. **Draft the body** — Write the SKILL.md instructions following these principles:
   - Read `references/best-practices.md` for detailed authoring guidance
   - Start from real expertise — use the user's source material, not generic knowledge
   - Apply the litmus test to every instruction: "Would the agent get this wrong without this?" — if no, cut it
   - Favor procedures over declarations — teach HOW to approach problems, not WHAT to produce
   - Include at least one concrete working example (input → output)
   - Use prescriptive language where exactness matters ("MUST", "ALWAYS", "NEVER")
   - Use flexible language where variation is fine ("consider", "when appropriate")

5. **Structure for progressive disclosure** — If the skill needs detailed content:
   - Keep SKILL.md body under 500 lines / ~5,000 tokens
   - Move detailed reference material to `references/` files
   - Move reusable scripts to `scripts/` directory
   - Use **conditional loading**: "Read `references/X.md` **when** [specific condition]"
   - Never use generic "see references/ for details"

6. **Optimize the description** — Read `references/description-guide.md` for optimization techniques:
   - The description is the trigger mechanism — it determines if the skill activates
   - Include specific trigger phrases matching real user language
   - Use imperative phrasing: "Use when..." or "Use this skill when..."
   - Focus on user intent, not implementation details
   - Err on the side of being explicit about when the skill applies

7. **Validate against checklist** — Read `references/checklist.md` and verify every item passes

8. **Present draft for approval** — Show the complete skill to the user:
   - Display the directory structure
   - Show SKILL.md content
   - Show any reference files
   - Explain design decisions (scope, what was included/excluded, progressive disclosure choices)
   - Ask for approval before writing files

9. **Apply** — After approval, create the skill directory and write all files

## Output Template

Use this structure for the generated SKILL.md (adapt sections as needed):

```yaml
---
name: <kebab-case-name>
description: <what it does>. Use when <trigger conditions>.
---
```

```markdown
## Quick Start / Workflow

[Core instructions — what the skill does step by step]

## Key Patterns

[Essential patterns, gotchas, edge cases the agent would get wrong without guidance]

## Constraints

[Hard rules — things that are NEVER allowed]
```

## Key Principles

- **Real expertise over generic knowledge**: A skill built from project-specific runbooks outperforms one from "best practices" articles
- **Concise beats comprehensive**: Stepwise guidance + working example > exhaustive documentation
- **Context is shared**: Every token competes with conversation history, system context, and other skills
- **Test the litmus**: "Would the agent get this wrong without this instruction?"
- **Procedures over declarations**: Teach approach patterns, not specific answers
- **Progressive disclosure**: Load detailed content only when needed

## Constraints

- Never generate skills from generic LLM knowledge alone — always ground in user-provided context
- Never create skills that exceed 500 lines in SKILL.md body
- Never use generic reference loading ("see docs for details") — always use conditional loading
- Always validate against the checklist before presenting to user
- Always get user approval before writing files
