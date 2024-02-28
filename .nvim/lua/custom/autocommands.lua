local function is_in_xxx_directory(directory_name, file_path)
  local pattern = "^(.-/?)" .. directory_name .. "/.+%.md$"

  return string.match(file_path, pattern) ~= nil
end

local function get_xxx_directory(directory_name, file_path)
  local pattern = "(.-" .. directory_name .. ")/"
  local match = string.match(file_path, pattern)
  if match then
    -- Return the match including 'xxx'
    return match
  else
    -- Return nil if 'xxx' is not found in the path
    return nil
  end
end

local buf_hash = {}

vim.api.nvim_create_autocmd("BufEnter", {
  pattern = "*",
  callback = function()
    local file_path = vim.api.nvim_buf_get_name(0)

    if is_in_xxx_directory("vpersonal", file_path) then
      local vault_personal_root = get_xxx_directory("vpersonal", file_path)
      -- Set current directory to vpersonal root
      vim.api.nvim_set_current_dir(vault_personal_root)
    elseif is_in_xxx_directory("vwork2", file_path) then
      local vault_work_root = get_xxx_directory("vwork2", file_path)
      -- Set current directory to vwork2 root
      vim.api.nvim_set_current_dir(vault_work_root)
    elseif is_in_xxx_directory("vwork3", file_path) then
      local vault_work_root = get_xxx_directory("vwork3", file_path)
      -- Set current directory to vwork3 root
      vim.api.nvim_set_current_dir(vault_work_root)
    elseif is_in_xxx_directory("dotfiles", file_path) then
      local dotfiles_root = get_xxx_directory("dotfiles", file_path)
      -- Set current directory to dotfiles root
      vim.api.nvim_set_current_dir(dotfiles_root)
    else
      local bufnr = vim.api.nvim_get_current_buf()
      local current_dir = vim.fn.getcwd()

      if buf_hash[bufnr] ~= nil then
        if buf_hash[bufnr] ~= current_dir then
          -- Set current directory to saved directory
          vim.api.nvim_set_current_dir(buf_hash[bufnr])
        end
      else
        buf_hash[bufnr] = current_dir
      end
    end
  end,
})
