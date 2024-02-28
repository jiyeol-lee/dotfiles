function Git_force_sync()
  local notify = require "notify"
  local notify_title = "Git Processing"

  notify("Syncing remote changes to local", vim.log.levels.INFO, {
    title = notify_title,
    render = "wrapped-compact",
  })
  os.execute "git reset --hard origin/HEAD"

  local error_message = nil

  vim.fn.jobstart({ "git", "pull", "--no-edit" }, {
    stdout_buffered = true,
    stderr_buffered = true,
    on_stderr = function(_, data)
      error_message = data
    end,
    on_exit = function(_, exit_code)
      if exit_code == 0 then
        notify("Sync remote changes to local successfully", vim.log.levels.SUCCESS, {
          title = notify_title,
          render = "wrapped-compact",
        })
      else
        if error_message then
          notify(error_message, vim.log.levels.ERROR, {
            title = notify_title,
            render = "wrapped-compact",
          })
        end
      end
    end,
  })
end
