# Numbering and Magnification Reference

## Numbering Rules

### Component labels

- Start each top-level component set at `1]`.
- Use simple top-level labels: `1]`, `2]`, `3]`.
- Use parent-derived nested labels in magnified views: `2-1]`, `2-2]`, `2-3]`.
- Use deeper labels only when needed: `2-1-1]`, `2-1-2]`.
- Do not skip labels unless the user explicitly asks to preserve numbering from a previous diagram.

### State-management labels

- Use `>` for state-management labels: `1>`, `2>`, `3>`.
- State labels are separate from component labels. Component labels use `]`; state labels use `>`.
- Prefer simple sequential top-level state labels across the layout. Use nested state labels such as `2-1>` only when a magnified or multi-part state flow needs parent-child precision.
- Add state labels only where state is created, updated, owned, passed, derived, or consumed from the requirements.
- Do not add state labels to every component.
- If no state is involved or required, omit state labels entirely.
- Diagrams may contain only numeric component labels and numeric state labels; do not write state names, component names, prose, or headings inside diagram code fences.

## When to Magnify

Create a magnified view when:

- a component is too small to show its own number label;
- nested child components would make the main diagram unreadable;
- labels would collide with borders or other labels;
- the user asks to inspect a specific component in more detail.

## Required Magnified View Pattern

Every magnified view MUST include the parent region and the parent label inside the ASCII diagram. The parent label must not appear only in the heading.

Correct pattern:

Magnified view for 2]

```
+-------------------------+
| 2] 1>                   |
| +---------+-----------+ |
| | 2-1]    | 2-2]      | |
| +---------+-----------+ |
+-------------------------+
```

Incorrect pattern because the parent label is missing inside the diagram:

Magnified view for 2]

```
+-------------------------+
| +---------+-----------+ |
| | 2-1]    | 2-2]      | |
| +---------+-----------+ |
+-------------------------+
```

## Deep Magnification

If `2-1]` needs its own detailed view, keep the full parent chain visible in the label and include `2-1]` inside the magnified diagram.

Magnified view for 2-1]

```
+-------------------------+
| 2-1]                    |
| +---------+-----------+ |
| | 2-1-1]  | 2-1-2]    | |
| +---------+-----------+ |
+-------------------------+
```

## State Label Explanation Requirements

Every component and state label used in a magnified view needs its own explanation outside the diagram. State explanations must cover:

- one literal key among `create`, `update`, or `reuse`;
- owner/location and file path;
- data source and initial/default values;
- update triggers;
- consumers that read, derive, pass, or submit the state;
- static/dynamic options when relevant;
- pseudocode only for `create` or `update`.
