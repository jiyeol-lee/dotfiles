local M = {
  "olimorris/codecompanion.nvim",
  event = "VeryLazy",
  version = "*",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "ravitemer/mcphub.nvim",
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
      },
      inline = {
        adapter = "copilot",
      },
    },
    adapters = {
      http = {
        copilot = function()
          return require("codecompanion.adapters").extend("copilot", {
            schema = {
              model = {
                -- default = "claude-sonnet-4.5",
                default = "gpt-5",
                -- default = "gemini-2.5-pro",
              },
            },
          })
        end,
      },
    },
    extensions = {
      mcphub = {
        callback = "mcphub.extensions.codecompanion",
        opts = {
          -- MCP Tools
          make_tools = true,                   -- Make individual tools (@server__tool) and server groups (@server) from MCP servers
          show_server_tools_in_chat = true,    -- Show individual tools in chat completion (when make_tools=true)
          add_mcp_prefix_to_tool_names = true, -- Add mcp__ prefix (e.g `@mcp__github`, `@mcp__neovim__list_issues`)
          show_result_in_chat = false,         -- Show tool results directly in chat buffer
          -- MCP Resources
          make_vars = true,                    -- Convert MCP resources to #variables for prompts
          -- MCP Prompts
          make_slash_commands = false,         -- Add MCP prompts as /slash commands
        },
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
                -- Enable YOLO mode!
                vim.g.codecompanion_yolo_mode = true

                return [[### Instructions

- Do not care about type. Feel free to use `as any` or `@ts-ignore` if needed
- If you need to mock data, mock as little as possible
- Make sure you cover all edge cases
- Update test descriptions if necessary
- Follow existing test style
- If you need to understand the code, use @{file_search} and @{read_file} tools to find the type definition

### Steps to Follow

You are required to write code following the instructions provided above and test the correctness by running the designated test suite. Follow these steps exactly:

1. Update the code in #{buffer} using the @{insert_edit_into_file} tool
2. Then use the @{cmd_runner} tool to run the test suite with `<test_cmd>` (do this after you have updated the code)
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
                return _G.codecompanion_current_tool == "cmd_runner"
              end,
              -- Repeat until the tests pass, as indicated by the testing flag
              -- which the cmd_runner tool sets on the chat buffer
              repeat_until = function(chat)
                return chat.tool_registry.flags.testing == true
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
          },
          {
            role = constants.USER_ROLE,
            content = function(context)
              local code = require("codecompanion.helpers.actions").get_code(context.start_line, context.end_line)

              return string.format(
                [[Please explain this code from buffer %d:

```%s
%s
```
]],
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
