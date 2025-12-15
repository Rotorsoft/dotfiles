local async = require('async')

local M = {}

function M.git_fetch(done)
  async.system_cmd('git -C "$(git rev-parse --show-toplevel)" fetch --quiet', function()
    done()
  end)
end

function M.git_status(done)
  local status_cmd = 'git -C "$(git rev-parse --show-toplevel)" status --porcelain=2 --branch'
  async.system_cmd(status_cmd, function(status_lines, status_code)
    if status_code ~= 0 or #status_lines == 0 then
      return done({ s = "", w = 0 })
    end

    local parts = {}
    local branch = ""
    local w = 0
    local untracked, unstaged, staged, ahead, behind = 0, 0, 0, 0, 0
    local abfound = false
    for _, line in ipairs(status_lines) do
      if line:match("^? ") then
        untracked = untracked + 1
      elseif line:match("^[12] ") then
        local xy = line:sub(3, 4) -- the XY status code
        local x, y = xy:sub(1, 1), xy:sub(2, 2)
        if x ~= "." then
          staged = staged + 1
        end
        if y ~= "." then
          unstaged = unstaged + 1
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
        end
      end
    end

    local status = ""
    if untracked + ahead + behind > 0 then
      status = status .. "%#StGitConflict#"
      if untracked > 0 then
        status = status .. "?" .. untracked
        w = w + 2
      end
      if behind > 0 then
        status = status .. "↓" .. behind
        w = w + 2
      end
      if ahead > 0 then
        status = status .. "↑" .. ahead
        w = w + 2
      end
      status = status .. "%*"
    end
    if staged + unstaged > 0 then
      status = status .. "%#StGitDirty#[" .. staged .. "/" .. staged + unstaged .. "]%*"
      w = w + 6
    end

    local function finalize(added, removed)
      if staged + unstaged + added + removed > 0 then
        table.insert(parts, status .. "%#StGitDirty# " .. branch .. "%*")
      else
        table.insert(parts, status .. "%#StGitClean# " .. branch .. "%*")
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
    if buf_path ~= "" then
      local diff_cmd = "git diff --numstat " .. vim.fn.shellescape(buf_path)
      async.system_cmd(diff_cmd, function(diff_lines)
        local added, removed = 0, 0
        for _, line in ipairs(diff_lines) do
          local a, r = line:match("(%d+)%s+(%d+)")
          if a and r then
            added = tonumber(a)
            removed = tonumber(r)
            break
          end
        end
        finalize(added, removed)
      end)
    else
      finalize(0, 0)
    end
  end)
end

return M
