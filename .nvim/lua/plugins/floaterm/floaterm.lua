local M = {
  "voldikss/vim-floaterm",
  version = "*",
}

M.config = function()
  vim.cmd [[
    let g:floaterm_autoinsert='always'
    let g:floaterm_width=0.95
    let g:floaterm_height=0.95
    let g:floaterm_title=""
    let g:floaterm_autoclose='always'
  ]]
end

return M
