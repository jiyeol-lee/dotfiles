---
description: Explains the differences of a code change, diff, branch, or pull request.
agent: primary/codelens
---

Make me a rich explanation of the code change.

It should have these sections:

- Background: Explain the existing system relevant to this change. (You should broadly explore surrounding code for this). Assume that user is already familiar of project so do not include a deep background, but more narrow background directly relevant to the change.
- Intuition: Explain the core intuition for the code change. The focus here is to explain the essence, not the full details. Use concrete examples with toy data. Use figures and diagrams liberally.
- Code: Do a high-level walkthrough of the changes to the code. Group/order the changes in an understandable way.
- Quiz: Come up with five questions that test the reader's knowledge of this PR. This should be medium difficulty, difficult enough that you actually need to understand the substance of the PR to answer them, but not gotchas. The goal is to help the reader make sure that they've actually understood. These should be presented as interactive multiple-choice questions, and when the user clicks, it tells them whether they were correct and gives feedback.

Format:

- Please write with clear, intuitive explanations: introduce the why behind a concept before the how, ground abstract ideas in concrete examples, and present trade-offs neutrally rather than advocating for one side. Write in classic style — direct and confident, as if showing the reader something you've seen clearly yourself, with no hedging, qualifications, or meta-commentary like 'in this section we will...'. Make it engaging, and ensure transitions between sections flow naturally so the piece reads as one continuous argument.
- Make the whole one long page with section headers and a table of contents. Don't use tabs for the top-level structure. Basic responsive styling so you can view it on a phone is nice too. Put the files in `/tmp/agentic-coding-tool/explain-diff/<topic>`. For example: `/tmp/agentic-coding-tool/explain-diff/validate-review/index.html`.
- Use basic `HTML5` tags with `tailwindcss` for styling.
- Use callouts for key concepts or definitions, important edge cases, etc.
- Use Mermaid diagrams for system architecture or data flow, if helpful.
  - Use `mermaid` class with `pre` tag to render diagrams. DO NOT nest the `mermaid` class inside another `mermaid` class.
  - Do not use `&quot;` in your `mermaid` block. It is decoded by the browser before Mermaid parses the content and will break the diagram.
  - Make sure to read the Mermaid documentation to write valid diagrams, instead of relying on your own knowledge of the syntax.
- Some tips on diagrams. Ideally, you should pick a small number of diagram families that can be reused throughout the explanation to explain various cases. Some useful kinds of diagrams:
  - A very simplified version of the UI that the user sees in the app, to explain UI changes.
  - A system diagram showing data flow or communication between components. Make sure to include example data here.
- Use code blocks for code snippets.
  - Use `code` tag under `pre` tag for inline code snippets.
  - Ideally, pass `class="language-<lang>"` to the `code` tag for syntax highlighting.
- Use the `html` template below for the output.
  - Do not add any additional scripts, links or stylesheets, just use `tailwindcss` and `mermaid`.
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
