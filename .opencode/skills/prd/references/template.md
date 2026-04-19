# PRD MD Template

Use this template when drafting a PRD. Replace all `[bracketed]` placeholders. Delete any section annotation comments before writing the final file.

```md
---
title: "[Feature Name — human-readable, title case]"
date: "[YYYY-MM-DD]"
author: "[Who requested or authored this PRD]"
status: "draft"
---

{/_ Status values: draft | in-progress | completed _/}

# [Feature Name]

## Background / Problem Statement

{/\*
WHY does this feature need to exist? Write 2-4 sentences covering:

1. What's the current situation?
2. What's painful about it? (quantify if possible — tickets/week, time lost, revenue impact)
3. Who is affected?

Litmus test: Could someone unfamiliar with the project understand the problem
after reading ONLY this section?
\*/}

[Describe the current state, the pain point, and who is affected. Use data when available.]

## Goals

{/\*
What does success look like? Each goal should be:

- Measurable (tied to a success metric below)
- Achievable within the stated scope
- Written as outcomes, not outputs ("reduce support tickets" not "build a form")
  \*/}

- [Goal 1 — outcome-oriented, measurable]
- [Goal 2]

## Non-Goals

{/\*
CRITICAL SECTION. For every goal, ask: "What adjacent thing might someone assume
is included but ISN'T?" List those here. This prevents scope creep during implementation.

Good non-goals are specific and tempting:

- "SMS-based password reset (planned for Phase 2)"
- "Admin ability to force-reset user passwords"

Bad non-goals are obvious:

- "Building a mobile app" (if the project is a CLI tool)
  \*/}

- [Non-goal 1 — something tempting but explicitly excluded, with brief rationale]
- [Non-goal 2]

## Functional Requirements

{/\*
Number every requirement for traceability (FR-1, FR-2...).
Rules:

- Each requirement MUST be independently testable
- If it contains "and", split it into two requirements
- Describe WHAT the system does, not HOW it's implemented
- Bad: "Use Redis to cache tokens" (implementation detail)
- Good: "Reset tokens are retrievable within 50ms" (testable behavior)
  \*/}

- **FR-1**: [Requirement — what the system must do, testable, no "and"]
- **FR-2**: [Requirement]
- **FR-3**: [Requirement]

## Non-Functional Requirements

{/_
Cover the "-ilities" that apply. Delete categories that don't apply to this feature.
Be specific — "fast" is not a requirement, "< 200ms p95 response time" is.
_/}

- **Performance**: [e.g., "Password reset email sent within 60 seconds of request"]
- **Security**: [e.g., "Reset tokens are cryptographically random, 256-bit minimum"]
- **Accessibility**: [e.g., "Reset flow is fully navigable via keyboard and screen reader"]
- **Scalability**: [e.g., "Supports 1000 concurrent reset requests"]
- **Reliability**: [e.g., "Reset flow available 99.9% uptime"]

## Acceptance Criteria

{/\*
Map each functional requirement to at least one acceptance criterion.
Use Given/When/Then format for clarity:

- Given [precondition]
- When [action]
- Then [expected result]

Each criterion must be a binary pass/fail — no subjective judgment.
\*/}

### FR-1: [Requirement title]

- **Given** [precondition], **when** [action], **then** [expected result].
- **Given** [alternate/edge case], **when** [action], **then** [expected result].

### FR-2: [Requirement title]

- **Given** [precondition], **when** [action], **then** [expected result].

## Technical Considerations

{/\*
Architecture notes for the engineering team. This is the ONE section where
implementation details are appropriate. Cover:

- Dependencies on other systems or services
- Known technical constraints or risks
- Suggested approach (as guidance, not mandate)
- Data model changes needed
- Migration considerations
  \*/}

- [Dependency, constraint, or architectural note]
- [Data model change or migration note]

## Out of Scope

{/\*
Different from Non-Goals. Non-Goals are things someone might EXPECT to be included.
Out of Scope is the explicit boundary of this PRD — everything beyond it.

Use this to prevent "while we're at it..." scope additions.
\*/}

- [Item explicitly excluded from this work]
- [Item deferred to a future phase]

## Success Metrics

{/\*
How do we know this feature succeeded AFTER launch?
Each metric should be:

- Quantifiable (a number, percentage, or threshold)
- Tied to a goal above
- Measurable with existing or planned instrumentation
  \*/}

| Metric                                      | Target                | Measurement Method                |
| ------------------------------------------- | --------------------- | --------------------------------- |
| [e.g., Support tickets for password resets] | [e.g., Reduce by 90%] | [e.g., Zendesk ticket tag count]  |
| [e.g., Reset flow completion rate]          | [e.g., > 95%]         | [e.g., Analytics funnel tracking] |

## Milestones / Phases

{/_
Optional — include only if the feature spans multiple releases.
Each phase should be independently shippable and valuable.
If the feature ships in one release, delete this section.
_/}

### Phase 1: [Name] — [Target date or sprint]

- [Deliverable 1]
- [Deliverable 2]

### Phase 2: [Name] — [Target date or sprint]

- [Deliverable 1]
- [Deliverable 2]

## Sprint Contracts

{/_
Sprint contracts define what "done" looks like for each phase.
They serve as the agreement between the generator (builder) and evaluator (reviewer).
Each contract should be independently verifiable — the evaluator should be able to
check it without knowing implementation details.
_/}

### Sprint 1: [Name]

| Field                   | Description                                                    |
| ----------------------- | -------------------------------------------------------------- |
| **Scope**               | [What this sprint builds — tie to FR numbers]                  |
| **Exit Criteria**       | [Testable pass/fail conditions in Given/When/Then format]      |
| **Verification Method** | [How the evaluator checks: test commands, manual checks, etc.] |
| **Dependencies**        | [What must be complete before this sprint]                     |
| **Handoff Artifact**    | [What state/context the next sprint needs]                     |

### Sprint 2: [Name]

| Field                   | Description                                                    |
| ----------------------- | -------------------------------------------------------------- |
| **Scope**               | [What this sprint builds — tie to FR numbers]                  |
| **Exit Criteria**       | [Testable pass/fail conditions in Given/When/Then format]      |
| **Verification Method** | [How the evaluator checks: test commands, manual checks, etc.] |
| **Dependencies**        | [What must be complete before this sprint]                     |
| **Handoff Artifact**    | [What state/context the next sprint needs]                     |
```
