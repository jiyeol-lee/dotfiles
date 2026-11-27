# <Title>

## Goal

The problem, what this change improves, and how it solves it, in a few short sentences. A reader who stops here knows what the document is about and what the change does.

## Current behavior

What the code does today, verified against each repository's origin/default branch. Then one short paragraph per change to existing behavior: "Today X. With this change, Y."

## Design

### Behavior

What users and systems see.

### Architecture

An ASCII diagram per path with numbered steps, then a table of each step: step, from, to, purpose. The table is the main flow.

### Data model

Each entity and its role.

### Data migration

Explain what existing data changes or moves and the migration phases. State service availability, version compatibility, and the main risks or irreversible boundaries. Summarize cutover conditions and link to each owning repository's Data migration section for detail. Include this summary even for a small, single-repository migration; omit only when no data migration is needed.

### API

Each endpoint's purpose, plus one example of the main call.

### Interactions

One ASCII UML sequence diagram per materially different flow that has a new or changed connection between repositories or with an external service. Omit this section when no connection is new or changed.

Give each participant a column, with time running from top to bottom. Label each arrow with the operation or event and the protocol or transport. Show a response or a failure branch only when it changes the sequence. Each connection's contract, timeouts, retries, and failures go in the Connections section of the repository files that take part.

## Permissions

| Who | Can do what | On which resource |
| --- | ----------- | ----------------- |

People and services both, including public access.

Omit Data model, API, or Permissions when the design does not change it.

## Key decisions and why

| Decision | Why | Trade-off |
| -------- | --- | --------- |

## Open questions

Remove this section when no questions are open.

## Rollout

| Step | Repositories | Why this order |
| ---- | ------------ | -------------- |

For each connection shown in Interactions, ask whether the two sides can run different versions while one deploys before the other. When they cannot, the order between them becomes a step. An infrastructure repository becomes a step when a later step needs its outputs. Why this order says what fails otherwise.

Include required migration phases alongside deployments, with links to the owning repository's Data migration section and the checks that must pass before the next phase.

Under the table, name any feature flag, what it covers and what it does not, and explain how to roll back. Omit this section only when the repositories can release in any order, no feature flag is involved, and no migration requires ordered or gated steps.

## Repositories

| Repository                  | What changes  | Ticket | Depends on |
| --------------------------- | ------------- | ------ | ---------- |
| [repository](repository.md) | One sentence. |        |            |

One row per ticket for every changed repository, infrastructure repositories included.
