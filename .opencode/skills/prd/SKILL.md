---
name: prd
description: Synthesizes Product Requirements Documents from the current conversation and repository context. Use when user asks to "write a PRD", "create a product requirements document", "turn this into a PRD", "draft requirements", "create a spec", or publish product requirements to an issue tracker.
---

## Workflow

1. **Synthesize first, interview only for blockers** — Use the current conversation, prior decisions, and visible codebase context as the source of truth. Ask follow-up questions only when missing information would change the PRD's core direction or create unsafe assumptions.
2. **Ground the PRD in the repository** — Explore enough of the repo to understand the feature's current state before writing:
   - Look for related code, configuration, existing docs, issue templates, and product specs.
   - Use the project's domain vocabulary and glossary terms when they exist.
   - Respect relevant notes, and established patterns in the area being changed.
3. **Map the implementation shape** — Identify the major modules, components, APIs, schemas, jobs, or interfaces likely to be created or changed. Prefer **deep modules**: small, stable, testable interfaces that encapsulate meaningful behavior and avoid leaking implementation details.
4. **Capture decisions, not transient details** — Read `references/template.md` when drafting the PRD. Fill it with product-facing problem/solution context plus implementation and testing decisions. Avoid brittle file paths and code snippets unless a short prototype artifact captures a decision more clearly than prose, such as a state machine, schema shape, reducer, or API contract.
5. **Define testing strategy by external behavior** — Specify which modules or interfaces need tests, what good tests should assert, and where similar tests already exist. Prefer tests of externally observable behavior over implementation details.
6. **Publish only when the workflow supports it** — If the user asks to create or publish an issue and the repository exposes an issue tracker workflow, create or update the issue using the project's existing templates and label vocabulary. Apply a readiness or triage label only when that vocabulary is present in the project context; never invent labels or rely on unrelated setup commands.
7. **Report the result** — Summarize the PRD created or issue published, the key implementation/testing decisions captured, and any assumptions that need later confirmation.

## Key Patterns

- Treat the PRD as a synthesis artifact: convert conversation context and repo understanding into a clear plan instead of re-asking everything.
- Use project language over generic product language; if the codebase calls a concept a "workspace", do not rename it to "organization" in the PRD.
- Separate durable decisions from implementation guesses. Module boundaries, API contracts, schema shapes, and test strategy belong in the PRD; temporary file locations usually do not.

## Example

User request: "Turn our discussion about saved search filters into a PRD and open an issue if this project supports it."

```md
## Problem Statement

Users repeatedly rebuild the same search filters across sessions, which slows down common workflows and increases the chance of inconsistent results.

## Solution

Add saved search filters so users can name, reuse, update, and delete frequently used filter sets from the search experience.

## Implementation Decisions

- Add a saved-filter module with a stable interface for creating, listing, applying, updating, and deleting filter definitions.
- Keep filter serialization and validation behind that module so the UI and persistence layer do not duplicate filter rules.
- Reuse the existing search execution boundary; applying a saved filter should produce the same query behavior as manually selecting those filters.

## Testing Decisions

- Test behavior through visible saved-filter outcomes: creation, reuse, update, deletion, validation errors, and applied search results.
- Prefer module-level tests around the saved-filter interface plus integration coverage at the search boundary; avoid asserting internal storage details.
- Use existing search/filter tests as prior art when present.

## Out of Scope

- Sharing saved filters between users.
- Advanced permission controls for saved filters.
- Redesigning the underlying search query engine.

## Further Notes

- Assumption: the current filter vocabulary and validation rules remain the source of truth.
- If an issue tracker and accepted readiness labels exist, publish this PRD there; otherwise return the Markdown PRD for the user to place manually.
```

## Constraints

- **NEVER** add persona-based narrative requirement lists unless the user explicitly asks for them.
- **NEVER** conduct a long interview when the conversation and repo already provide enough context.
- **NEVER** invent issue tracker labels, triage vocabulary, or setup commands.
- **NEVER** include fragile file-path inventories or full code samples as implementation decisions.
- **ALWAYS** include implementation decisions, testing decisions, and explicit out-of-scope boundaries.
- **ALWAYS** call out assumptions when the PRD depends on inferred context.
