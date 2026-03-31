---
name: e2e-test
description: Interactively tests web applications using the Playwright CLI. Use when user asks to "open a page", "take a screenshot", "check the layout", "verify the UI", "test a page behavior", "navigate through pages", "inspect element", "see how a page looks", "fill out a form", "click a button", "test a user flow", "check network requests", "verify cookies", "test localStorage", "mock API responses", "record a trace", or "check console logs". Also use when debugging design issues, verifying responsive layouts, testing form validation, checking API mocking, or tracing page performance.
---

## Quick Reference

```
playwright-cli <command> [args] [options]
playwright-cli -s=<session> <command> [args] [options]
```

**Core commands:** `open`, `goto`, `click`, `fill`, `type`, `hover`, `select`, `check`, `uncheck`, `screenshot`, `pdf`
**Navigation:** `go-back`, `go-forward`, `reload`
**Keyboard/Mouse:** `press`, `keydown`, `keyup`, `mousemove`, `mousedown`, `mouseup`, `mousewheel`
**Tabs:** `tab-list`, `tab-new`, `tab-close`, `tab-select`
**Storage:** `state-load`, `state-save`, `cookie-*`, `localstorage-*`, `sessionstorage-*`
**Network:** `route`, `route-list`, `unroute`
**DevTools:** `console`, `network`, `tracing-start`, `tracing-stop`, `video-start`, `video-stop`
**Sessions:** `list`, `close-all`, `kill-all`

Read `references/commands.md` **when** you need detailed options for a specific command.

## Workflow

1. **Verify Playwright CLI is available** — Confirm `playwright-cli` is installed
2. **Identify the target** — Determine the URL or page to test from the user's request
3. **Choose the command** — Map the user's request to the appropriate CLI command(s)
4. **Execute and report** — Run the command(s) and report findings

## Common Test Scenarios

### Page Navigation & Verification

```bash
# Open a page
playwright-cli open https://example.com

# Navigate to a URL
playwright-cli goto https://example.com/login

# Go back/forward
playwright-cli go-back
playwright-cli go-forward

# Reload page
playwright-cli reload
```

### Element Interaction

```bash
# Get element reference first
playwright-cli snapshot

# Click an element (use ref from snapshot)
playwright-cli click "#submit-button"

# Fill a form field
playwright-cli fill "#email" "user@example.com"

# Type text (character by character)
playwright-cli type "#search" "query text"

# Hover over element
playwright-cli hover "#dropdown"

# Select from dropdown
playwright-cli select "#country" "US"

# Check/uncheck checkbox or radio
playwright-cli check "#agree-terms"
playwright-cli uncheck "#newsletter"
```

### Form Testing

```bash
# Fill form and submit
playwright-cli fill "#name" "John Doe"
playwright-cli fill "#email" "john@example.com"
playwright-cli fill "#password" "securepass123"
playwright-cli click "#signup-button"

# Test form validation (empty submit)
playwright-cli goto https://example.com/form
playwright-cli click "#submit-button"
playwright-cli console error
```

### Screenshot & Visual Verification

```bash
# Screenshot of current page
playwright-cli screenshot

# Screenshot of specific element
playwright-cli snapshot
playwright-cli screenshot "#modal"

# Full page screenshot
playwright-cli screenshot --full-page

# PDF of page
playwright-cli pdf
```

### Keyboard & Mouse

```bash
# Press a key
playwright-cli press "Enter"
playwright-cli press "Escape"
playwright-cli press "arrowdown"

# Press key combination
playwright-cli press "Control+a"
playwright-cli press "Meta+s"

# Move mouse
playwright-cli mousemove 100 200

# Scroll
playwright-cli mousewheel 0 500
```

### Tabs & Windows

```bash
# List all tabs
playwright-cli tab-list

# Open new tab
playwright-cli tab-new https://example.com

# Switch tabs
playwright-cli tab-select 1

# Close tab
playwright-cli tab-close 1
```

### Storage & State

```bash
# Save authentication state
playwright-cli state-save auth.json

# Load authentication state
playwright-cli state-load auth.json

# List cookies
playwright-cli cookie-list

# Set cookie
playwright-cli cookie-set "session" "abc123" --domain=example.com

# Get localStorage
playwright-cli localstorage-list
playwright-cli localstorage-get "token"

# Set localStorage
playwright-cli localstorage-set "theme" "dark"
```

### Network & API

```bash
# List network requests
playwright-cli network

# Mock API response
playwright-cli route "**/api/users"
# Then specify the mock response via eval or another command

# List active mocks
playwright-cli route-list

# Remove mocks
playwright-cli unroute "**/api/users"
```

### Debugging & DevTools

```bash
# View console messages
playwright-cli console

# Set console log level
playwright-cli console error

# Show DevTools
playwright-cli show

# Start trace recording
playwright-cli tracing-start

# Stop trace recording
playwright-cli tracing-stop

# List network requests
playwright-cli network
```

## Error Handling

| Error                               | Meaning               | Action                                                                  |
| ----------------------------------- | --------------------- | ----------------------------------------------------------------------- |
| `command not found: playwright-cli` | Not installed         | Report: "Install with `npm install -g playwright`"                      |
| `element not found: <ref>`          | Element doesn't exist | Use `snapshot` to get correct ref, or check if element is in shadow DOM |
| `Timeout`                           | Operation timed out   | Retry or increase timeout with `--timeout=<ms>`                         |
| `Browser not launched`              | No browser session    | Run `playwright-cli open <url>` first                                   |
| `Invalid session`                   | Session doesn't exist | Run `playwright-cli list` to see available sessions                     |
| `Dialog not handled`                | Dialog appeared       | Use `dialog-accept` or `dialog-dismiss`                                 |

## Constraints

- **NEVER** hardcode credentials or secrets — use environment variables or `state-load` with pre-saved auth
- **NEVER** assume element refs — always use `snapshot` to verify exact refs before clicking/filling
- **NEVER** leave tracing or video recording running — always stop with `tracing-stop` or `video-stop`
- **ALWAYS** clean up test data — use `delete-data` or clear cookies/localstorage after tests
- **ALWAYS** close tabs you open — use `tab-close` when done
- **ALWAYS** report console errors when testing for errors
- **ALWAYS** use descriptive refs in screenshots (e.g., `login-form.png`, `error-modal.png`)

## Example: Complete User Flow Test

**User:** "Test the login flow: open login page, fill credentials, submit, verify redirect to dashboard, check console for errors"

**Agent:**

```bash
# 1. Open login page
playwright-cli open https://example.com/login

# 2. Fill credentials (get refs first, then fill)
playwright-cli snapshot
playwright-cli fill "#email" "user@example.com"
playwright-cli fill "#password" "password123"

# 3. Submit
playwright-cli click "#login-button"

# 4. Verify navigation (should be on dashboard)
playwright-cli console error
playwright-cli screenshot dashboard.png

# 5. Report
# Screenshot saved to dashboard.png
# Console shows no errors
# Login successful - redirected to /dashboard
```

## Example: Form Validation Test

**User:** "Test form validation on the signup form - submit empty and see what errors appear"

**Agent:**

```bash
# 1. Go to signup page
playwright-cli goto https://example.com/signup

# 2. Click submit without filling
playwright-cli click "#submit-button"

# 3. Check for validation messages
playwright-cli console
playwright-cli screenshot validation-errors.png

# Report: "Validation errors shown - email required, password too short"
```

## Example: API Mocking Test

**User:** "Mock the /api/user endpoint to test how the UI handles a failed API call"

**Agent:**

```bash
# 1. Go to page
playwright-cli goto https://example.com/profile

# 2. Mock the API
playwright-cli route "**/api/user"
# (Set up mock response - may need eval or state)

# 3. Reload to trigger mock
playwright-cli reload

# 4. Check UI behavior
playwright-cli screenshot api-error-handling.png
playwright-cli console error

# 5. Clean up
playwright-cli unroute "**/api/user"
```

## Example: Multi-Tab Test

**User:** "Open the app in two tabs, make changes in one, verify the other shows the update"

**Agent:**

```bash
# Tab 1: Open app
playwright-cli open https://example.com/app

# Tab 2: Open same app
playwright-cli tab-new https://example.com/app

# Tab 1: Make a change (e.g., update title)
playwright-cli click "#settings-button"
playwright-cli fill "#title-input" "New Title"
playwright-cli click "#save-button"

# Tab 2: Reload and check
playwright-cli tab-select 2
playwright-cli reload
playwright-cli screenshot tab2-state.png

# Report: "Tab 2 shows the updated title from Tab 1"
```

## Example: Auth State Test

**User:** "Load saved auth state and verify the dashboard shows the logged-in user"

**Agent:**

```bash
# Load auth state
playwright-cli state-load auth.json

# Go to dashboard
playwright-cli goto https://example.com/dashboard

# Verify user is logged in
playwright-cli screenshot logged-in-dashboard.png
playwright-cli localstorage-get "user"

# Report: "Dashboard shows logged-in state with user data"
```
