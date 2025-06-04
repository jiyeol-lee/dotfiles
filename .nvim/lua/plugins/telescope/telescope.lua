local M = {
  "nvim-telescope/telescope.nvim",
  version = "*",
  dependencies = {
    {
      "nvim-lua/plenary.nvim",
      "xiyaowong/telescope-emoji",
      "ANGkeith/telescope-terraform-doc.nvim",
    },
  },
}

M.config = function()
  local actions = require "telescope.actions"
  local action_state = require "telescope.actions.state"

  -- this is a hack to open multiple files in tabs
  -- hopefully this will be fixed in the future
  local function fzf_multi_select(prompt_bufnr)
    local picker = action_state.get_current_picker(prompt_bufnr)
    local selections = picker:get_multi_selection()

    if #selections > 1 then
      for _, entry in ipairs(selections) do
        vim.cmd(string.format("%s %s", ":e!", entry.value))
      end
      vim.cmd ":stopinsert"
    else
      actions.select_tab(prompt_bufnr)
    end
  end

  local telescope = require "telescope"
  local setup = {
    defaults = {
      mappings = {
        i = {
          -- I don't care about normal mode
          ["<esc>"] = actions.close,
          ["<C-k>"] = "move_selection_previous",
          ["<C-j>"] = "move_selection_next",
          ["<C-t>"] = fzf_multi_select,
        },
      },
      sorting_strategy = "ascending",
      layout_config = {
        prompt_position = "top",
      },
    },
    pickers = {
      find_files = {
        find_command = function()
          return { "rg", "--files", "--color", "never", "-g", "!.git" }
        end,
        hidden = true,
      },
    },
    extensions = {
      emoji = {
        action = function(emoji)
          -- insert emoji when picked
          vim.api.nvim_put({ ":" .. emoji.name .. ":" }, "c", false, true)
        end,
      },
    },
  }

  telescope.setup(setup)
  telescope.load_extension "emoji"
  telescope.load_extension "terraform_doc"
end

return M
