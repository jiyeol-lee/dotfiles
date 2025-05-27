local M = {
  "github/copilot.vim",
  version = "*",
}

M.config = function()
  vim.cmd [[imap <silent><script><expr> <C-l> copilot#Accept("\<CR>")]]
  vim.g.copilot_no_tab_map = true
  vim.g.copilot_settings = { selectedCompletionModel = "gpt-4o-copilot-2025-04-03" }

  vim.cmd [[imap <C-]> <Plug>(copilot-next)]]
end

return M
