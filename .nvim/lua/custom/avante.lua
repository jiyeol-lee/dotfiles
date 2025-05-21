local M = {
  "yetone/avante.nvim",
  event = "VeryLazy",
  version = false, -- Never set this value to "*"! Never!
  -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
  build = "make",
  dependencies = {
    "stevearc/dressing.nvim",
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
    --- The below dependencies are optional,
    "echasnovski/mini.pick",         -- for file_selector provider mini.pick
    "nvim-telescope/telescope.nvim", -- for file_selector provider telescope
    "hrsh7th/nvim-cmp",              -- autocompletion for avante commands and mentions
    "ibhagwan/fzf-lua",              -- for file_selector provider fzf
  },
}

function M.config()
  local avante = require "avante"
  local setup = {
    provider = "copilot-gemini-2.5",
    copilot = {
      endpoint = "https://api.githubcopilot.com",
      model = "gpt-4o-2024-11-20",
      proxy = nil,            -- [protocol://]host[:port] Use this proxy
      allow_insecure = false, -- Allow insecure server connections
      timeout = 600000, -- Timeout in milliseconds
      temperature = 0,
      max_tokens = 100000,
    },
    vendors = {
      ["copilot-gemini-2.5"] = {
        __inherited_from = "copilot",
        model = "gemini-2.5-pro",
      },
      ["copilot-claude-3.7-sonnet"] = {
        __inherited_from = "copilot",
        model = "claude-3.7-sonnet",
      },
      ["copilot-o3-mini"] = {
        __inherited_from = "copilot",
        model = "o3-mini-2025-01-31",
      },
      ["copilot-o4-mini"] = {
        __inherited_from = "copilot",
        model = "o4-mini",
      },
    },
    behaviour = {
      auto_suggestions = false,
      auto_set_highlight_group = false,
      auto_set_keymaps = true,
      auto_apply_diff_after_generation = false,
      support_paste_from_clipboard = false,
      minimize_diff = true, -- Whether to remove unchanged lines when applying a code block
      enable_token_counting = true,
    },
    auto_suggestions_provider = "claude",
    windows = {
      ---@type "right" | "left" | "top" | "bottom"
      position = "right", -- the position of the sidebar
      width = 50,
      input = {
        prefix = "> ",
        height = 12, -- Height of the input window in vertical layout
      },
    },
  }

  avante.setup(setup)
end

return M
