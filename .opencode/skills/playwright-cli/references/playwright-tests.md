# Debugging Playwright Tests with playwright-cli

Use `playwright-cli attach` to connect to a Playwright test that is paused in debug mode.

## Attaching to a Paused Test

When a Playwright test is running with `--debug=cli`, it pauses at the start and prints a session name. Use `playwright-cli` to attach and interactively debug:

```bash
# Attach to the paused test session
playwright-cli attach tw-abcdef
```

Once attached, use any `playwright-cli` command to explore the page:

```bash
playwright-cli snapshot
playwright-cli click e5
playwright-cli console
playwright-cli network
```

Every action generates corresponding Playwright TypeScript code in the output, which can inform what needs to change in the test.

After identifying the issue, detach and stop the background test run.
