local M = {
  "catppuccin/nvim",
  version = "*",
  priority = 1000,
}

M.config = function()
  local catppuccin = require "catppuccin"
  local setup = {
    terminal_colors = true,
    transparent_mode = true,
  }

  catppuccin.setup(setup)

  vim.cmd [[
    " set the colorscheme and highlight here
    set background=dark
    colorscheme catppuccin

    " make background transparent
    highlight Normal guibg=NONE ctermbg=NONE
    highlight NormalNC guibg=NONE ctermbg=NONE
    highlight NvimTreeNormal guibg=NONE ctermbg=NONE
    highlight NvimTreeNormalNC guibg=NONE ctermbg=NONE
    highlight NvimTreeNormalNC guibg=NONE ctermbg=NONE
    highlight NvimTreeCursorLine guifg=#ef8d34
    highlight GitSignsCurrentLineBlame guifg=#ffffff
    highlight PmenuSel guibg=gray ctermbg=gray
    highlight CursorLine guifg=NONE guibg=#223843
    highlight Visual guifg=NONE guibg=#223843

    " vimwiki highlights
    highlight VimwikiHeader1 cterm=bold gui=bold guifg=#ff6800 " guibg=#361a1a
    highlight VimwikiHeader2 cterm=bold gui=bold guifg=#ffd700 " guibg=#362a1a
    highlight VimwikiHeader3 cterm=bold gui=bold guifg=#90ee90 " guibg=#36361a
    highlight VimwikiHeader4 cterm=bold gui=bold guifg=#87cefa " guibg=#1a362a
    highlight VimwikiHeader5 cterm=bold gui=bold guifg=#7b68ee " guibg=#1a2a36
    highlight VimwikiHeader6 cterm=bold gui=bold guifg=#d8bfd8 " guibg=#2a1a36
  ]]
end

return M
