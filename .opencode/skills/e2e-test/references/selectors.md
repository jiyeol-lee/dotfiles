# E2E Test Selectors Reference

## Selector Priority (getByXXX)

Follow this priority order when selecting elements. Always start from the top and only move down if the higher-priority option is not available.

| Priority | Method             | Use Case                                      |
| -------- | ------------------ | --------------------------------------------- |
| 1        | `getByRole`        | Interactive elements (buttons, links, inputs) |
| 2        | `getByLabel`       | Form fields with associated labels            |
| 3        | `getByPlaceholder` | Inputs with placeholder text                  |
| 4        | `getByText`        | Static text content                           |
| 5        | `getByAltText`     | Images with alt text                          |
| 6        | `getByTitle`       | Elements with title attribute                 |
| 7        | `getByTestId`      | Last resort (requires `data-testid`)          |
| 8        | `locator`          | Avoid if possible; add `data-testid` instead  |

## Usage Guidelines

- **Prefer semantic selectors**: `getByRole` and `getByLabel` are more resilient to UI changes
- **Use `data-testid` as a last resort**: When no semantic selector is available, add `data-testid` to the application code
- **Avoid `locator` with CSS/XPath**: These are fragile and break easily with UI changes
- **Placeholder text**: Only use `getByPlaceholder` when the placeholder is unique and descriptive

