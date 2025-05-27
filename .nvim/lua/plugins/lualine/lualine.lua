local M = {
  "nvim-lualine/lualine.nvim",
  version = "*",
  dependencies = { "nvim-tree/nvim-web-devicons" },
}

M.config = function()
  local lualine = require "lualine"

  local setup = {
    theme = "gruvbox_dark",
  }
  lualine.setup(setup)
end

return M
