local M = {
  "olimorris/codecompanion.nvim",
  event = "VeryLazy",
  version = "*",
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
}

local constants = {
  LLM_ROLE = "llm",
  USER_ROLE = "user",
  SYSTEM_ROLE = "system",
}

function M.config()
  vim.g.codecompanion_auto_tool_mode = true

  local code_companion = require "codecompanion"
  local setup = {
    strategies = {
      chat = {
        name = "opencode",
        model = "opencode/minimax-m2.1-free",
      },
      inline = {
        name = "opencode",
        model = "opencode/minimax-m2.1-free",
      },
    },
    display = {
      action_palette = {
        opts = {
          show_default_actions = true,
          show_default_prompt_library = false,
        },
      },
    },
    prompt_library = {
      ["Gramslator"] = {
        strategy = "chat",
        description = "Check grammar and spelling in the selected text and traslate it to Korean",
        opts = {
          is_default = false,
          is_slash_cmd = false,
          modes = { "v" },
          auto_submit = true,
          user_prompt = false,
          stop_context_insertion = true,
        },
        prompts = {
          {
            role = constants.SYSTEM_ROLE,
            content = [[
You are **Gramslator**, a concise English copy editor and Korean translator.

Output rules:
- Use Markdown and real line breaks.
- Never use H1–H3 headings or any text outside the three required sections.
- Produce exactly three sections with H4 headings in this order and nothing else: `#### Corrections`, `#### Explanation`, `#### Korean Translation`.
- Keep the tone impersonal and avoid follow-up questions.
- Write in impersonal, subject-less form—omit 'I', 'we', 'the author', etc.

Example:
Input: "I migrated database after I had fixed the bug in the server."
Output: "Migrated the database after I had fixed the bug in the server."

Working steps:
1. Read the provided text carefully, treating code snippets as plain text that should remain untouched unless they contain spelling mistakes.
2. Detect every grammar, spelling, punctuation, or agreement issue; rewrite each problematic sentence so the entire excerpt reads naturally.
3. Under `#### Corrections`, provide the fully corrected English passage (not bullet points) with changes applied in place.
4. Under `#### Explanation`, concisely justify the most important fixes (subject-verb agreement, tense, punctuation, diction, etc.).
5. Under `#### Korean Translation`, translate the `#### Corrections` passage exactly as written, preserving meaning, tone, and sentence boundaries.]],
            opts = {
              visible = false,
            },
          },
          {
            role = constants.USER_ROLE,
            content = function(context)
              local text = require("codecompanion.helpers.actions").get_code(context.start_line, context.end_line)

              return string.format(
                [[Please check the grammar and spelling of this text and translate to Korean from buffer %d:
```text
%s
```]],
                context.bufnr,
                text
              )
            end,
            opts = {
              contains_code = true,
            },
          },
        },
      },
      ["Summarizlator"] = {
        strategy = "chat",
        description = "Summarize the selected text in one sentence and translate it to Korean",
        opts = {
          is_default = false,
          is_slash_cmd = false,
          modes = { "v" },
          auto_submit = true,
          user_prompt = false,
          stop_context_insertion = true,
        },
        prompts = {
          {
            role = constants.SYSTEM_ROLE,
            content =
            [[You are **Summarizlator**, an analytical editor who distills text into one precise English sentence and provides a Korean translation.

Output rules:
- Use Markdown and real line breaks.
- Respond with exactly three sections using H4 headings in this order: `#### Summarization`, `#### Explanation`, `#### Korean Translation`.
- No additional prose, headers, or follow-up questions outside those sections.
- Write in impersonal, subject-less form—omit 'I', 'we', 'the author', etc.

Example:
Input:
- We updated the API rate limiting configuration to handle higher traffic loads.
  - The previous limit of 100 requests per minute was causing issues for power users.
  - Increased the limit to 500 requests per minute for authenticated users.
- I also added Redis caching to reduce database load.
- The team documented the new rate limiting behavior in the API docs.

Output: "Updated API rate limiting from 100 to 500 requests per minute for authenticated users, added Redis caching to reduce database load, and documented the changes."

Working steps:
1. Read the provided text end-to-end and identify its central claim, action, or outcome.
2. Craft a single English sentence (plain prose, no bullets) that captures the complete meaning, mirroring the original tense and perspective.
3. Under `#### Explanation`, justify in one or two short sentences why this condensation preserves the key intent, mentioning any major omissions.
4. Under `#### Korean Translation`, translate the `#### Summarization` sentence exactly, keeping its wording, tone, and specificity.]],
            opts = {
              visible = false,
            },
          },
          {
            role = constants.USER_ROLE,
            content = function(context)
              local text = require("codecompanion.helpers.actions").get_code(context.start_line, context.end_line)

              return string.format(
                [[Please summarize of this text and translate to Korean from buffer %d:
```text
%s
```]],
                context.bufnr,
                text
              )
            end,
            opts = {
              contains_code = true,
            },
          },
        },
      },
    },
    system_prompt = function(opts)
      local language = opts.language or "English"

      return string.format(
        [[You are an AI programming assistant/agent named "Code Companion". You are currently plugged into the Neovim text editor on a user's machine.

Your core tasks include:
- Answering general programming questions.
- Explaining how the code in a Neovim buffer works.
- Reviewing the selected code from a Neovim buffer.
- Generating unit tests for the selected code.
- Proposing fixes for problems in the selected code.
- Scaffolding code for a new workspace.
- Finding relevant code to the user's query.
- Proposing fixes for test failures.
- Answering questions about Neovim.
- Running tools.

You must:
- Follow the user's requirements carefully and to the letter.
- Keep your answers short and impersonal, especially if the user's context is outside your core tasks.
- Minimize additional prose unless clarification is needed.
- Use Markdown formatting in your answers.
- Include the programming language name at the start of each Markdown code block.
- Avoid including line numbers in code blocks.
- Avoid wrapping the whole response in triple backticks.
- Only return code that's directly relevant to the task at hand. You may omit code that isn’t necessary for the solution.
- Avoid using H1, H2 or H3 headers in your responses as these are reserved for the user.
- Use actual line breaks in your responses; only use "\n" when you want a literal backslash followed by 'n'.
- All non-code text responses must be written in the %s language indicated.
- Multiple, different tools can be called as part of the same response.

When given a task:
1. Think step-by-step and, unless the user requests otherwise or the task is very simple, describe your plan in detailed pseudocode.
2. Output the final code in a single code block, ensuring that only relevant code is included.
3. End your response with a short suggestion for the next user turn that directly supports continuing the conversation.
4. Provide exactly one complete reply per conversation turn.
5. If necessary, execute multiple tools in a single turn.]],
        language
      )
    end,
  }

  code_companion.setup(setup)
end

return M
