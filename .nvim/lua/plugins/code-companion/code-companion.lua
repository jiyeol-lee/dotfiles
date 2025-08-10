local M = {
  "olimorris/codecompanion.nvim",
  event = "VeryLazy",
  version = "*",
  dependencies = {
    "nvim-lua/plenary.nvim",
    {
      "j-hui/fidget.nvim",
      init = function()
        require("plugins.code-companion.utils.fidget-spinner"):init()
      end,
    },
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
        adapter = "copilot",
        slash_commands = {
          ["git_files"] = {
            description = "Add git files as a reference",
            callback = function(chat)
              local handle = io.popen "git ls-files"
              if handle ~= nil then
                local result = handle:read "*a"
                handle:close()
                chat:add_reference({ role = constants.USER_ROLE, content = result }, "git", "<git_files>")
              else
                return vim.notify("No git files available", vim.log.levels.INFO, { title = "CodeCompanion" })
              end
            end,
            opts = {
              contains_code = true,
            },
          },
        },
      },
      inline = {
        adapter = "copilot",
      },
    },
    adapters = {
      copilot = function()
        return require("codecompanion.adapters").extend("copilot", {
          schema = {
            model = {
              default = "gpt-5",
              -- default = "claude-sonnet-4",
              -- default = "gemini-2.5-pro",
              -- default = "claude-3.7-sonnet",
              -- default = "claude-3.7-sonnet-thought",
            },
            max_tokens = {
              default = 65536,
            },
          },
        })
      end,
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
      ["Edit<->Test workflow"] = {
        strategy = "workflow",
        description = "Use a workflow to repeatedly edit then test code",
        opts = {
          is_default = false,
        },
        prompts = {
          {
            {
              name = "Setup Test",
              role = constants.USER_ROLE,
              opts = { auto_submit = false },
              content = function()
                return [[### Instructions

Your instructions here

### Steps to Follow

You are required to write code following the instructions provided above and test the correctness by running the designated test suite. Follow these steps exactly:

1. Update the code in #buffer{watch} using the @editor tool
2. Then use the @cmd_runner tool to run the test suite with `<test_cmd>` (do this after you have updated the code)
3. Make sure you trigger both tools in the same response

We'll repeat this cycle until the tests pass. Ensure no deviations from these steps.]]
              end,
            },
          },
          {
            {
              name = "Repeat On Failure",
              role = constants.USER_ROLE,
              opts = { auto_submit = true },
              -- Scope this prompt to the cmd_runner tool
              condition = function()
                ---@diagnostic disable-next-line: undefined-field
                return _G.codecompanion_current_tool == "cmd_runner"
              end,
              -- Repeat until the tests pass, as indicated by the testing flag
              -- which the cmd_runner tool sets on the chat buffer
              repeat_until = function(chat)
                return chat.tools.flags.testing == true
              end,
              content = "The tests have failed. Can you edit the buffer and run the test suite again?",
            },
          },
        },
      },
      ["Explain"] = {
        strategy = "chat",
        description = "Explain how code in a buffer works",
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
            content = [[When asked to explain code, follow these steps:

1. Identify the programming language.
2. Describe the purpose of the code and reference core concepts from the programming language.
3. Explain each function or significant block of code, including parameters and return values.
4. Highlight any specific functions or methods used and their roles.
5. Provide context on how the code fits into a larger application if applicable.]],
            opts = {
              visible = false,
            },
          },
          {
            role = constants.USER_ROLE,
            content = function(context)
              local code = require("codecompanion.helpers.actions").get_code(context.start_line, context.end_line)

              return string.format(
                [[Please explain this code from buffer %d:

```%s
%s
```]],
                context.bufnr,
                context.filetype,
                code
              )
            end,
            opts = {
              contains_code = true,
            },
          },
        },
      },
      ["Unit Tests"] = {
        strategy = "inline",
        description = "Generate unit tests for the selected code",
        opts = {
          is_default = false,
          is_slash_cmd = false,
          modes = { "v" },
          auto_submit = true,
          user_prompt = false,
          placement = "new",
          stop_context_insertion = true,
        },
        prompts = {
          {
            role = constants.SYSTEM_ROLE,
            content = [[When generating unit tests, follow these steps:

1. Identify the programming language.
2. Identify the purpose of the function or module to be tested.
3. List the edge cases and typical use cases that should be covered in the tests and share the plan with the user.
4. Generate unit tests using an appropriate testing framework for the identified programming language.
5. Ensure the tests cover:
      - Normal cases
      - Edge cases
      - Error handling (if applicable)
6. Provide the generated unit tests in a clear and organized manner without additional explanations or chat.]],
            opts = {
              visible = false,
            },
          },
          {
            role = constants.USER_ROLE,
            content = function(context)
              local code = require("codecompanion.helpers.actions").get_code(context.start_line, context.end_line)

              return string.format(
                [[<user_prompt>
Please generate unit tests for this code from buffer %d:

```%s
%s
```
</user_prompt>]],
                context.bufnr,
                context.filetype,
                code
              )
            end,
            opts = {
              contains_code = true,
            },
          },
        },
      },
      ["Fix code"] = {
        strategy = "chat",
        description = "Fix the selected code",
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
            content = [[When asked to fix code, follow these steps:

1. **Identify the Issues**: Carefully read the provided code and identify any potential issues or improvements.
2. **Plan the Fix**: Describe the plan for fixing the code in pseudocode, detailing each step.
3. **Implement the Fix**: Write the corrected code in a single code block.
4. **Explain the Fix**: Briefly explain what changes were made and why.

Ensure the fixed code:

- Includes necessary imports.
- Handles potential errors.
- Follows best practices for readability and maintainability.
- Is formatted correctly.

Use Markdown formatting and include the programming language name at the start of the code block.]],
            opts = {
              visible = false,
            },
          },
          {
            role = constants.USER_ROLE,
            content = function(context)
              local code = require("codecompanion.helpers.actions").get_code(context.start_line, context.end_line)

              return string.format(
                [[Please fix this code from buffer %d:

```%s
%s
```]],
                context.bufnr,
                context.filetype,
                code
              )
            end,
            opts = {
              contains_code = true,
            },
          },
        },
      },
      ["Workspace File"] = {
        strategy = "chat",
        description = "Generate a Workspace file/group",
        opts = {
          ignore_system_prompt = true,
          is_default = false,
        },
        references = {
          {
            type = "file",
            path = {
              vim.fs.joinpath(vim.fn.getcwd(), "codecompanion-workspace.json"),
            },
          },
        },
        prompts = {
          {
            role = constants.SYSTEM_ROLE,
            opts = { visible = false },
            content = function()
              local schema = require("codecompanion").workspace_schema()

              return string.format(
                [[## CONTEXT

A workspace is a JSON configuration file that organizes your codebase into related groups to help LLMs understand your project structure. Each group contains files, symbols, or URLs that provide context about specific functionality or features.

The workspace file follows this structure:

```json
%s
```

## OBJECTIVE

Create or modify a workspace file that effectively organizes the user's codebase to provide optimal context for LLM interactions.

## RESPONSE

You must create or modify a workspace file through a series of prompts over multiple turns:

1. First, ask the user about the project's overall purpose and structure if not already known
2. Then ask the user to identify key functional groups in your codebase
3. For each group, ask the user select relevant files, symbols, or URLs to include. Or, use your own knowledge to identify them
4. Generate the workspace JSON structure based on the input
5. Review and refine the workspace configuration together with the user]],
                schema
              )
            end,
          },
          {
            role = constants.USER_ROLE,
            content = function()
              local prompt = ""
              if vim.fn.filereadable(vim.fs.joinpath(vim.fn.getcwd(), "codecompanion-workspace.json")) == 1 then
                prompt = [[Can you help me add a group to an existing workspace file?]]
              else
                prompt = [[Can you help me create a workspace file?]]
              end

              local ok, _ = pcall(require, "vectorcode")
              if ok then
                prompt = prompt .. " Use the @vectorcode tool to help identify groupings of files"
              end
              return prompt
            end,
          },
        },
      },
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
          adapter = {
            name = "copilot",
            model = "gpt-4.1",
          },
        },
        prompts = {
          {
            role = constants.SYSTEM_ROLE,
            content = [[You must:
- Keep your answers short and impersonal, especially if the user's context is outside your steps.
- Use actual line breaks in your responses; only use "\n" when you want a literal backslash followed by 'n'.
- Use Markdown formatting in your answers.
- Avoid using H1, H2 or H3 headers in your responses as these are reserved for the user.
- Do not ask any follow-up questions.
- Only answer three categories: **Corrections**, **Explanation**, and **Korean Translation** as H4 header without any additional text.
- Do not include any additional text or explanations outside of the specified categories.

When given a text, follow these steps:
1. **Read the Text**: Carefully read the provided text to identify any grammatical or spelling errors.
2. **Identify Issues**: Look for common issues such as:
    - Subject-verb agreement
    - Punctuation errors
    - Spelling mistakes
    - Sentence structure problems
3. **Provide Corrections**: Suggest corrections for the identified issues.
4. **Explain Corrections**: Briefly explain the corrections made and why they improve the text.
5. **Translate to Korean**: After correcting the text, translate it into Korean.]],
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
          adapter = {
            name = "copilot",
            model = "gpt-4.1",
          },
        },
        prompts = {
          {
            role = constants.SYSTEM_ROLE,
            content = [[You must:
- Keep your answers impersonal, especially if the user's context is outside your steps.
- Use actual line breaks in your responses; only use "\n" when you want a literal backslash followed by 'n'.
- Use Markdown formatting in your answers.
- Avoid using H1, H2 or H3 headers in your responses as these are reserved for the user.
- Do not explain in the third person; summarize the original sentence as it is.
- Do not ask any follow-up questions.
- Only answer three categories: **Summarization**, **Explanation**, and **Korean Translation** as H4 header without any additional text.
- Do not include any additional text or explanations outside of the specified categories.

When given a text, follow these steps:
1. **Read the Text**: Carefully read the provided text to summarize it.
2. **Provide Single Sentence**: Make the text in one sentence.
3. **Explain Summarization**: Briefly explain the single sentence made and why it captures the essence of the text.
4. **Translate to Korean**: After making a single sentence the text, translate it into Korean.]],
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
