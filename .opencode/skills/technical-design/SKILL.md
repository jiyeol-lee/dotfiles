---
name: technical-design
description: Use when writing or reviewing a technical design document, also called a design doc, tech spec, or engineering spec.
---

# Technical design document

This document describes how to solve the business problem in technical terms. Other software engineers read it to review the design, and the author reads it to build the feature. The `README.md` gives the whole design, high level and clear. Each changed repository has its own file with that repository's detail.

## Writing style

Load the `documentation-writing` skill and follow its writing style. The templates below apply it: every file opens with what matters most, the README gives the whole design at a high level, and each repository file stands alone, understandable without the README.

## Folder structure

```text
<ticket>/technical_design/
├── README.md             # high level for the whole design
├── <repository>.md       # detail for one changed repository, application or infrastructure
└── decisions/
    └── <topic>.md        # the alternatives compared for one major decision
```

Give every changed repository its own file, infrastructure repositories included. An application repository that owns its infrastructure describes it in its own file, under `## Infrastructure`.

## Where each fact lives

The README and each repository file stand alone.

- The README gives the whole design at a high level, including changes within a single repository, understandable without opening any other file. It links to repository files for depth.
- A repository file gives one repository's part, understandable without the README or another repository file. It states the context that repository needs, such as what calls it, what it calls, and the cross-repository decisions that shape it, in a sentence or two each. It does not retell the README's design.
- The repository that defines a contract holds its full detail, such as payloads, status codes, and record shapes. A repository that uses the contract restates the parts it uses and links to the owner for the rest.

Link between files for deeper detail, never for something needed to understand the file that links.

```markdown
<!-- Do: README -->

An order stays PENDING until its payment check finishes, and the customer sees the result without reloading.

<!-- Not: README -->

The worker sets the order status before it publishes `ORDER-UPDATED` to the `customer:{customer_id}` room.
```

| Topic          | README                                                         | Repository file                                                 |
| -------------- | -------------------------------------------------------------- | --------------------------------------------------------------- |
| Behavior       | What users and systems see                                     | The rules behind it                                             |
| Flow           | The main steps across repositories, in the Architecture table  | Internal runtime paths, failures, retries, and edge cases       |
| Interactions   | New or changed connections, with mechanism, owner, and failure | Each connection's contract, timeouts, and retries               |
| Data model     | Each entity and its role                                       | Fields, constraints, states                                     |
| Data migration | Existing data changes, service impact, and migration phases    | Transformation, backfill, compatibility, verification, rollback |
| API            | Each endpoint's purpose, plus one example of the main call     | All requests, responses, and status codes, in Connections       |
| Permissions    | Who can do what on which resource, people and services         | The checks and policies that enforce it                         |
| Infrastructure | Each new resource, in the Repositories table                   | Each resource, its settings, and why                            |
| Program layout | Not covered                                                    | Changed files and necessary existing context                    |
| Tests          | Not covered                                                    | Planned test files and the behavior each must prove             |

## Writing rules

- Keep each table cell to one sentence. When a cell needs more, write prose under the table.
- Use one term for each idea in every file.
- Draw diagrams in ASCII.
- Omit a field or section that is not known yet instead of writing a placeholder such as TBD.

## README template

The README explains the goal, proposed behavior, architecture and infrastructure, data changes and migration, main risks, and rollout without opening repository files. Every section stays high level.

[README template](./references/readme.md)

The README links every other file: repository files from Repositories, and decision files from Key decisions and why.

## Repository file template

Keep repository files self-contained, understandable without browsing source. Add the detail this repository needs beyond the README's high level, enough to review and build it, not a line-by-line account of the code. In both repository templates, omit sections that do not apply.

[Repository file template](./references/repository.md)

## Infrastructure repository file template

[Infrastructure repository file template](./references/infrastructure.md)

## Decision file template

[Decision file template](./references/decision.md)

A decision file is the only place a design document compares alternatives. Link it from the matching row in Key decisions and why. Every alternative the file argues against is one of its options. Why option N compares the chosen option with the others instead of repeating its pros.

## Target design, not edit steps

Describe target behavior and structure, not an edit checklist. Keep design names such as models, fields, statuses, endpoints, and queues. Use file paths in Program layout and test-file headings. Runtime diagrams may label files to connect the flow to the layout. Leave out line numbers, class-placement details, and step-by-step edit lists.

Do not include source code, language-specific type declarations or method signatures, dependency-injection wiring code, executable tests, or framework-shaped skeletons. Contract and payload examples may still show fields and endpoints.

```markdown
<!-- Do -->

Create order runs in one transaction. It returns 409 if the cart is locked, inserts the order as PENDING, and queues the payment check.

<!-- Not -->

Add `OrderCreateView` to `src/orders/views/order_create.py`, register it in `src/orders/urls.py`, and update `src/orders/serializers/__init__.py`.
```

## No refinement log

The technical design documentation guideline applies to design documents: describe the target design, not how it was reached. The `[+]`, `[~]`, and `[-]` markers in Program layout and Tests record planned scope, not refinement history. Brief removal or replacement explanations are allowed there. Outside decision files, a design document also leaves out:

- denials of designs that were considered and rejected
- "future" or "out of scope" notes for ideas that were discussed and dropped

```markdown
<!-- Do -->

The orders service queues the payment check when it creates an order, so a cart that is never checked out is never charged.

<!-- Not -->

The cart no longer triggers a payment check. Requests no longer carry a region id. Partial refunds are out of scope for now and can come later.
```

## Key decisions

Do record only decisions that span repositories or that a reviewer of the whole design would question, with the reason that makes each one right. A choice that affects one repository goes in that repository file's Design, with its reason. Do not record choices that have no real alternative, the order in which things were decided, or who decided.

Risks go in the Trade-off column: each risk is the cost of a decision, stated with its mitigation. Leave the cell empty when a decision accepts no trade-off.

```markdown
<!-- Do -->

| Decision                           | Why                                                                                                                                   | Trade-off                                                           |
| ---------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------- |
| Payment check in a separate worker | Failed checks retry on their own, away from API load, as [decisions/payment-check.md](decisions/payment-check.md) compares in detail. | The order shows PENDING for a few seconds until the check finishes. |

<!-- Not -->

| Decision                             | Why                                     | Trade-off |
| ------------------------------------ | --------------------------------------- | --------- |
| Switched from a cron job to a worker | Decided on 2026-03-02 after discussion. |           |
| PostgreSQL for order storage         | The owner chose it.                     |           |
```
