local M = {
  "olimorris/codecompanion.nvim",
  event = "VeryLazy",
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
}

function M.config()
  local code_companion = require "codecompanion"
  local setup = {
    strategies = {
      chat = {
        adapter = "copilot",
      },
      inline = {
        adapter = "copilot",
      },
      agent = {
        adapter = "copilot",
      },
    },
    adapters = {
      copilot = function()
        return require("codecompanion.adapters").extend("copilot", {
          schema = {
            model = {
              default = "gemini-2.5-pro",
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
  }

  code_companion.setup(setup)
end

return M
