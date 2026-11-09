# Technical design document

A technical design document describes one change across repositories. Other engineers read it to review the design, and the author reads it to build the change. The README gives the whole design, concise and high level, most important first. Each changed repository has its own file with that repository's detail.

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

The README summarizes what crosses repositories, and each repository file holds that repository's detail. State each detail once, in the file of the repository that owns or enforces it, and link to it from other files. A contract's detail, such as payloads, status codes, and record shapes, lives in the file of the repository that defines it.

```markdown
<!-- Do: README -->

An order stays PENDING until its payment check finishes, and the customer sees the result without reloading.

<!-- Not: README -->

The worker sets the order status before it publishes `ORDER-UPDATED` to the `customer:{customer_id}` room.
```

| Topic          | README                                                         | Repository file                                           |
| -------------- | -------------------------------------------------------------- | --------------------------------------------------------- |
| Behavior       | What users and systems see                                     | The rules behind it                                       |
| Flow           | The main steps across repositories, in the Architecture table  | Internal runtime paths, failures, retries, and edge cases |
| Interactions   | New or changed connections, with mechanism, owner, and failure | The contract's detail, in the owner's file                |
| Data model     | Each entity and its role                                       | Fields, constraints, states                               |
| API            | Each endpoint's purpose, plus one example of the main call     | All requests, responses, and status codes                 |
| Permissions    | Who can do what on which resource, people and services         | The checks and policies that enforce it                   |
| Infrastructure | Each new resource, in the Repositories table                   | Each resource, its settings, and why                      |
| Program layout | Not covered                                                    | Changed files and necessary existing context              |
| Tests          | Not covered                                                    | Planned test files and the behavior each must prove       |

## Writing rules

- Keep each table cell to one sentence. When a cell needs more, write prose under the table.
- Use one term for each idea in every file.
- Draw diagrams in ASCII.
- Omit a field or section that is not known yet instead of writing a placeholder such as TBD.

## README template

Every README section stays high level, Data model, API, and Permissions included. A reviewer who reads through Architecture knows what changes, how it works, and what it risks.

```markdown
# <Title>

## Summary

Up to 5 bullets: what changes and for whom, how it works in one sentence, and the biggest risk. A reader who stops here can explain the change to a teammate.

## Repositories

| Repository                  | What changes  | Ticket | Depends on |
| --------------------------- | ------------- | ------ | ---------- |
| [repository](repository.md) | One sentence. |        |            |

One row per ticket for every changed repository, infrastructure repositories included.

## Goal

What the change achieves and why.

## Current behavior

What the code does today, verified against each repository's main branch. Then one short paragraph per change to existing behavior: "Today X. With this change, Y."

## Design

### Behavior

What users and systems see.

### Architecture

An ASCII diagram per path with numbered steps, then a table of each step: step, from, to, purpose. The table is the main flow.

### Interactions

| Interaction | Mechanism | Contract owner | When it fails |
| ----------- | --------- | -------------- | ------------- |

One row per new or changed connection between repositories or with an external service. Omit this section when no connection is new or changed.

Mechanism names sync or async and the delivery guarantee, plus:

- For a synchronous call, the timeout and the number of attempts, such as "HTTP, sync, 10 s timeout, 3 attempts". The caller's repository file links here for those numbers. Along a chain of synchronous calls, each caller waits longer than everything it calls, attempts included. When it does not, add it to Open questions.
- For an asynchronous connection, the id both sides log, so one request can be followed across them, such as "SQS, async, at least once, `order_id`".

## Key decisions and why

| Decision | Why | Trade-off |
| -------- | --- | --------- |

## Open questions

Remove this section when no questions are open.

## Rollout

| Step | Repositories | Why this order |
| ---- | ------------ | -------------- |

For each Interactions row, ask whether the two sides can run different versions while one deploys before the other. When they cannot, the order between them becomes a step. An infrastructure repository becomes a step when a later step needs its outputs. Why this order says what fails otherwise.

Under the table, name the feature flag, what it covers and what it does not, and how to roll back. Omit this section when the repositories can release in any order and no feature flag is involved.

## Data model

Each entity and its role.

## API

Each endpoint's purpose, plus one example of the main call.

## Permissions

| Who | Can do what | On which resource |
| --- | ----------- | ----------------- |

People and services both, including public access.

Omit Data model, API, or Permissions when the design does not change it.
```

The README links every other file: repository files from Repositories, and decision files from Key decisions and why.

## Repository file template

Keep repository files concise and self-contained, understandable without browsing source. In both repository templates, omit sections that do not apply.

````markdown
# <repository>

Back to [README.md](README.md).

## Design

### Behavior

The behavior and rules first, then the data shapes, the contracts it owns, and links to the contracts it calls. A choice that affects only this repository states its reason here.

### Program layout

Show changed files and the existing context needed to understand them. Use indentation only, without tree connectors. Mark changes relative to the repository's main branch: `[+]` added, `[~]` updated, `[-]` deleted, and unmarked existing context. Put a one-line purpose or change explanation after `#` on the same line as each filename.

```text
src/
  feature/
    [+] handler.ext       # Handle the new request path
    [~] storage.ext       # Save the new state
    [-] legacy.ext        # Replaced by handler.ext
    contract.ext          # Existing request contract
tests/
  [+] <new-file>          # Cover the new behavior
  [~] <existing-file>     # Cover changed expectations
```

### Runtime flow

Use a plain-language ASCII diagram for each materially different runtime path. Name files only when that helps connect the flow to Program layout. Show important decisions, failure branches, and transaction boundaries where relevant. Do not list functions or walk through source code.

## Tests

Group planned tests by file, not in a table or framework syntax. Each file heading includes a repository-relative path and a `[+]`, `[~]`, or `[-]` marker, using the same main-branch baseline as Program layout. Give each file one short approach note, explaining real or replaced dependencies when meaningful.

Use natural-language bullets for scenarios, each with a change marker, a concise behavior label, the setup, and the observable expected result. File and scenario markers are independent. Include only markers that apply. Updated cases state the target expectation. Removed cases explain the obsolete expectation or where coverage moves. Add short `input -> action -> result` text pseudocode only where useful.

### [+] tests/<new-file>

Approach: <How the file checks behavior, including real or replaced dependencies when meaningful.>

- [+] <Behavior label>. Given <setup>, <action> produces <observable result>.

Optional pseudocode for a case:

```text
<input> -> <action> -> <observable result>
```

### [~] tests/<existing-file>

Approach: <One short note on how the file checks behavior.>

- [+] <Added behavior>. Given <setup>, <action> produces <observable result>.
- [~] <Updated behavior>. Given <setup>, <action> produces <target observable result>.
- [-] <Removed expectation>. <Why it is obsolete or where coverage moves.>

## Failures

| Failure | What happens | Recovery | Detected by |
| ------- | ------------ | -------- | ----------- |

Detected by names the alarm or signal that catches the failure. When nothing catches it, write Nothing and add the failure to the README's Open questions. Omit this section when the repository has no failure case in this design.

## Infrastructure

Omit this section unless this repository owns infrastructure for the design. It holds the Resources, Outputs, and Alarms tables from the infrastructure repository file template.

## Tickets

| Ticket | Scope |
| ------ | ----- |
````

## Infrastructure repository file template

```markdown
# <repository>

Back to [README.md](README.md).

## Resources

| Resource | Settings | Why |
| -------- | -------- | --- |

## Outputs

| Output | Used by |
| ------ | ------- |

## Alarms

| Alarm | What it means | What to do |
| ----- | ------------- | ---------- |

Omit this section when the repository adds no alarm.

## Verification

What the plan must show, and what to check after apply in a lower environment.

## Tickets

| Ticket | Scope |
| ------ | ----- |
```

## Decision file template

```markdown
# <Decision topic>

Back to [README.md](../README.md).

## Question

## Decision

Option <N>, <name>, and the main reason, in one sentence.

## Options

### Option 1: <name>

An ASCII diagram, pros, and cons. One subsection per option, numbered from 1.

## Comparison

A table comparing the options.

## Why option <N>

## Trade-offs accepted

| Trade-off | Why it is acceptable |
| --------- | -------------------- |
```

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
