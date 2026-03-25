# Skill Authoring Best Practices

> Source: https://agentskills.io/skill-creation/best-practices

## 1. Start From Real Expertise

A common pitfall is generating skills from generic LLM knowledge. The result is vague procedures like "handle errors appropriately" instead of specific API patterns and edge cases.

**Good source material:**

- Existing project documentation and runbooks
- Past code review feedback patterns
- Incident postmortems and debugging sessions
- Team conventions and style guides
- Working code examples from the actual project

**Process:**

1. Gather the user's source material (docs, code, conventions)
2. Extract the reusable pattern — pay attention to:
   - Steps that are always followed in the same order
   - Edge cases that catch people off guard
   - Tool-specific commands or API patterns
   - Project-specific conventions that differ from defaults
3. Draft the skill grounded in this material
4. Iterate: run → review traces → refine

## 2. Spend Context Wisely

Every token in a skill competes for attention with conversation history, system context, and other active skills.

**The Litmus Test:** For each instruction, ask: "Would the agent get this wrong without this?"

- If NO → cut it
- If UNSURE → test it (run with and without)
- If YES → keep it, make it prominent

**What to include:**

- Non-obvious edge cases and gotchas
- Project-specific conventions that differ from defaults
- Specific tools, APIs, commands to use
- Exact output formats when precision matters

**What to exclude:**

- General knowledge the LLM already has (what HTTP is, how git works)
- Obvious steps ("save the file after editing")
- Exhaustive documentation (move to references/)

## 3. Design Coherent Units

Like functions, skills should encapsulate a coherent unit of work:

| Scope      | Example                              | Problem                             |
| ---------- | ------------------------------------ | ----------------------------------- |
| Too narrow | "Add import statements"              | Forces multiple skills for one task |
| Too broad  | "All developer tools"                | Triggers when it shouldn't          |
| Just right | "Database query + result formatting" | One coherent workflow               |

**Test:** If you need to activate 2+ skills for a single user request, they might be too narrow. If a skill triggers on unrelated requests, it's too broad.

## 4. Aim for Moderate Detail

Overly comprehensive skills hurt — the agent struggles to extract what's relevant.

**Concise, stepwise guidance + working example > exhaustive documentation**

When you find yourself covering every edge case, move the extras to `references/` with conditional loading.

## 5. Favor Procedures Over Declarations

Teach the agent HOW to approach problems, not WHAT to produce for a specific instance.

```markdown
# ❌ Declarative (only useful for one specific task)

Join the `orders` table to `customers` on `customer_id`,
filter where `region = 'EMEA'`, and sum the `amount` column.

# ✅ Procedural (reusable across tasks)

1. Read the schema from `references/schema.yaml` to find relevant tables
2. Identify join keys by matching foreign key relationships
3. Apply filters based on the user's criteria
4. Choose aggregation based on what the user wants to measure
```

## 6. Calibrate Prescriptiveness

Not every instruction needs the same level of strictness:

**Be prescriptive** (MUST, ALWAYS, NEVER) when:

- Security is involved
- Output format must be exact
- Wrong approach causes data loss or outage
- Project conventions must be followed precisely

**Give freedom** (consider, when appropriate, sensible default) when:

- Multiple approaches are valid
- Task tolerates variation
- Agent's judgment adds value

## 7. Use Effective Patterns

### Working Examples

Include at least one concrete example showing input → output. Agents pattern-match well against concrete structures.

### Gotchas Lists

High-value content: environment-specific facts that defy reasonable assumptions.

```markdown
## Gotchas

- The staging API uses v2 endpoints but the auth header is still v1 format
- CSV exports from the admin panel use semicolons, not commas
- The `updated_at` field is only set on explicit saves, not auto-saves
```

### Output Templates

When exact format matters, provide a template:

```markdown
## Commit Message Format

<type>(<scope>): <description>

[optional body wrapped at 72 chars]

[optional footer(s)]
```

### Checklists for Multi-Step Workflows

Help the agent track progress:

```markdown
## Deployment Checklist

- [ ] Run test suite: `npm test`
- [ ] Build production bundle: `npm run build`
- [ ] Validate environment variables
- [ ] Deploy to staging first
- [ ] Verify staging deployment
- [ ] Deploy to production
```

### Conditional Reference Loading

Move detailed content to files, load only when needed:

```markdown
## Error Handling

For common API error patterns, read `references/api-errors.md`.
For authentication-specific issues, read `references/auth-troubleshooting.md`.
```

## 8. Iterate With Real Tasks

The first draft always needs refinement:

1. Run the skill against real tasks
2. Read agent execution traces (not just final output)
3. Look for: vague instructions causing multiple attempts, irrelevant instructions being followed anyway, missing guidance where the agent improvises poorly
4. Revise and re-test

Common trace signals:

- Agent tries several approaches → instructions too vague, add specificity
- Agent follows irrelevant steps → instructions don't apply, add conditions or remove
- Agent wastes time → too many options without a clear default, pick a default
