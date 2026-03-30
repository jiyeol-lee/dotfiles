---
name: prd
description: Creates Product Requirements Documents (PRDs) as MD files in __docs/prd/. Use when asked to "write a PRD", "create a product requirements document", "draft requirements", "write requirements for a feature", "create a spec", or "document product requirements".
---

## Workflow

1. **Clarify the goal** — Confirm the feature/goal with the user. Ask for:
   - What problem does this solve? (not what to build — WHY to build it)
   - Who are the users affected?
   - Any known constraints (timeline, tech stack, dependencies)?
   - Any prior art or related features?

   If the user provides enough context upfront, skip the interview and proceed.

2. **Research the codebase** — Before writing, ground the PRD in reality:
   - Glob for related code, configs, and existing docs
   - Read relevant source files to understand current architecture
   - Check for existing PRDs in `__docs/prd/` to avoid duplication and maintain consistency

3. **Derive the feature name** — Convert the feature/goal to kebab-case for the filename:
   - "User Password Reset" → `user-password-reset`
   - "Add Dark Mode Support" → `dark-mode-support`
   - Strip verbs like "add", "implement", "create" — name the FEATURE, not the action

4. **Draft the PRD** — Read `references/template.md` for the full MD structure, then write each section following these principles:

   **Problem Statement** — Write this FIRST. If you can't articulate the problem clearly, the PRD isn't ready. Ask the user for clarification instead of guessing.

   **Goals vs Non-Goals** — Non-goals are MORE important than goals. They prevent scope creep. For every goal, ask: "What's the adjacent thing someone might assume is included but ISN'T?"

   **User Stories** — Write from the user's perspective, not the developer's. Bad: "As a developer, I want an API endpoint." Good: "As a customer, I want to reset my password so I can regain access to my account."

   **Functional Requirements** — Number every requirement (FR-1, FR-2...). Each MUST be independently testable. If a requirement contains "and", split it into two.

   **Acceptance Criteria** — Write these as pass/fail checks. Use "Given/When/Then" format. Every functional requirement MUST have at least one acceptance criterion.

   **Open Questions** — Don't fake certainty. If something is unclear, list it here. A PRD with honest open questions is better than one with fabricated answers.

## File Splitting

**Always split PRDs into multiple files** to maintain readability and enable parallel editing:

1. **Create an index file** — Main PRD file that references sub-files
2. **Split logically** — Group related content into separate files
3. **Index file structure** — Include problem statement, goals, non-goals, and links to sub-files

```
__docs/prd/
├── feature-name.md          # Index file
└── feature-name/            # PRD sub-directory
    ├── overview.md          # Problem, goals, non-goals, user stories
    ├── functional-reqs.md    # All FR-X requirements
    └── acceptance-criteria.md # All acceptance criteria
```

The index file MUST:

- Contain the problem statement and executive summary
- Link to all sub-files
- Serve as the entry point for reading the PRD

## Write the file

Write to a directory structure, not a single file:

- `__docs/prd/<feature-name>.md` → Index file (with YAML frontmatter)
- `__docs/prd/<feature-name>/` → Sub-directory containing the parts

**Frontmatter for PRD files** — Every PRD index file should start with:

```yaml
---
title: <feature-name in title case>
date: yyyy-mm-dd format
author: git config --get user.name (fallback to git config --get user.email)
---
```

Example: If the feature is `user-password-reset`, the frontmatter would be:

```yaml
---
title: User Password Reset
date: 2026-03-30
author: John Doe
---
```

## Report

Summarize what was created and flag any open questions that need resolution before implementation.

## Example: User Password Reset PRD

Given the request: "We need to let users reset their passwords"

```
Step 1 — Clarify: Users currently have no self-service recovery.
         Support team handles ~50 reset requests/week manually.

Step 2 — Research: Read auth module, found existing session management
         in src/auth/. No existing reset flow. Uses JWT tokens.

Step 3 — Feature name: user-password-reset

Step 4 — Draft (abbreviated):

  Problem: Users who forget passwords must contact support,
  creating ~50 tickets/week and 24hr average resolution time.

  Goals:
  - Self-service password reset via email
  - Reduce support tickets for password resets by 90%

  Non-Goals:
  - Account recovery for deleted accounts
  - Password reset via SMS (future phase)
  - Changing password policies or complexity rules

  User Stories:
  - As a user who forgot my password, I want to receive a reset
    link via email so I can regain access without contacting support.
  - As a user, I want confirmation that my password was changed
    so I know the reset succeeded.

  Functional Requirements:
  - FR-1: System sends a reset email with a unique, time-limited token
  - FR-2: Reset tokens expire after 1 hour
  - FR-3: Reset tokens are single-use

  Acceptance Criteria (for FR-1):
  - Given a registered email, when the user requests a reset,
    then an email with a reset link is sent within 60 seconds.
  - Given an unregistered email, when the user requests a reset,
    then the same success message is shown (no email enumeration).

  Open Questions:
  - Should we invalidate existing sessions on password reset?
  - What's the rate limit for reset requests per email?

Step 5 — Write to:
  - __docs/prd/user-password-reset.md (index file with frontmatter)
  - __docs/prd/user-password-reset/overview.md
  - __docs/prd/user-password-reset/functional-reqs.md
  - __docs/prd/user-password-reset/acceptance-criteria.md
```

## Writing Good Requirements — Common Mistakes

| Mistake                           | Example                                          | Fix                                                                      |
| --------------------------------- | ------------------------------------------------ | ------------------------------------------------------------------------ |
| Vague requirement                 | "System should be fast"                          | "Page loads in < 2s on 3G"                                               |
| Untestable criterion              | "User has a good experience"                     | "User completes flow in < 3 steps"                                       |
| Solution disguised as requirement | "Use Redis for caching"                          | "Frequently accessed data loads in < 100ms" (let tech design choose HOW) |
| Missing non-goal                  | Goals list everything to build                   | Add what's explicitly OUT — prevents scope creep                         |
| AND in a requirement              | "FR-1: User can reset password and update email" | Split into FR-1 and FR-2                                                 |

## Constraints

- **NEVER** invent requirements — if context is insufficient, list items under Open Questions
- **NEVER** specify implementation details in functional requirements (that's for tech design)
- **NEVER** skip Non-Goals — they are the most valuable section for preventing scope creep
- **ALWAYS** number functional requirements (FR-1, FR-2...) for traceability
- **ALWAYS** write acceptance criteria as testable pass/fail conditions
- **ALWAYS** split PRDs into multiple files (index + sub-directory)
- **ALWAYS** include YAML frontmatter in the index file
- **ALWAYS** write index file to `__docs/prd/<feature-name>.md`
- **ALWAYS** write sub-files to `__docs/prd/<feature-name>/`
