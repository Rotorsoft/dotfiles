local M = {}

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

function M.syscmd(cmd, done)
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
      done(stdout_lines, code)
    end,
    -- Make sure stderr is not printed to the user
    stderr_piped = true,
    on_stderr = function() end,
  })
end

function M.git_fetch(done)
  M.syscmd('git -C "$(git rev-parse --show-toplevel)" fetch --quiet', done)
end

function M.git_status(done)
  local status_cmd = 'git -C "$(git rev-parse --show-toplevel)" status --porcelain=2 --branch'
  M.syscmd(status_cmd, function(status_lines, status_code)
    if status_code ~= 0 or #status_lines == 0 then
      return done({ s = "", w = 0 })
    end

    local parts = {}
    local branch = ""
    local w = 0
    local untracked, ahead, behind = 0, 0, 0
    local uncommitted, dirty = false, false
    local changes = { A = { staged = 0, unstaged = 0 }, M = { staged = 0, unstaged = 0 }, D = { staged = 0, unstaged = 0 }, R = { staged = 0, unstaged = 0 } }
    local abfound = false
    for _, line in ipairs(status_lines) do
      if line:match("^? ") then
        dirty = true
        untracked = untracked + 1
      elseif line:match("^[12] ") then
        local xy = line:sub(3, 4) -- the XY status code
        local x, y = xy:sub(1, 1), xy:sub(2, 2)
        if x ~= "." then
          uncommitted = true
          changes[x].staged = changes[x].staged + 1
        end
        if y ~= "." then
          dirty = true
          changes[y].unstaged = changes[y].unstaged + 1
        end
      elseif branch == "" then
        local b = line:match("^# branch.head")
        if b then
          branch = line:match("head%s+(%S+)")
          w = #branch + 2
        end
      elseif not abfound then
        local a, b = line:match("^# branch%.ab%s%+(%d+)%s%-(%d+)")
        if a and b then
          abfound = true
          ahead = tonumber(a)
          behind = tonumber(b)
          if behind > 0 then
            dirty = true
          elseif ahead > 0 then
            uncommitted = true
          end
        end
      end
    end

    local status = ""
    if dirty then
      status = status .. "%#StGitDirty#"
      if behind > 0 then
        status = status .. "󰜮" .. behind .. " "
        w = w + 3
      end
      if changes.A.unstaged > 0 then
        status = status .. "+" .. changes.A.unstaged
        w = w + 2
      end
      if changes.M.unstaged > 0 then
        status = status .. "~" .. changes.M.unstaged
        w = w + 2
      end
      if changes.D.unstaged > 0 then
        status = status .. "-" .. changes.D.unstaged
        w = w + 2
      end
      if changes.R.unstaged > 0 then
        status = status .. "r" .. changes.R.unstaged
        w = w + 2
      end
      if untracked > 0 then
        status = status .. "?" .. untracked
        w = w + 2
      end
      status = status .. "%*"
    end
    if uncommitted then
      if dirty then status = status .. " " end
      status = status .. "%#StGitUncommitted#"
      if ahead > 0 then
        status = status .. "󰜷" .. ahead .. " "
        w = w + 3
      end
      if changes.A.staged > 0 then
        status = status .. "+" .. changes.A.staged
        w = w + 2
      end
      if changes.M.staged > 0 then
        status = status .. "~" .. changes.M.staged
        w = w + 2
      end
      if changes.D.staged > 0 then
        status = status .. "-" .. changes.D.staged
        w = w + 2
      end
      if changes.R.staged > 0 then
        status = status .. "r" .. changes.R.staged
        w = w + 2
      end
      status = status .. "%*"
    end

    local function finalize(added, removed)
      if dirty then
        table.insert(parts, "%#StGitDirty# " .. branch .. " " .. status .. " %*")
      elseif uncommitted then
        table.insert(parts, "%#StGitUncommitted# " .. branch .. " " .. status .. " %*")
      else
        table.insert(parts, "%#StGitClean# " .. branch .. "%*")
      end

      local changes = ""
      if added > 0 then
        changes = changes .. "%#StGitAdd#+" .. added .. "%*"
        w = w + 3
      end
      if removed > 0 then
        changes = changes .. "%#StGitDelete#-" .. removed .. "%*"
        w = w + 3
      end
      table.insert(parts, changes)

      done({ s = table.concat(parts, ""), w = w })
    end

    local buf_path = vim.api.nvim_buf_get_name(0)
    local diff_cmd = "git diff --numstat " .. vim.fn.shellescape(buf_path)
    M.syscmd(diff_cmd, function(diff_lines)
      local added, removed = 0, 0
      for _, line in ipairs(diff_lines) do
        local a, r = line:match("(%d+)%s+(%d+)")
        if a and r then
          added = added + tonumber(a)
          removed = removed + tonumber(r)
        end
      end
      finalize(added, removed)
    end)
  end)
end

return M
