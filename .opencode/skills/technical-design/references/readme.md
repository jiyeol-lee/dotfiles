# <Title>

## Summary

Up to 5 bullets: what changes and for whom, how it works in one sentence, and the biggest risk. A reader who stops here can explain the change to a teammate.

## Goal

What the change achieves and why.

## Current behavior

What the code does today, verified against each repository's main branch. Then one short paragraph per change to existing behavior: "Today X. With this change, Y."

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

Use one ASCII UML sequence diagram per materially different flow involving new or changed connections between repositories or with an external service. Omit this section when no connection is new or changed.

Give each participant a column, with time running from top to bottom. Number arrows consecutively across all diagrams in Interactions (`<1>`, `<2>`, ...) and label each with the operation or event and the protocol or transport. Show responses, acknowledgements, and important failure or retry branches when they affect the sequence.

Immediately below each diagram, before the next diagram, use a matching `#### <number> <sender> to <receiver>` subsection for each arrow in diagram order, with short bullets covering:

- Whether the connection is synchronous or asynchronous, and its delivery guarantee.
- The contract owner, linked to the repository file section that defines the contract's detail.
- What the caller sees when the connection fails.
- Links to the Connections section of each repository that enforces the connection's timeouts, attempts, and retries.

Describe each connection once across its request, response, or acknowledgement subsections. When another flow reuses a connection, refer to its arrow number instead of repeating it.

Along a chain of synchronous calls, each caller waits longer than everything it calls, attempts included. When it does not, add it to Open questions.

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
