local M = {}

local cache = {
  git = nil,
  file = nil,
  diagnostics = nil,
  lsp = nil,
}

local modes = {
  n = { "N", "StModeNormal" },
  i = { "I", "StModeInsert" },
  v = { "V", "StModeVisual" },
  V = { "V-L", "StModeVisual" },
  [""] = { "V-B", "StModeVisual" },
  c = { "C", "StModeCommand" },
  R = { "R", "StModeReplace" },
  t = { "T", "StModeTerminal" },
}
local fg = "#1e1e2e"

local function setup_highlights()
  local hl = function(group, opts)
    vim.api.nvim_set_hl(0, group, opts)
  end

  hl("StModeNormal", { fg = fg, bg = "#89b4fa", bold = true })
  hl("StModeInsert", { fg = fg, bg = "#a6e3a1", bold = true })
  hl("StModeVisual", { fg = fg, bg = "#fab387", bold = true })
  hl("StModeCommand", { fg = fg, bg = "#f9e2af", bold = true })
  hl("StModeReplace", { fg = fg, bg = "#f38ba8", bold = true })
  hl("StModeTerminal", { fg = fg, bg = "#94e2d5", bold = true })

  hl("StGitClean", { fg = "#a6e3a1", })
  hl("StGitDirty", { fg = "#f9e2af", })
  hl("StGitConflict", { fg = "#f38ba8", })
  hl("StGitAdd", { fg = "#a6e3a1" })
  hl("StGitChange", { fg = "#fab387" })
  hl("StGitDelete", { fg = "#f38ba8" })

  hl("StDiagError", { fg = "#f38ba8" })
  hl("StDiagWarn", { fg = "#f9e2af" })
  hl("StDiagInfo", { fg = "#89b4fa" })
  hl("StDiagHint", { fg = "#94e2d5" })

  hl("StInfo", { fg = "#6c7086", bg = "NONE", bold = false })
  hl("StInfoModified", { fg = "#7d8197", bg = "NONE", bold = false, italic = true })
end

local function git()
  if cache.git then return cache.git end

  local output = vim.fn.systemlist('git -C "$(git rev-parse --show-toplevel)" status --porcelain=2 --branch 2>/dev/null')
  if vim.v.shell_error ~= 0 or #output == 0 then
    cache.git = { s = "", w = 0 }
    return cache.git
  end

  local parts = {}
  local branch = ""
  local w = 0
  local untracked, unstaged, staged, ahead, behind = 0, 0, 0, 0, 0
  local abfound = false
  for _, line in ipairs(output) do
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

  local added, removed = 0, 0
  local buf_path = vim.api.nvim_buf_get_name(0)
  if buf_path ~= "" then
    local changes = vim.fn.systemlist("git diff --numstat " .. vim.fn.shellescape(buf_path))
    for _, line in ipairs(changes) do
      local a, r = line:match("(%d+)%s+(%d+)")
      if a and r then
        added = tonumber(a)
        removed = tonumber(r)
        break
      end
    end
  end

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

  cache.git = { s = table.concat(parts, ""), w = w }
  return cache.git
end

local function file()
  if cache.file then return cache.file end

  local name = vim.fn.expand("%:t")
  if name == "" then
    cache.file = { s = "", ls = "", w = 0, lw = 0 }
  else
    local path = vim.fn.expand("%:~:.")
    local group = "StInfo"
    if vim.bo.modified then group = "StInfoModified" end
    cache.file = {
      s = "%#" .. group .. "#" .. name .. "%*",
      ls = "%#" .. group .. "#" .. path .. "%*",
      w = #name,
      lw = #path
    }
  end
  return cache.file
end

local diagnostic_hl_groups = {
  { vim.diagnostic.severity.ERROR, "StDiagError" },
  { vim.diagnostic.severity.WARN,  "StDiagWarn" },
  { vim.diagnostic.severity.INFO,  "StDiagInfo" },
  { vim.diagnostic.severity.HINT,  "StDiagHint" },
}
local diagnostic_signs = {
  [vim.diagnostic.severity.ERROR] = "E",
  [vim.diagnostic.severity.WARN] = "W",
  [vim.diagnostic.severity.INFO] = "I",
  [vim.diagnostic.severity.HINT] = "H",
}

-- Diagnostics (only show if > 0)
local function diagnostics()
  if cache.diagnostics then return cache.diagnostics end

  local counts = vim.diagnostic.count(0)
  local w = 0
  local parts = {}
  for _, item in pairs(diagnostic_hl_groups) do
    local severity, hl_group = item[1], item[2]
    local n = counts[severity] or 0
    if n > 0 then
      table.insert(parts, "%#" .. hl_group .. "#" .. diagnostic_signs[severity] .. n .. "%* ")
      w = w + 3
    end
  end

  cache.diagnostics = { s = table.concat(parts), w = w }
  return cache.diagnostics
end

-- LSP client names
local function lsp_status()
  if cache.lsp then return cache.lsp end

  local names = {}
  local w = 0
  local clients = vim.lsp.get_clients({ bufnr = 0 })
  for _, c in ipairs(clients) do
    table.insert(names, c.name)
    w = w + #c.name + 2
  end

  cache.lsp = { s = "%#StInfo#" .. table.concat(names, ",") .. "%*", w = w }
  return cache.lsp
end

-- Invalidate caches
local debounce = nil
local fetch_next = false
local last_fetched = 0
local redrawn, fetched = 0, 0
local function invalidate()
  if fetch_next then
    fetch_next = false
    local now = os.time()
    if now - last_fetched > 300 then -- fetch in 5 minute intervals
      vim.fn.system('git -C "$(git rev-parse --show-toplevel)" fetch --quiet')
      fetched = fetched + 1
      last_fetched = now
    end
  end
  cache.git = nil
  cache.diagnostics = nil
  debounce = nil
  redrawn = redrawn + 1
  vim.cmd("redrawstatus")
end
local function schedule(timeout, fetch)
  cache.file = nil
  if fetch then fetch_next = true end
  if debounce then
    debounce:close()
    debounce = nil
  end
  debounce = vim.defer_fn(invalidate, timeout)
end
vim.api.nvim_create_autocmd({ "BufEnter", "DirChanged" }, { callback = function() schedule(500, true) end })
vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, { callback = function() schedule(5000, false) end })
vim.api.nvim_create_autocmd(
  { "BufNewFile", "BufReadPost", "BufWritePost", "FocusGained", "DiagnosticChanged", "LspAttach", "LspDetach", },
  { callback = function() schedule(1000, false) end })

-- Assemble statusline
function M.statusline()
  local winid             = vim.g.statusline_winid
  local active            = (winid == vim.api.nvim_get_current_win())
  local m                 = modes[vim.fn.mode()]
  local mode_str, mode_hl = m and m[1] or vim.fn.mode(), m and m[2] or "StModeNormal"
  local mode              = "%#" .. mode_hl .. "# " .. mode_str .. " %*"
  --local mode              = "%#" .. mode_hl .. "# " .. mode_str .. "/" .. redrawn .. "/" .. fetched .. " %*"

  if not active or mode_str == "T" then
    return mode
  else
    local cl   = vim.fn.line(".")
    local lt   = vim.fn.line("$")
    local lp   = lt > 0 and math.floor(cl / lt * 100) or 0
    local lc   = "%#StInfo#" .. lp .. "%% " .. cl .. ":" .. vim.fn.col(".") .. "%*"
    local g    = git()
    local f    = file()
    local d    = diagnostics()
    local l    = lsp_status()

    -- trim to cols
    local cols = vim.o.columns - 10 - 4 -- 10 for mode and location, 4 for progress
    if g.w + f.lw + d.w + l.w < cols then
      return mode .. " " .. g.s .. " " .. f.ls .. "%=" .. d.s .. l.s .. " " .. lc
    elseif g.w + f.w + d.w + l.w < cols then
      return mode .. " " .. g.s .. " " .. f.s .. "%=" .. d.s .. l.s .. " " .. lc
    elseif f.w + d.w < cols then
      return mode .. " " .. f.s .. "%=" .. d.s .. lc
    else
      return mode .. " " .. f.s .. "%=" .. lc
    end
  end
end

function M.setup()
  setup_highlights()
  vim.o.laststatus = 3 -- globalstatus
  vim.o.statusline = "%!v:lua.require'status'.statusline()"
end

return M
