local M = {
  "numToStr/Comment.nvim",
  version = "*",
}

M.config = function()
  local comment = require "Comment"
  local setup = {}

  comment.setup(setup)
end

return M
