---
name: ascii-layout
description: Creates ASCII-only UI appearance/layout snapshots and numbered implementation plans for pages, screens, components, or system layouts. Use when the user asks to draw an ASCII layout, make a layout plan, show visible UI/page/screen/component structure, map components with numbers, magnify crowded layout regions, or produce an implementation plan from an ASCII diagram; do not use for internal flow/logic diagrams, prose-only UI advice, or direct application-code edits.
---

## Reference Loading

Read `references/output-template.md` before producing any ASCII layout output; it is the source of truth for section order, exact item templates, pseudocode placement, and final folder structure.

Read `references/example-simple.md` only when a small normal layout or single conditional swap sample would resolve ambiguity.

Read `references/numbering-and-magnification.md` when nested labels, crowded regions, state labels, or magnified views are involved.

Read `references/variant-snapshots.md` when feature flags, permissions/roles, plan tiers, experiments, data availability, loading/error/empty states, user settings, responsive alternatives, or other requirements-driven conditional UI variants are involved.

Read `references/example-intermediate.md` only when a moderate sample with state markers and magnification would clarify the requested output.

Read `references/example-complex.md` only when a complex sample with multiple UI-like variant snapshots would clarify the requested output.

## Workflow

1. Identify the target layout and target language/framework from the user's request or repository context. If the target language cannot be inferred and pseudocode is needed, ask a clarifying question.
2. Draw the top-level ASCII layout first. For conditional UI variants, draw separate UI-like variant snapshots rather than a flow chart.
3. Label components from `1]`; use nested labels such as `2-1]` and `2-1-1]` when needed.
4. Use separate magnified views when labels or nested regions cannot fit; include the parent label inside the magnified ASCII diagram.
5. Add state labels such as `1>` only where state is added, updated, owned, passed, derived, or consumed. Omit state labels when no state is involved.
6. Keep diagram code fences ASCII-only: borders, spaces, numeric component labels, and numeric state labels only.
7. Explain every component and state label outside diagrams using the exact templates from `references/output-template.md`.
8. Choose `reuse` only when no implementation changes are required; otherwise use `update`. Inspect the repository when file existence matters, or state assumptions if inspection is unavailable.

## Constraints

- NEVER create, update, or patch implementation files from an ASCII layout plan until the user explicitly approves that implementation work.

## Diagram Rules

- In diagram code fences, include only ASCII borders, spaces, numeric component labels, and numeric state labels.
- Do not put component names, prose, headings, arrows with words, or explanations inside diagrams.
- Every component region MUST have a visible ASCII wrapper or boundary, representing its layout wrapper/container rather than a required visual UI border.
- Adjacent components MUST be visibly divided by separate wrappers, spacing, or divider lines.
- For visible variants, keep shared components on the same numbers across snapshots and assign different conditional components different numbers, even when they occupy the same slot.

## Explanation Rules

Each component or state explanation must name exactly one literal action key: `create`, `update`, or `reuse`. Details must explain purpose, data source, props, state, configuration, behavior, and static/dynamic options where relevant. Use `reuse` only when no implementation changes are required; use `update` when props, styling, responsive behavior, options, state, validation, accessibility, events, data fetching, or persistence must change. Include `_pseudocode:` only for `create` and `update`, never for `reuse`.

## Final Check

Before returning, verify the plan follows the formal output template, every diagram label has an explanation, every explained file path appears in the final folder structure, and no implementation files were modified without explicit approval.
