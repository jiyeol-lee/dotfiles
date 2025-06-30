local M = {
  "ray-x/lsp_signature.nvim",
  event = "InsertEnter",
}

M.config = function()
  local signature = require "lsp_signature"
  local setup = {
    debug = false,
    bind = true,
    doc_lines = 10,
    floating_window = true,
    floating_window_above_cur_line = true,
    fix_pos = true,
    hint_enable = false,
    use_lspsaga = false,
    hi_parameter = "LspSignatureActiveParameter",
    max_height = 12,
    -- max_width = function()
    --   local width = vim.api.nvim_win_get_width(0)
    --
    --   -- Ensure it's a number, fallback to 80 if not
    --   if type(width) ~= "number" then
    --     width = 80 -- fallback width
    --   end
    --
    --   return width * 0.8
    -- end,
    handler_opts = {
      border = "rounded",
      relative = "editor",
    },
    always_trigger = true,
    auto_close_after = nil,
    extra_trigger_chars = {},
    zindex = 200,
    padding = " ",
    transparency = 85,
    timer_interval = 200,
    toggle_key = nil,
  }

  signature.setup(setup)
  signature.on_attach(setup)
end

return M
