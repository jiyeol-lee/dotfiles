local function run_command(command)
  local handle = io.popen(command)

  if not handle then
    return ""
  end

  local result = handle:read "*a"

  handle:close()

  return result
end

function Git_backup()
  local notify = require "notify"
  local output = run_command "git log --oneline --format=%s -1"
  local current_date = run_command 'date "+%Y-%m-%d %H:%M:%S (%z)"'
  local commit_message = "chore(backup): " .. current_date
  local notify_title = "Git Processing"

  if output == commit_message then
    notify("Amending last commit with new changes", vim.log.levels.INFO, {
      title = notify_title,
      render = "wrapped-compact",
    })
    os.execute "git add -A && git commit --allow-empty --amend --no-edit"
    notify("Pushing changes to remote", vim.log.levels.INFO, {
      title = notify_title,
      render = "wrapped-compact",
    })

    local error_message = nil

    vim.fn.jobstart({ "git", "push", "--force-with-lease" }, {
      stdout_buffered = true,
      stderr_buffered = true,
      on_stderr = function(_, data)
        error_message = data
      end,
      on_exit = function(_, exit_code)
        if exit_code == 0 then
          notify("Changes pushed to remote", vim.log.levels.SUCCESS, {
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
  else
    notify("Creating new commit", vim.log.levels.INFO, {
      title = notify_title,
      render = "wrapped-compact",
    })
    os.execute('git add -A && git commit -m "' .. commit_message .. '"')
    notify("Pushing changes to remote", vim.log.levels.INFO, {
      title = notify_title,
      render = "wrapped-compact",
    })

    local error_message = nil

    vim.fn.jobstart({ "git", "push", "--force-with-lease" }, {
      stdout_buffered = true,
      stderr_buffered = true,
      on_stderr = function(_, data)
        error_message = data
      end,
      on_exit = function(_, exit_code)
        if exit_code == 0 then
          notify("Changes pushed to remote", vim.log.levels.SUCCESS, {
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
end
