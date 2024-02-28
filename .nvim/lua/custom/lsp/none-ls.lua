local M = {
  "nvimtools/none-ls.nvim",
  dependencies = {
    {
      "nvim-lua/plenary.nvim",
    },
  },
}

M.config = function()
  local null_ls = require "null-ls"
  -- https://github.com/nvimtools/none-ls.nvim/blob/main/doc/BUILTINS.md
  local formatting = null_ls.builtins.formatting
  local augroup = vim.api.nvim_create_augroup("LspFormatting", {})
  local setup = {
    debug = true,
    sources = {
      -- lua
      formatting.stylua,
      -- webdev stuff
      formatting.prettier,
      -- go
      formatting.golines,
      formatting.gofumpt,
      -- bash
      formatting.shfmt,
      -- terraform
      formatting.terraform_fmt,
    },
    on_attach = function(client, bufnr)
      -- the Buffer will be null in buffers like nvim-tree or new unsaved files
      if not bufnr then
        return
      end

      if client.supports_method "textDocument/formatting" then
        vim.api.nvim_clear_autocmds { group = augroup, buffer = bufnr }
        vim.api.nvim_create_autocmd("BufWritePre", {
          group = augroup,
          buffer = bufnr,
          callback = function()
            vim.lsp.buf.format { async = false }
          end,
        })
      end
    end,
  }

  -- https://github.com/prettier-solidity/prettier-plugin-solidity
  -- npm install --save-dev prettier prettier-plugin-solidity
  null_ls.setup(setup)
end

return M
