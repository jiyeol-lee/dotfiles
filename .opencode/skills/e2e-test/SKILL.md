---
name: e2e-test
description: Writes and runs end-to-end tests using Playwright. Use when user asks to "write E2E tests", "add end-to-end tests", "test this user flow", "fix flaky tests", "debug test failures", or "add Playwright tests". Also use when validating user-facing workflows or creating page object models.
---

## Workflow

1. **Discover test setup** — Read `playwright.config.ts` (or `.js`) for base URL, test directory, browser config, and timeouts
2. **Identify target flow** — Determine which user flow to test from the request
3. **Check for existing patterns** — Glob `**/e2e/**/*.spec.ts` or `**/tests/**/*.spec.ts` to follow existing test structure and naming conventions
4. **Write the test** — Follow selector priority, use page object models for complex flows
5. **Run and verify** — Execute with `npx playwright test <file>` and report results

## Selector Priority

Read `references/selectors.md` **when** choosing selectors for test elements or when tests fail due to selector issues.

Quick reference (use in this order):
1. `getByRole` — buttons, links, inputs (preferred)
2. `getByLabel` — form fields
3. `getByPlaceholder` — inputs with placeholder
4. `getByText` — static text content
5. `getByTestId` — last resort, requires `data-testid` attribute

## Error Handling

| Error Type | Action |
| ---------------------- | -------------------------------------------- |
| Test failures | Document with error message and screenshot |
| Flaky tests | Add retry logic or fix root cause |
| Selector not found | Check selector strategy, suggest `data-testid` |
| Timeout errors | Increase timeout or fix async handling |
| Missing test deps | Report which dependencies are needed |
| Browser launch failure | Report environment setup issues |

## Example

**User request:** "Write an E2E test for the login flow"

```typescript
import { test, expect } from '@playwright/test';

test.describe('Login Flow', () => {
  test('should login with valid credentials', async ({ page }) => {
    await page.goto('/login');

    // Fill login form using semantic selectors
    await page.getByLabel('Email').fill('user@example.com');
    await page.getByLabel('Password').fill('securepassword');
    await page.getByRole('button', { name: 'Sign in' }).click();

    // Verify successful login
    await expect(page).toHaveURL('/dashboard');
    await expect(page.getByRole('heading', { name: 'Welcome' })).toBeVisible();
  });

  test('should show error for invalid credentials', async ({ page }) => {
    await page.goto('/login');

    await page.getByLabel('Email').fill('user@example.com');
    await page.getByLabel('Password').fill('wrongpassword');
    await page.getByRole('button', { name: 'Sign in' }).click();

    // Verify error message appears
    await expect(page.getByText('Invalid email or password')).toBeVisible();
    await expect(page).toHaveURL('/login');
  });
});
```

Key patterns demonstrated:
- `getByLabel` for form fields (priority 2 — semantic and resilient)
- `getByRole` for buttons (priority 1 — most preferred)
- `getByText` for error messages (priority 4 — appropriate for dynamic content)
- `expect` assertions for URL and element visibility
- Happy path AND error path in the same describe block

## Constraints

- **NEVER** hardcode credentials or secrets in test files — use environment variables or test fixtures
- **NEVER** skip tests without a documented reason (comment explaining why)
- **NEVER** use `locator` with raw CSS/XPath when a semantic selector is available
- **NEVER** write tests that depend on execution order between `test()` blocks
- **ALWAYS** clean up test data created during tests (use `test.afterEach` or `test.afterAll`)
- **ALWAYS** report flaky test patterns to the orchestrator for investigation
