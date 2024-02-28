local M = {
  "nvim-treesitter/nvim-treesitter",
  version = "*",
  build = ":TSUpdate",
}

M.config = function()
  local nvim_treesitter_config = require "nvim-treesitter.configs"
  local setup = {
    -- one of "all" or a list of languages
    ensure_installed = {
      "typescript",
      "tsx",
      "javascript",
      "scss",
      "html",
      "css",
      "lua",
      "vim",
      "python",
      "markdown",
      "markdown_inline",
      "go",
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
    },
    highlight = {
      enable = true,

      -- NOTE: these are the names of the parsers and not the filetype. (for example if you want to
      -- disable highlighting for the `tex` filetype, you need to include `latex` in this list as this is
      -- the name of the parser)
      -- list of language that will be disabled
      disable = { "lua" },
    },
    autopairs = {
      enable = true,
    },
    indent = {
      enable = true,
    },
  }

  nvim_treesitter_config.setup(setup)
end

return M
