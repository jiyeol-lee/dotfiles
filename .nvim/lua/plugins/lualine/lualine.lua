local M = {
  "nvim-lualine/lualine.nvim",
  version = "*",
  dependencies = { "nvim-tree/nvim-web-devicons" },
}

M.config = function()
  local lualine = require "lualine"
  local lualine_code_companion_extension = require "plugins.lualine.extension.code-companion"

  local setup = {
    theme = "gruvbox_dark",
    sections = {
      lualine_x = {
        { lualine_code_companion_extension },
        "encoding",
        "fileformat",
        "filetype",
      },
    },
  }
  lualine.setup(setup)
end

return M
