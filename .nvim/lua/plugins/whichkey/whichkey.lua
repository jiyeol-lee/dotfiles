local M = {
  "folke/which-key.nvim",
  version = "*",
  event = "VeryLazy",
}

M.config = function()
  local setup = {
    preset = "modern",
  }

  local mappings = {
    {
      mode = "n",
      "<leader>1",
      "<cmd>BufferLineGoToBuffer 1<CR>",
      desc = "Buffer 1",
      nowait = true,
    },
    {
      mode = "n",
      "<leader>2",
      "<cmd>BufferLineGoToBuffer 2<CR>",
      desc = "Buffer 2",
      nowait = true,
    },
    {
      mode = "n",
      "<leader>3",
      "<cmd>BufferLineGoToBuffer 3<CR>",
      desc = "Buffer 3",
      nowait = true,
    },
    {
      mode = "n",
      "<leader>4",
      "<cmd>BufferLineGoToBuffer 4<CR>",
      desc = "Buffer 4",
      nowait = true,
    },
    {
      mode = "n",
      "<leader>5",
      "<cmd>BufferLineGoToBuffer 5<CR>",
      desc = "Buffer 5",
      nowait = true,
    },
    {
      mode = "n",
      "<leader>6",
      "<cmd>BufferLineGoToBuffer 6<CR>",
      desc = "Buffer 6",
      nowait = true,
    },
    {
      mode = "n",
      "<leader>7",
      "<cmd>BufferLineGoToBuffer 7<CR>",
      desc = "Buffer 7",
      nowait = true,
    },
    {
      mode = "n",
      "<leader>8",
      "<cmd>BufferLineGoToBuffer 8<CR>",
      desc = "Buffer 8",
      nowait = true,
    },
    {
      mode = "n",
      "<leader>9",
      "<cmd>BufferLineGoToBuffer 9<CR>",
      desc = "Buffer 9",
      nowait = true,
    },
    {
      mode = "n",
      "<leader>e",
      "<cmd>NvimTreeToggle<CR>",
      desc = "Explorer",
      nowait = true,
    },
    {
      mode = "n",
      "<leader>w",
      "<cmd>w!<CR>",
      desc = "Save",
      nowait = true,
    },
    {
      mode = "n",
      "<leader>q",
      "<cmd>bdelete!<CR>",
      desc = "Close Buffer",
      nowait = true,
    },
    {
      mode = "n",
      "<leader>Q",
      "<cmd>bufdo bd | qa!<CR>",
      desc = "Quit",
      nowait = true,
    },
    {
      mode = "n",
      "<leader><CR>",
      "<cmd>nohlsearch<CR>",
      desc = "No Highlight",
      nowait = true,
    },
    {
      mode = "n",
      "grd",
      "<cmd>lua vim.lsp.buf.definition()<CR>",
      nowait = true,
    },
    {
      mode = "n",
      "grh",
      "<cmd>lua vim.lsp.buf.hover()<CR>",
      nowait = true,
    },
    {
      mode = "n",
      "grl",
      "<cmd>lua vim.diagnostic.open_float()<CR>",
      nowait = true,
    },

    {
      mode = "n",
      "<leader>a",
      group = "AI",
      nowait = false,
    },
    {
      mode = "n",
      "<leader>aa",
      "<cmd>CodeCompanionActions<CR>",
      desc = "Code Companion Actions",
      nowait = true,
    },
    {
      mode = "n",
      "<leader>at",
      "<cmd>CodeCompanionChat Toggle<CR>",
      desc = "Code Companion Toggle",
      nowait = true,
    },

    {
      mode = "n",
      "<leader>b",
      group = "Bookmark",
      nowait = false,
    },
    {
      mode = "n",
      "<leader>bt",
      "<cmd>BookmarkToggle<CR>",
      desc = "Bookmark Toggle",
      nowait = true,
    },
    {
      mode = "n",
      "<leader>ba",
      "<cmd>BookmarkShowAll<CR>",
      desc = "Bookmark Show All",
      nowait = true,
    },
    {
      mode = "n",
      "<leader>bj",
      "<cmd>BookmarkNext<CR>",
      desc = "Bookmark Next",
      nowait = true,
    },
    {
      mode = "n",
      "<leader>bk",
      "<cmd>BookmarkPrev<CR>",
      desc = "Bookmark Prev",
      nowait = true,
    },
    {
      mode = "n",
      "<leader>bx",
      "<cmd>BookmarkClearAll<CR>",
      desc = "Bookmark Clear All",
      nowait = true,
    },

    {
      mode = "n",
      "<leader>g",
      group = "Git",
      nowait = false,
    },
    {
      mode = "n",
      "<leader>gg",
      "<cmd>FloatermNew lazygit<CR>",
      desc = "Lazygit",
      nowait = true,
    },
    {
      mode = "n",
      "<leader>gu",
      "<cmd>silent !gh auth switch && gh auth setup-git && tmux refresh-client -S<cr>",
      desc = "gh switch user",
      nowait = true,
    },
    {
      mode = "n",
      "<leader>gd",
      "<cmd>Gitsigns diffthis HEAD<CR>",
      desc = "Diff",
      nowait = true,
    },
    {
      mode = "n",
      "<leader>gb",
      "<cmd>lua Git_backup()<CR>",
      desc = "Backup",
      nowait = true,
    },
    {
      mode = "n",
      "<leader>gs",
      "<cmd>lua Git_force_sync()<CR>",
      desc = "Force Sync",
      nowait = true,
    },

    {
      mode = "n",
      "<leader>f",
      group = "Telescope",
      nowait = true,
    },
    {
      mode = "n",
      "<leader>ff",
      "<cmd>Telescope find_files<CR>",
      desc = "Find Files",
      nowait = true,
    },
    {
      mode = "n",
      "<leader>fe",
      "<cmd>Telescope emoji<CR>",
      desc = "Find Emoji",
      nowait = true,
    },
    {
      mode = "n",
      "<leader>fg",
      "<cmd>Telescope live_grep<CR>",
      desc = "Find Grep",
      nowait = true,
    },
    {
      mode = "n",
      "<leader>ft",
      "<cmd>Telescope terraform_doc<CR>",
      desc = "Find Telescope docs",
      nowait = true,
    },

    {
      mode = "n",
      "<leader>l",
      group = "LSP",
      nowait = true,
    },
    {
      mode = "n",
      "<leader>la",
      "<cmd>lua vim.lsp.buf.code_action()<CR>",
      desc = "Code Action",
      nowait = true,
    },
    {
      mode = "n",
      "<leader>lI",
      "<cmd>LspInstallInfo<CR>",
      desc = "Installer Info",
      nowait = true,
    },
    {
      mode = "n",
      "<leader>lr",
      "<cmd>LspRestart<CR>",
      desc = "Restart Lsp Server",
      nowait = true,
    },

    {
      mode = "n",
      "<leader>o",
      group = "Obsidian",
      nowait = true,
    },
    {
      mode = "n",
      "<leader>os",
      ":ObsidianSearch<CR>",
      desc = "Search in workspace",
      nowait = true,
    },
    {
      mode = "n",
      "<leader>on",
      ":ObsidianNew<CR>",
      desc = "Create a new note",
      nowait = true,
    },
    {
      mode = "n",
      "<leader>od",
      ":ObsidianDailies -1 1<CR>",
      desc = "Open dailies telescope",
      nowait = true,
    },
    {
      mode = "n",
      "<leader>ot",
      ":ObsidianTags<CR>",
      desc = "Search by tags",
      nowait = true,
    },
    {
      mode = "n",
      "<leader>olb",
      ":ObsidianBacklinks<CR>",
      desc = "Display backlinks",
      nowait = true,
    },
    {
      mode = "n",
      "<leader>olf",
      ":ObsidianLinks<CR>",
      desc = "Display links",
      nowait = true,
    },
    {
      mode = "n",
      "<leader>oln",
      ":ObsidianLinkNew<CR>",
      desc = "Create a new link",
      nowait = true,
    },

    {
      mode = "n",
      "<leader>s",
      group = "Search",
      nowait = true,
    },
    {
      mode = "n",
      "<leader>ss",
      "<cmd>lua require('spectre').open()<CR>",
      desc = "Search",
      nowait = true,
    },

    {
      mode = "n",
      "<leader>t",
      group = "Test",
      nowait = true,
    },
    {
      mode = "n",
      "<leader>to",
      "<cmd>TestNearest<CR>",
      desc = "Nearest",
      nowait = true,
    },
    {
      mode = "n",
      "<leader>tw",
      "<cmd>silent !tmux split-window -h<CR><cmd>silent !tmux send-keys 'yarn test:watch <C-r>%' C-m;<CR><cmd>silent !tmux select-pane -t 0<CR>",
      desc = "Nearest watch",
      nowait = true,
    },
    {
      mode = "n",
      "<leader>tr",
      "<cmd>lua require 'rest-nvim'.run()<CR>",
      desc = "Run REST-API",
      nowait = true,
    },

    {
      mode = "n",
      "<leader>T",
      group = "Terminal",
      nowait = true,
    },
    {
      mode = "n",
      "<leader>Tf",
      "<cmd>ToggleTerm direction=float<CR>",
      desc = "Float",
      nowait = true,
    },
    {
      mode = "n",
      "<leader>Th",
      "<cmd>ToggleTerm size=10 direction=horizontal<CR>",
      desc = "Horizontal",
      nowait = true,
    },
    {
      mode = "n",
      "<leader>Tv",
      "<cmd>ToggleTerm size=80 direction=vertical<CR>",
      desc = "Vertical",
      nowait = true,
    },

    {
      mode = "v",
      "<leader>a",
      group = "AI",
      nowait = false,
    },
    {
      mode = "v",
      "<leader>aa",
      "<cmd>CodeCompanionActions<CR>",
      desc = "Code Companion Actions",
      nowait = true,
    },

    {
      mode = "v",
      "<leader>f",
      group = "Telescope",
      nowait = true,
    },
    {
      mode = "v",
      "<leader>ff",
      desc = "Telescope Find",
      nowait = true,
    },
    {
      mode = "v",
      "<leader>fg",
      "y<ESC><cmd>Telescope grep_string<CR>",
      desc = "Find Grep",
      nowait = true,
    },

    {
      mode = "v",
      "<leader>s",
      group = "Search",
      nowait = true,
    },
    {
      mode = "v",
      "<leader>ss",
      "<cmd>lua require('spectre').open_visual({select_word=true})<CR>",
      desc = "Search",
      nowait = true,
    },
  }

  local which_key = require "which-key"

  which_key.add(mappings)
  which_key.setup(setup)
end

return M
