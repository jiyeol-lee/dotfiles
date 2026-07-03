local M = {
  "jiyeol-lee/obsidian.nvim",
  version = "*",
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
}

M.config = function()
  local function _make_filename(source_path)
    math.randomseed(os.time())
    local ext = vim.fn.fnamemodify(source_path, ":e")

    if ext ~= "" then
      ext = "." .. ext
    end

    local timestamp = os.date "!%Y%m%dT%H%M%SZ"
    local random = math.random(0, 99999999)

    return string.format("%s_%08d%s", timestamp, random, ext)
  end

  local obsidian = require "obsidian"
  local setup = {
    workspaces = {
      {
        name = "personal",
        path = "~/vaults/vpersonal",
        strict = true,
      },
      {
        name = "work2",
        path = "~/vaults/vwork2",
        strict = true,
      },
      {
        name = "work3",
        path = "~/vaults/vwork3",
        strict = true,
      },
    },

    -- Optional, if you keep notes in a specific subdirectory of your vault.
    notes_subdir = "notes",

    daily_notes = {
      -- Optional, if you keep daily notes in a separate directory.
      folder = "dailies",
      -- Optional, if you want to change the date format for the ID of daily notes.
      date_format = "%Y-%m-%d",
      -- Optional, if you want to change the date format of the default alias of daily notes.
      alias_format = "%Y-%m-%d",
      -- Optional, default tags to add to each new daily note created.
      default_tags = { "daily-notes" },
      -- Optional, if you want to automatically insert a template from your template directory like 'daily.md'
      template = "daily.md",
    },

    -- Optional, completion of wiki links, local markdown links, and tags using nvim-cmp.
    completion = {
      -- Set to false to disable completion.
      nvim_cmp = true,
      -- Trigger completion at 2 chars.
      min_chars = 2,
    },

    -- Where to put new notes. Valid options are
    --  * "current_dir" - put new notes in same directory as the current buffer.
    --  * "notes_subdir" - put new notes in the default notes subdirectory.
    new_notes_location = "notes_subdir",

    -- Optional, customize how note IDs are generated given an optional title.
    ---@param title string|?
    ---@return string
    note_id_func = function(title)
      return tostring(os.time())
    end,

    -- Either 'wiki' or 'markdown'.
    preferred_link_style = "markdown",

    -- Optional, alternatively you can customize the frontmatter data.
    ---@return table
    note_frontmatter_func = function(note)
      if note.title then
        note:add_alias(note.title)
      end

      local out = { id = note.id, aliases = note.aliases, tags = note.tags }

      -- `note.metadata` contains any manually added fields in the frontmatter.
      -- So here we just make sure those fields are kept in the frontmatter.
      if note.metadata ~= nil and not vim.tbl_isempty(note.metadata) then
        for k, v in pairs(note.metadata) do
          out[k] = v
        end
      end

      return out
    end,

    -- Optional, for templates (see below).
    templates = {
      folder = "templates",
      date_format = "%Y-%m-%d",
      time_format = "%H:%M",
      -- A map for custom variables, the key should be the variable and the value a function
      substitutions = {
        year = function()
          return os.date("%Y", os.time())
        end,
        month = function()
          return os.date("%m", os.time())
        end,
        quarter = function()
          local month = os.date("%m", os.time())

          return math.ceil(month / 3)
        end,
        date = function()
          return os.date("%Y-%m-%d", os.time())
        end,
      },
    },

    picker = {
      -- Set your preferred picker. Can be one of 'telescope.nvim', 'fzf-lua', or 'mini.pick'.
      name = "telescope.nvim",
      -- Optional, configure key mappings for the picker. These are the defaults.
      -- Not all pickers support all mappings.
      note_mappings = {
        -- Create a new note from your query.
        new = "<C-x>",
        -- Insert a link to the selected note.
        insert_link = "<C-l>",
      },
      tag_mappings = {
        -- Add tag(s) to current note.
        tag_note = "<C-x>",
        -- Insert a tag at the current location.
        insert_tag = "<C-l>",
      },
    },

    mappings = {
      -- Toggle check-boxes.
      ["<leader>ch"] = {
        action = function()
          return require("obsidian").util.toggle_checkbox()
        end,
        opts = { buffer = true },
      },
      -- Smart action depending on context, either follow link or toggle checkbox.
      ["<cr>"] = {
        action = function()
          return require("obsidian").util.cursor_link_action(function(type, link)
            if type == "link" then
              if not link:match "^s3://" then
                vim.notify("Link is not an S3 URI: " .. link, vim.log.levels.WARN)
                return
              end

              local filename = vim.fn.fnamemodify(link, ":t")
              local output_path = "~/.local/share/obsidian_attachments/" .. filename

              -- if file exists, open it
              if vim.fn.filereadable(output_path) == 1 then
                vim.cmd("open " .. output_path)
                return
              end

              local region = "us-east-2"
              local signed_url = vim.fn.system("aws", "s3", "presign", link, "--region", region, "--expires-in", "10")

              if vim.v.shell_error ~= 0 then
                vim.notify("Failed to create signed URL: " .. signed_url, vim.log.levels.ERROR)
                return
              end

              signed_url = vim.trim(signed_url)
              local output = vim.fn.system("curl", "-L", signed_url, "-o", output_path)

              if vim.v.shell_error ~= 0 then
                vim.notify("Download failed: " .. output, vim.log.levels.ERROR)
                return
              end

              vim.cmd("open " .. output_path)
            end

            return "<cmd>ObsidianToggleCheckbox<CR>"
          end)
        end,
        opts = { buffer = true, expr = true },
      },
    },

    ui = {
      enable = false,
      checkboxes = {
        [" "] = { char = "󰄱", hl_group = "RenderMarkdownUnchecked" },
        ["x"] = { char = "", hl_group = "RenderMarkdownChecked" },
        ["-"] = { char = "󰥔", hl_group = "RenderMarkdownTodo" },
      },
    },

    -- Specify how to handle attachments.
    attachments = {
      upload_func = function(client, source_path)
        local workspace_name = client.current_workspace.name or "personal"
        local bucket = "jiyeol-lee.obsidian-attachments"
        local key = string.format("%s/%s", workspace_name, _make_filename(source_path))
        local s3_uri = string.format("s3://%s/%s", bucket, key)
        local output = vim.fn.system("aws", "s3", "cp", source_path, s3_uri, "--quiet")

        if vim.v.shell_error ~= 0 then
          vim.notify("S3 upload failed: " .. output, vim.log.levels.ERROR)
          return nil
        end

        return s3_uri
      end,

      file_text_func = function(client, path)
        path = client:vault_relative_path(path) or path

        local input = vim.fn.input {
          prompt = "Enter the description for the file: ",
        }

        return string.format("[%s](%s)", input == "" and path.stem or input, path)
      end,

      confirm_paste = false,
    },
  }

  obsidian.setup(setup)
end

return M
