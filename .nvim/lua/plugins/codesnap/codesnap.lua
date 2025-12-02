local M = {
  "mistricky/codesnap.nvim",
  version = "*",
}

M.config = function()
  local codesnap = require "codesnap"
  local setup = {
    show_line_number = true,
    highlight_color = "#73737320",
    show_workspace = false,
    snapshot_config = {
      window = {
        mac_window_bar = false,
        margin = {
          x = 0,
          y = 0,
        },
      },
      themes_folders = {},
      fonts_folders = {},
      code_config = {
        breadcrumbs = {
          enable = true,
          separator = "/",
        },
      },
      background = "#737373",
    },
  }

  codesnap.setup(setup)
end

return M
