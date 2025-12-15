local M = {}

--- Returns a new debouncer instance. A debouncer will delay execution of a function
--- until a certain amount of time has passed without it being called.
---
--- Usage:
--- local debounce = require('async').debounce()
--- -- somewhere in hot path
--- debounce(500, function() print("This will only run once, 500ms after the last call") end)
function M.debounce()
  local timer
  return function(delay, fn)
    if timer then
      timer:close()
    end
    timer = vim.defer_fn(function()
      timer = nil
      fn()
    end, delay)
  end
end

--- Runs a shell command asynchronously and returns the output via a callback.
--- @param cmd string The command to run.
--- @param on_done function A callback function that receives `(lines, code)`, where `lines` is a table of stdout lines and `code` is the exit code.
function M.system_cmd(cmd, on_done)
  local stdout_lines = {}
  vim.fn.jobstart(cmd, {
    on_stdout = function(_, data)
      for _, line in ipairs(data) do
        if line ~= "" then
          table.insert(stdout_lines, line)
        end
      end
    end,
    on_exit = function(_, code)
      on_done(stdout_lines, code)
    end,
    -- Make sure stderr is not printed to the user
    stderr_piped = true,
    on_stderr = function() end,
  })
end

return M
