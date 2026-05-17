# ASCII Layout Output Template

This template defines the required section order for ASCII layout plans. Optional sections appear only when the layout requires them.

## Required Section Order

1. `## ASCII Layout`
2. `## Condition Plan` when feature flags, permissions/roles, plan tiers, experiments, data availability, loading/error/empty states, user settings, responsive alternatives, or other requirements-driven conditional UI variants need explanation outside the diagrams
3. `## Magnified Views` when any component needs a separate expanded diagram, including variant-specific magnified views for a small changed region
4. `## Component Plan`
5. `## State Plan` when state labels appear in any diagram or state changes are required by the plan
6. `## Final Folder Structure`
7. `## Notes` when assumptions, limits, or review concerns need to be called out

## Template

````markdown
## ASCII Layout

Main layout

```
<ASCII diagram containing only borders, spaces, numeric component labels, and numeric state labels>
```

Variant: <condition-or-state-label>

```
<ASCII diagram containing only borders, spaces, numeric component labels, and numeric state labels>
```

Variant: <another-condition-or-state-label>

```
<ASCII diagram containing only borders, spaces, numeric component labels, and numeric state labels>
```

## Condition Plan

- <condition-label> condition: <condition name>
  source: <feature flag, permission/role, plan tier, experiment, route, data value, loading/error/empty state, user setting, viewport, or runtime source>
  variants: <which labeled ASCII snapshots or magnified views this condition controls>
  details: <how to evaluate the condition and which visible components appear for each variant; keep condition labels outside diagrams unless they are visible UI markers>

## Magnified Views

Magnified view for <parent-number>]

```
<ASCII diagram containing the parent label inside the parent region plus nested component labels and any needed state labels>
```

## Component Plan

- <number>] component: <component name>
  create: `<path>`
  details: <purpose, data source, props, state, configuration, behavior, and static/dynamic options when relevant>
  \_pseudocode:

  ```<language>
  <pseudocode only; do not write final implementation code>
  ```

- <number>] component: <component name>
  update: `<path>`
  details: <purpose, changed behavior, data source, props, state, configuration, and static/dynamic options when relevant>
  \_pseudocode:

  ```<language>
  <pseudocode only; do not write final implementation code>
  ```

- <number>] component: <component name>
  reuse: `<path>`
  details: <purpose, existing behavior, expected props/configuration/data/options, and why no code changes are required>

## State Plan

- <number>> state: <state name>
  create: `<path>`
  details: <owner/location, data source, triggers, consumers, defaults, and static/dynamic options>
  \_pseudocode:

  ```<language>
  <pseudocode only; do not write final implementation code>
  ```

- <number>> state: <state name>
  update: `<path>`
  details: <owner/location, changed state behavior, data source, triggers, consumers, defaults, and static/dynamic options>
  \_pseudocode:

  ```<language>
  <pseudocode only; do not write final implementation code>
  ```

- <number>> state: <state name>
  reuse: `<path>`
  details: <owner/location, existing state behavior, data source, triggers, consumers, defaults, static/dynamic options, and why no code changes are required>

## Final Folder Structure

```text
<root>/
+-- <directory>/
|   +-- <file> [create|update|reuse]
+-- <directory>/
    +-- <file> [create|update|reuse]
```

## Notes

- <assumption, constraint, or review note>
````

## Section Rules

- `## ASCII Layout` is required and contains the top-level diagram. A short label such as `Main layout` may appear outside the code fence.
- For variant snapshots, use labels such as `Variant: admin with data`, `Variant: free plan empty state`, or `Variant: experiment enabled`; labels must stay outside code fences. Draw separate UI-like snapshots rather than a flow chart.
- `## Condition Plan` is optional and explains feature flags, permissions/roles, plan tiers, experiments, data availability, loading/error/empty states, user settings, responsive alternatives, or other variant rules outside diagrams. Optional labels such as `1?` may be used in this section, but do not put condition labels into UI diagrams unless the marker is visible UI.
- `## Magnified Views` is optional and appears only when needed. Every magnified diagram must include the parent component label inside the parent region. If only a small region changes between variants, prefer separate labeled variant magnified views for that region instead of repeating the whole page.
- `## Component Plan` is required and must explain every component label used in every diagram.
- `## State Plan` is optional, but required when any state label appears or state behavior is part of the requested plan.
- `## Final Folder Structure` is required and is part of the formal output template.
- `## Notes` is optional and should stay concise.

## Final Folder Structure Rules

The final folder structure is not a layout diagram, so it may include file names, folders, and action annotations such as `[create]`, `[update]`, `[reuse]`, or `[optional/context]`.

- Render the final folder structure as an ASCII tree in a `text` code fence.
- Include every file path mentioned in component explanations and state explanations.
- Do not invent files that are not mentioned in the component or state explanations unless they are clearly marked `[optional/context]`.
- Use the same action semantics as the explanations: `[create]`, `[update]`, or `[reuse]`.
- If multiple components or state items refer to the same file, list the file once with the strongest action required: `[update]` over `[reuse]`, and `[create]` for newly introduced files.
- Preserve file paths exactly as described in explanations, grouped by directory.

## Pseudocode Rules

- Include `_pseudocode:` only for `create` and `update` entries.
- Never include `_pseudocode:` for `reuse` entries.
- If a reused component needs adaptation, classify it as `update` instead.
