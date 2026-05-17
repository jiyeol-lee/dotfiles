# Simple ASCII Layout Example

User request: "Draw an ASCII layout for a simple marketing card with a header, content region, and call-to-action. Use React/TypeScript pseudocode."

## ASCII Layout

Main layout

```
+---------------------------------------+
| 1]                                    |
| +-----------------------------------+ |
| | 2]                                | |
| +-----------------------------------+ |
| +-----------------------------------+ |
| | 3]                                | |
| +-----------------------------------+ |
| +-----------------------------------+ |
| | 4]                                | |
| +-----------------------------------+ |
+---------------------------------------+
```

## Component Plan

- 1] component: MarketingCard
  create: `src/components/marketing/MarketingCard.tsx`
  details: Owns the card wrapper and composes the header, body, and action regions. Content is provided through static props from the parent page; the component has no local state or data fetching.
  \_pseudocode:

  ```tsx
  export function MarketingCard(props: Props) {
    return <section>{props.title}</section>;
  }
  ```

- 2] component: MarketingCardHeader
  create: `src/components/marketing/MarketingCardHeader.tsx`
  details: Displays the card eyebrow and title from parent props. It does not own state, fetch data, or choose conditional variants.
  \_pseudocode:

  ```tsx
  export function MarketingCardHeader({ eyebrow, title }: Props) {
    return <header>{title}</header>;
  }
  ```

- 3] component: MarketingCardBody
  create: `src/components/marketing/MarketingCardBody.tsx`
  details: Shows short marketing copy from parent props. Text is static for the rendered card and has no state, persistence, or asynchronous behavior.
  \_pseudocode:

  ```tsx
  export function MarketingCardBody({ body }: Props) {
    return <p>{body}</p>;
  }
  ```

- 4] component: MarketingCardAction
  create: `src/components/marketing/MarketingCardAction.tsx`
  details: Renders the call-to-action link using `href` and `label` props from the parent. It is static after render and does not require local state.
  \_pseudocode:

  ```tsx
  export function MarketingCardAction({ href, label }: Props) {
    return <a href={href}>{label}</a>;
  }
  ```

## Final Folder Structure

```text
src/
+-- components/
    +-- marketing/
        +-- MarketingCard.tsx [create]
        +-- MarketingCardHeader.tsx [create]
        +-- MarketingCardBody.tsx [create]
        +-- MarketingCardAction.tsx [create]
```
