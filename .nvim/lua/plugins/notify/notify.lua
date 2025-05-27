local M = {
  "rcarriga/nvim-notify",
  version = "*",
}

M.config = function()
  local notify = require "notify"

  local setup = {
    background_colour = "#000000",
  }

  notify.setup(setup)
end

return M
