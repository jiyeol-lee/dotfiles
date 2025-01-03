local M = {
  "jiyeol-lee/obsidian.nvim",
  version = "*",
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
}

local function rename_current_file(new_name)
  -- Get the current file path
  local current_file = vim.fn.expand('%:p')

  -- Check if the file exists
  if current_file == '' then
    print("No file is currently loaded!")
    return
  end

  -- Get the directory of the current file
  local dir = vim.fn.fnamemodify(current_file, ':h')
  local new_path = dir .. '/' .. new_name

  -- Rename the file
  local success, err = os.rename(current_file, new_path)
  if not success then
    print("Error renaming file: " .. err)
    return
  end

  -- Update the buffer to the new file name
  vim.api.nvim_command('file ' .. new_path)

  -- Reload the buffer to reflect the new file name
  vim.api.nvim_command('edit')
end

local get_note_id_prefix = function(title)
  -- Create note IDs in a Zettelkasten format with a prefix and a timestamp.
  -- In this case a note with the title 'My new note' will be given an ID that looks
  -- like 'my-new-note-1657296016', and therefore the file name 'my-new-note-1657296016.md'
  local prefix = ""
  if title ~= nil then
    -- If title is given, transform it into valid file name.
    prefix = title:gsub(" ", "-"):gsub("[^A-Za-z0-9-]", ""):lower()
  else
    -- If title is nil, just add 4 random uppercase letters to the prefix.
    for _ = 1, 4 do
      prefix = prefix .. string.char(math.random(65, 90))
    end
  end
  return prefix
end

local get_note_id = function(title)
  return get_note_id_prefix(title) .. "-" .. tostring(os.time())
end

vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = "*.md",
  callback = function()
    local Note = require("obsidian.note")
    local client = require("obsidian").get_client()

    local target_dir = vim.fn.expand("~/vaults/") -- Expand '~' to the absolute path
    local full_path = vim.fn.expand('%:p')

    -- Check if the file is under the target directory
    if not full_path:find(target_dir, 1, true) then
      return -- Exit if the file is not under the target directory
    end

    local note = Note.from_file(full_path, client.dir)

    local is_daily_note = false
    for _, v in ipairs(note.tags) do
      if v == "daily-notes" then
        is_daily_note = true
      end
    end

    if is_daily_note then
      return
    end

    local file_name = vim.fn.expand('%:t')
    local pattern = ("^" .. get_note_id_prefix(note.title) .. "-" .. "%d%d%d%d%d%d%d%d%d%d.md$"):gsub("%-", "%%%-")

    if not string.match(file_name, pattern) then
      rename_current_file(get_note_id(note.title) .. ".md")
    end
  end,
})

M.config = function()
  local obsidian = require("obsidian")
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
      template = "daily.md"
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
      if string.match(title, "^%d%d%d%d%-%d%d%-%d%d$") then
        return title
      end
      return get_note_id(title)
    end,

    -- Either 'wiki' or 'markdown'.
    preferred_link_style = "markdown",

    -- Optional, alternatively you can customize the frontmatter data.
    ---@return table
    note_frontmatter_func = function(note)
      if note.title then
        note:add_alias(note.title)
      end

      local id = note.id
      local pattern = ("^" .. get_note_id_prefix(note.title) .. "-" .. "%d%d%d%d%d%d%d%d%d%d$"):gsub("%-", "%%%-")

      if note.title and not string.match(id, pattern) then
        if string.match(note.title, "^%d%d%d%d%-%d%d%-%d%d$") then
          id = note.title
        elseif not string.match(id, pattern) then
          id = get_note_id(note.title)
        end
      end

      local out = { id = id, aliases = note.aliases, tags = note.tags }

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

    -- Optional, by default when you use `:ObsidianFollowLink` on a link to an external
    -- URL it will be ignored but you can customize this behavior here.
    ---@param url string
    follow_url_func = function(url)
      -- Open the URL in the default web browser.
      -- vim.fn.jobstart({ "open", url }) -- Mac OS
      -- vim.fn.jobstart({"xdg-open", url})  -- linux
      -- vim.cmd(':silent exec "!start ' .. url .. '"') -- Windows
      vim.ui.open(url) -- need Neovim 0.10.0+
    end,

    -- Optional, by default when you use `:ObsidianFollowLink` on a link to an image
    -- file it will be ignored but you can customize this behavior here.
    ---@param img string
    follow_img_func = function(img)
      vim.fn.jobstart { "qlmanage", "-p", img } -- Mac OS quick look preview
      -- vim.fn.jobstart({"xdg-open", url})  -- linux
      -- vim.cmd(':silent exec "!start ' .. url .. '"') -- Windows
    end,

    ---@param pdf string
    follow_pdf_func = function(pdf)
      -- os.execute('start "" "' .. pdf .. '"') -- For Windows
      -- os.execute('xdg-open "' .. pdf .. '"')  -- For Linux
      os.execute('open "' .. pdf .. '"') -- For macOS
    end,

    -- Optional, set to true to force ':ObsidianOpen' to bring the app to the foreground.
    open_app_foreground = true,

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
          return require("obsidian").util.smart_action()
        end,
        opts = { buffer = true, expr = true },
      },
    },

    -- Specify how to handle attachments.
    attachments = {
      -- The default folder to place images in via `:ObsidianPasteImg`.
      -- If this is a relative path it will be interpreted as relative to the vault root.
      -- You can always override this per image by passing a full path to the command instead of just a filename.
      img_folder = "assets/images", -- This is the default

      -- Optional, customize the default name or prefix when pasting images via `:ObsidianPasteImg`.
      ---@return string
      img_name_func = function()
        -- Prefix image names with timestamp.
        return string.format("%s-", os.time())
      end,

      -- A function that determines the text to insert in the note when pasting an image.
      -- It takes two arguments, the `obsidian.Client` and an `obsidian.Path` to the image file.
      -- This is the default implementation.
      ---@param client obsidian.Client
      ---@param path obsidian.Path the absolute path to the image file
      ---@return string
      img_text_func = function(client, path)
        path = client:vault_relative_path(path) or path
        return string.format("![%s](%s)", path.name, path)
      end,
    },

  }

  obsidian.setup(setup)
end

return M
