local M = {
  "ray-x/lsp_signature.nvim",
  event = "InsertEnter",
}

M.config = function()
  local signature = require "lsp_signature"
  local setup = {
    bind = true,
    handler_opts = {
      border = "rounded",
      relative = "editor",
    },
    transparency = 100,
  }

  signature.setup(setup)
  signature.on_attach(setup)
end

return M
