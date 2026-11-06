# Engineering spec conventions

## Folder structure

Do keep the high level in the README and the detail in one file per changed repository, with one file per major decision. When infrastructure changes, `infrastructure.md` gives the high level for infrastructure, and each infrastructure repository still gets its own file. Do not put every detail in a single file.

```text
<ticket>/engineering_spec/
├── README.md             # high level for the whole design
├── infrastructure.md     # high level for infrastructure, when any infrastructure repository changes
├── <repository>.md       # detail for one changed repository, application or infrastructure
└── decisions/
    └── <topic>.md        # the alternatives compared for one major decision
```

## README and repository files

Do keep the README at the level of where the design is going and why, and put how each repository gets there in its repository file. Link the repository file instead of repeating its detail in the README.

| Topic      | README                                                     | Repository file                           |
| ---------- | ---------------------------------------------------------- | ----------------------------------------- |
| Behavior   | What users and systems see                                 | The rules behind it                       |
| Flow       | The main steps across repositories                         | Edge cases, failures, retries             |
| Data model | Each entity and its role                                   | Fields, constraints, states               |
| API        | Each endpoint's purpose, plus one example of the main call | All requests, responses, and status codes |
| Tests      | Not covered                                                | What tests must prove                     |

`infrastructure.md` sits between the README and the infrastructure repository files. It shows which resources exist, how they connect, which repository owns each, and who can access what. Each infrastructure repository's file holds that repository's resource settings and the reason for each. The README links `infrastructure.md` instead of describing resources in detail.

## README template

```markdown
# <Title>

## Goal

What the change achieves and why.

## Current behavior

What the code does today, verified against each repository's main branch.

## Propose

One short paragraph per change to existing behavior: "Today X. With this change, Y." Omit it for new behavior.

### Behavior

### Architecture

An ASCII diagram, then a table of each step: from, to, purpose.

### Flow

### Data model

### API

### Permissions

Who can read and who can write each resource.

## Open questions

Remove this section when no questions are open.

## Key decisions and why

| Decision | Why | Trade-off |
| -------- | --- | --------- |

## Tickets

| Ticket | Repository | Depends on |
| ------ | ---------- | ---------- |

## Documents

Link every spec file except `README.md`, including each repository file, `infrastructure.md` when present, and every file under `decisions/`. Replace the example rows with actual files, using paths relative to `README.md`, document names as link text, and brief scope descriptions.

| Document                             | Covers                                           |
| ------------------------------------ | ------------------------------------------------ |
| [Infrastructure](infrastructure.md)  | Resources, connections, ownership, and access.   |
| [Repository name](repository.md)     | This repository's design, tests, and tickets.    |
| [Decision topic](decisions/topic.md) | Alternatives, the chosen option, and trade-offs. |
```

## Repository file template

```markdown
# <repository>

Back to [README.md](README.md).

## Responsibility

What this repository is responsible for in this design.

## Design

The behavior, rules, data shapes, and interfaces it exposes or calls. For an infrastructure repository: each resource, its settings, and why.

## Tests

What tests must prove, as behavior.

## Tickets

| Ticket | Scope |
| ------ | ----- |
```

## Infrastructure template

```markdown
# Infrastructure

Back to [README.md](README.md).

## Goal

What the infrastructure must provide for the design, and why.

## Resources

| Resource | Purpose | Repository |
| -------- | ------- | ---------- |

## Architecture

An ASCII diagram of the resources and the services that use them, then a table of each connection: from, to, purpose.

## Access

| Who | Can do what | On which resource |
| --- | ----------- | ----------------- |
```

Tickets for infrastructure repositories go in the README's Tickets table and in each repository file, as for any repository.

## Decision file template

```markdown
# <Decision topic>

Back to [README.md](../README.md).

## Question

## Options

### Option 1: <name>

An ASCII diagram, pros, and cons. One subsection per option, numbered from 1.

## Comparison

A table comparing the options.

## Why option <N>

## Trade-offs accepted
```

A decision file is the only place a spec compares alternatives. Link it from the matching row in Key decisions and why.

## Behavior, not code changes

Do describe behavior, rules, and interfaces, not where or what to edit. Keep design names such as models, fields, statuses, endpoints, and queues. Leave out file paths, line numbers, class placement, and step-by-step edit lists.

```markdown
<!-- Do -->

Create order runs in one transaction. It returns 409 if the cart is locked, inserts the order as PENDING, and queues the payment check.

<!-- Not -->

Add `OrderCreateView` to `src/orders/views/order_create.py`, register it in `src/orders/urls.py`, and update `src/orders/serializers/__init__.py`.
```

## No refinement log

The Documentation guideline in SKILL.md applies to specs: describe the target design, not how it was reached. Outside decision files, a spec also leaves out:

- denials of designs that were considered and rejected
- "future" or "out of scope" notes for ideas that were discussed and dropped

```markdown
<!-- Do -->

The orders service queues the payment check when it creates an order, so a cart that is never checked out is never charged.

<!-- Not -->

The cart no longer triggers a payment check. Requests no longer carry a region id. Partial refunds are out of scope for now and can come later.
```

## Key decisions

Do record only choices a reviewer would question, with the reason that makes each one right. Do not record choices that have no real alternative, the order in which things were decided, or who decided.

Risks go in the Trade-off column: each risk is the cost of a decision, stated with its mitigation. Leave the cell empty when a decision accepts no trade-off.

```markdown
<!-- Do -->

| Decision                           | Why                                                                                                                         | Trade-off                                                                        |
| ---------------------------------- | --------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------- |
| Payment check in a separate worker | Isolated from API load, and failed checks retry on their own. See [decisions/payment-check.md](decisions/payment-check.md). | A check can lag the order by seconds; the order shows PENDING until it finishes. |

<!-- Not -->

| Decision                             | Why                                     | Trade-off |
| ------------------------------------ | --------------------------------------- | --------- |
| Switched from a cron job to a worker | Decided on 2026-03-02 after discussion. |           |
| PostgreSQL for order storage         | The owner chose it.                     |           |
```
