local M = {
  "MeanderingProgrammer/render-markdown.nvim",
  version = "*",
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "nvim-tree/nvim-web-devicons",
  },
}

M.config = function()
  local render_markdown = require "render-markdown"
  local setup = {
    enabled = true,
    render_modes = true,
    file_types = {
      "markdown",
    },
  }

  render_markdown.setup(setup)
end

return M
