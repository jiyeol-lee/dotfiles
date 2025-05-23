-- this should be called first so we can use spec func
require "custom.launch"

require "custom.keymaps"
require "custom.options"
require "custom.autocommands"
require "custom.git-backup" -- to backup git repo
require "custom.git-force-sync" -- to force sync git repo

-- lsp
spec "custom.lsp.mason"
spec "custom.lsp.none-ls"
spec "custom.lsp.lsp-signature"

spec "custom.codesnap"
spec "custom.whichkey"
spec "custom.notify"
spec "custom.typescript"
spec "custom.colorscheme"
spec "custom.comment"
spec "custom.obsidian"
spec "custom.render-markdown"
spec "custom.highlightyark"
-- spec "custom.octo"
-- spec("custom.indent-blankline")
spec "custom.snacks"
spec "custom.treesitter"
spec "custom.nvim-tree"
spec "custom.telescope"
spec "custom.lualine"
spec "custom.gitsigns"
spec "custom.floaterm"
spec "custom.copilot"
spec "custom.avante"
spec "custom.cmp"
spec "custom.autopairs" -- this should be after cmp
spec "custom.test"
spec "custom.markdown-preview"
spec "custom.bookmarks"
spec "custom.prisma" -- tree sitter is not working for some reason
spec "custom.gopher"

-- vim extra combinations start
spec "custom.subversive"
spec "custom.surround"
-- spec "custom.replace-with-register"

-- search and replace text
spec "custom.spectre"

require "custom.lazy" -- this should be the last
