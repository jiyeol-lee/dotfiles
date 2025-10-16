local M = {
  "ravitemer/mcphub.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  build = "npm install -g mcp-hub@latest",
}

M.config = function()
  local mcphub = require "mcphub"
  local setup = {}

  mcphub.setup(setup)
end

return M
