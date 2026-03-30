local M = {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  lazy = false,
}

M.config = function()
  local nvim_treesitter = require "nvim-treesitter"
  local setup = {
    ensure_installed = {
      "typescript",
      "tsx",
      "javascript",
      "scss",
      "html",
      "css",
      "lua",
      "toml",
      "luadoc",
      "luap",
      "vim",
      "python",
      "markdown",
      "markdown_inline",
      "go",
      "gomod",
      "gosum",
      "gotmpl",
      "graphql",
      "dockerfile",
      "json",
      "regex",
      "yaml",
      "http",
      "bash",
      "ssh_config",
      "terraform",
      "hcl",
      "svelte",
    },
  }

  nvim_treesitter.setup(setup)
end

return M
