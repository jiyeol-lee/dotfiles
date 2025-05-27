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

    highlight AvanteTitle guifg=#1e222a guibg=#98c379
    highlight AvanteReversedTitle guifg=#98c379 guibg=#000000 ctermbg=NONE
    highlight AvanteSubtitle guifg=#1e222a guibg=#56b6c2
    highlight AvanteReversedSubtitle guifg=#56b6c2 guibg=#000000 ctermbg=NONE
    highlight AvanteThirdTitle guifg=#abb2bf guibg=#353b45
    highlight AvanteReversedThirdTitle guifg=#353b45 guibg=#000000 ctermbg=NONE
    highlight link AvanteSuggestion Comment
    highlight link AvanteAnnotation Comment
    highlight link AvantePopupHint NormalFloat
    highlight link AvanteInlineHint Keyword
    highlight AvanteToBeDeleted gui=strikethrough guibg=#ffcccc
    highlight AvanteToBeDeletedWOStrikethrough guibg=#562c30
    highlight AvanteConfirmTitle guifg=#1e222a guibg=#e06c75
    highlight AvanteButtonDefault guifg=#1e222a guibg=#abb2bf
    highlight AvanteButtonDefaultHover guifg=#1e222a guibg=#a9cf8a
    highlight AvanteButtonPrimary guifg=#1e222a guibg=#abb2bf
    highlight AvanteButtonPrimaryHover guifg=#1e222a guibg=#56b6c2
    highlight AvanteButtonDanger guifg=#1e222a guibg=#abb2bf
    highlight AvanteButtonDangerHover guifg=#1e222a guibg=#e06c75
    highlight link AvantePromptInputBorder NormalFloat
    highlight AvanteStateSpinnerGenerating guifg=#1e222a guibg=#ab9df2
    highlight AvanteStateSpinnerToolCalling guifg=#1e222a guibg=#56b6c2
    highlight AvanteStateSpinnerFailed guifg=#1e222a guibg=#e06c75
    highlight AvanteStateSpinnerSucceeded guifg=#1e222a guibg=#98c379
    highlight AvanteStateSpinnerSearching guifg=#1e222a guibg=#c678dd
    highlight AvanteStateSpinnerThinking guifg=#1e222a guibg=#c678dd
    highlight AvanteStateSpinnerCompacting guifg=#1e222a guibg=#c678dd

    highlight BookmarkSign guifg=#ffffff ctermbg=NONE

    highlight NormalFloat guibg=NONE ctermbg=NONE
  ]]
end

return M
