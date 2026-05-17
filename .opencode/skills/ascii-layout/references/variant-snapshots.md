# Variant Snapshot Reference

## Core Rule

When requirements describe multiple possible visible UI appearances from roles, plan tiers, data availability, flags, experiments, settings, loading/error/empty states, or other conditions, draw each relevant appearance as a separate snapshot instead of a decision or flow graph.

## Variant Snapshot Rules

- Put variant labels outside diagram code fences, for example `Variant: admin with data`, `Variant: free plan empty state`, or `Variant: experiment enabled`.
- Keep shared components on the same component numbers across all variant snapshots.
- Give different conditional components different component numbers, even when they occupy the same visual slot.
- Explain feature flags, permissions/roles, plan tiers, experiments, data availability, loading/error/empty states, user settings, responsive alternatives, or other conditions outside diagrams in `## Condition Plan` or `## Notes`.
- Do not put condition labels such as `1?` inside UI diagrams unless the marker is visibly rendered in the UI.
- If only a small region changes, use labeled variant magnified views for that parent region instead of repeating the full page.
- Continue to use state labels only where state is added, updated, owned, passed, derived, or consumed; do not label every conditional component with state by default.
