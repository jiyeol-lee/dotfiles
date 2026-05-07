# PRD Template

Use this template when synthesizing a PRD from conversation and repository context. Replace bracketed placeholders, remove instructional comments, and keep the final document focused on durable decisions.

```md
# [Feature or Initiative Name]

## Problem Statement

[Describe the user's problem, the current state, who is affected, and why this matters now. Use project vocabulary and relevant metrics when available.]

## Solution

[Describe the proposed outcome from the user's perspective. Explain what changes for users/operators and how success should feel or be observed.]

## Implementation Decisions

[List durable technical decisions that guide implementation. Include major modules/components/interfaces to create or modify, architectural constraints, schema/API contracts, data flows, migrations, and integration points.]

- [Decision 1]
- [Decision 2]
- [Decision 3]

Avoid brittle file paths and long code snippets because they drift quickly. Exception: include a short decision-rich prototype artifact when prose would be less precise, such as a state machine, reducer transition table, schema/type shape, or API contract. Trim it to the important decision, not a working demo.

## Testing Decisions

[Describe the testing strategy. Focus tests on externally observable behavior, stable interfaces, and meaningful outcomes rather than implementation details. Note which modules/interfaces should be tested and cite similar tests or prior art in the codebase when known.]

- [Testing decision 1]
- [Testing decision 2]
- [Relevant prior art]

## Out of Scope

[List adjacent or tempting work that this PRD explicitly excludes. Include deferred phases, unrelated refactors, unsupported platforms, or features that should not be assumed by implementation agents.]

- [Excluded item 1]
- [Excluded item 2]

## Further Notes

[Capture assumptions, open questions that do not block drafting, issue tracker links, rollout notes, observability considerations, or follow-up decisions.]
```
