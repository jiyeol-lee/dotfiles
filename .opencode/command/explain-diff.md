---
description: Explains the differences of a code change, diff, branch, or pull request.
agent: primary/review
---

Make me a rich explanation of the code change.

It should have these sections:

- Background: Explain the existing system relevant to this change. (You should broadly explore surrounding code for this). Assume that user is already familiar of project so do not include a deep background, but more narrow background directly relevant to the change.
- Intuition: Explain the core intuition for the code change. The focus here is to explain the essence, not the full details. Use concrete examples with toy data. Use figures and diagrams liberally.
- Code: Do a high-level walkthrough of the changes to the code. Group/order the changes in an understandable way.

Format:

- Generated file always lives under `/tmp/agentic-coding-tool/explain-diff/<topic>` and is named `index.html` like `/tmp/agentic-coding-tool/explain-diff/implement-plan-selector/index.md`. Attached files are copied into the same directory, `$TMPDIR/explain-diff/implement-plan-selector/*` and linked in the html with relative paths.
- Output a single self-contained Markdown document. Make the whole thing one long page with section headers and a table of contents.
- Use basic html5 tags with `tailwindcss` for styling.
- Use callouts for key concepts or definitions, important edge cases, etc.
- Use Mermaid diagrams for system architecture or data flow, if helpful.
  - Use `mermaid` class with `pre` tag to render diagrams. DO NOT nest the `mermaid` class inside another `mermaid` class.
  - Make sure to use `playwright-cli` bash command to validate the mermaid diagrams render correctly. Fix any issues with the diagrams before finalizing the explanation.
- Use code blocks for code snippets.
  - Use `code` tag under `pre` tag for inline code snippets.
  - Ideally, pass `class="language-<lang>"` to the `code` tag for syntax highlighting.
- Use the `html` template below for the output.
  - Do not add any additional scripts, links or stylesheets, just use `tailwindcss` and `mermaid.
  - Do not customize `tailwindcss` or `mermaid` beyond the default configuration in the template.

```html
<!doctype html>
<html lang="en" class="dark">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />

    <script src="https://cdn.jsdelivr.net/npm/@tailwindcss/browser@4.3.3"></script>
    <script>
      tailwind.config = { darkMode: "class" };
    </script>

    <link
      rel="stylesheet"
      href="https://cdn.jsdelivr.net/gh/highlightjs/cdn-release@11.12.0/build/styles/dark.min.css"
    />
    <script src="https://cdn.jsdelivr.net/gh/highlightjs/cdn-release@11.12.0/build/highlight.min.js"></script>
    <script>
      hljs.highlightAll();
    </script>

    <script type="module">
      import mermaid from "https://cdn.jsdelivr.net/npm/mermaid@11.17.2/+esm";
      mermaid.initialize({ startOnLoad: true, theme: "dark" });
    </script>
  </head>
  <body></body>
</html>
```

After writing the explanation file, provide a URL starts with `file://` that points to the `index.html` file so the user can open it in a browser. Do not include any other text in your response.
