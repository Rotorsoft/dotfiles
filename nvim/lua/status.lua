local M = {}

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

-- Git branch
local function git_branch()
  local branch = vim.b.gitsigns_head
  if not branch or branch == "" then
    return { s = "", w = 0 }
  end

  local dict = vim.b.gitsigns_status_dict or {}
  local parts = {}
  local w = #branch + 2

  -- Staged changes (use git diff --cached)
  local staged_str = ""
  local staged = vim.fn.systemlist("git diff --cached --numstat 2>/dev/null")
  local staged_added, staged_changed, staged_removed = 0, 0, 0
  for _, line in ipairs(staged) do
    local added, removed = line:match("(%d+)%s+(%d+)%s+")
    added, removed = tonumber(added), tonumber(removed)
    if added and added > 0 then staged_added = staged_added + added end
    if removed and removed > 0 then staged_removed = staged_removed + removed end
    if added and removed and added > 0 and removed > 0 then staged_changed = staged_changed + 1 end
  end
  if staged_added > 0 then
    staged_str = staged_str .. "%#StGitAdd#+" .. staged_added .. "%*"
    w = w + 2
  end
  if staged_changed > 0 then
    staged_str = staged_str .. "%#StGitChange#~" .. staged_changed .. "%*"
    w = w + 2
  end
  if staged_removed > 0 then
    staged_str = staged_str .. "%#StGitDelete#-" .. staged_removed .. "%*"
    w = w + 2
  end
  table.insert(parts, staged_str)

  -- Ahead/behind upstream
  local conflicts_str = ""
  local upstream_exists = vim.fn.system("git rev-parse --abbrev-ref --symbolic-full-name @{upstream} 2>/dev/null")
  if vim.v.shell_error ~= 0 or upstream_exists == "" then
    conflicts_str = "↑?"
    w = w + 2
  else
    local ahead_behind = vim.fn.systemlist(
      "git rev-list --left-right --count @{upstream}...HEAD 2>/dev/null"
    )[1]
    if ahead_behind then
      local behind, ahead = ahead_behind:match("(%d+)%s+(%d+)")
      behind, ahead = tonumber(behind), tonumber(ahead)
      if behind and behind > 0 then
        conflicts_str = conflicts_str .. "↓" .. behind
        w = w + 2
      end
      if ahead and ahead > 0 then
        conflicts_str = conflicts_str .. "↑" .. ahead
        w = w + 2
      end
    end
  end

  -- Determine branch highlight
  local group = "StGitClean"
  if conflicts_str ~= "" then
    group = "StGitConflict"
  elseif (dict.added or 0) + (dict.changed or 0) + (dict.removed or 0) > 0 then
    group = "StGitDirty"
  end
  -- Branch name with conflicts prepended and icon
  table.insert(parts, "%#" .. group .. "#" .. conflicts_str .. " " .. branch .. "%*")

  return { s = table.concat(parts, ""), w = w }
end

-- Git diff counts
local function git_diff()
  local gitsigns = vim.b.gitsigns_status_dict
  if not gitsigns then return { s = "", w = 0 } end

  local out = ""
  local w = 0
  if gitsigns.added and gitsigns.added > 0 then
    out = out .. "%#StGitAdd#+" .. gitsigns.added .. "%*"
    w = w + 3
  end
  if gitsigns.changed and gitsigns.changed > 0 then
    out = out .. "%#StGitChange#~" .. gitsigns.changed .. "%*"
    w = w + 3
  end
  if gitsigns.removed and gitsigns.removed > 0 then
    out = out .. "%#StGitDelete#-" .. gitsigns.removed .. "%*"
    w = w + 3
  end
  return { s = out, w = w }
end

-- Filename with status
local function filename()
  local name = vim.fn.expand("%:t")
  if name == "" then
    return { s = "", ls = "", w = 0, lw = 0 }
  end
  local path = vim.fn.expand("%:~:.")
  local group = "StInfo"
  if vim.bo.modified then group = "StInfoModified" end
  return {
    s = "%#" .. group .. "#" .. name .. "%*",
    ls = "%#" .. group .. "#" .. path .. "%*",
    w = #name,
    lw = #path
  }
end

-- Diagnostics (only show if > 0)
local function diagnostics()
  local bufnr = vim.api.nvim_get_current_buf()
  local parts = {}
  local groups = {
    { vim.diagnostic.severity.ERROR, "StDiagError" },
    { vim.diagnostic.severity.WARN,  "StDiagWarn" },
    { vim.diagnostic.severity.INFO,  "StDiagInfo" },
    { vim.diagnostic.severity.HINT,  "StDiagHint" },
  }
  local signs = vim.diagnostic.config().signs.text or {}
  local w = 0

  for _, item in ipairs(groups) do
    local severity, hl_group = item[1], item[2]
    local n = #vim.diagnostic.get(bufnr, { severity = severity })
    if n > 0 then
      table.insert(parts, "%#" .. hl_group .. "#" .. (signs[severity] or "") .. n .. "%* ")
      w = w + 3
    end
  end
  return { s = table.concat(parts), w = w }
end

-- LSP client names
local function lsp_status()
  local clients = vim.lsp.get_clients({ bufnr = 0 })
  if #clients == 0 then return { s = "", w = 0 } end
  local names = {}
  local w = 0
  for _, c in ipairs(clients) do
    table.insert(names, c.name)
    w = w + #c.name + 2
  end
  return { s = "%#StInfo#" .. table.concat(names, ",") .. "%*", w = w }
end

-- Filesize
local function filesize()
  local size = vim.fn.getfsize(vim.fn.expand("%:p"))
  if size < 0 then return "" end
  local sizestr
  if size < 1024 then
    sizestr = size .. "B"
  elseif size < 1024 * 1024 then
    sizestr = string.format("%.1fK", size / 1024)
  else
    sizestr = string.format("%.1fM", size / (1024 * 1024))
  end
  return "%#StInfo#" .. sizestr .. "%*"
end

-- Progress (% through file)
local function progress()
  local cur = vim.fn.line(".")
  local total = vim.fn.line("$")
  local p = total > 0 and math.floor(cur / total * 100) or 0
  return "%#StInfo#/" .. p .. "%%" .. "%*"
end

-- Cursor location
local function location()
  return "%#StInfo#" .. vim.fn.line(".") .. ":" .. vim.fn.col(".") .. "%*"
end

-- Assemble statusline
function M.statusline()
  local winid             = vim.g.statusline_winid
  local active            = (winid == vim.api.nvim_get_current_win())
  local m                 = modes[vim.fn.mode()]
  local mode_str, mode_hl = m and m[1] or vim.fn.mode(), m and m[2] or "StModeNormal"
  local mode              = "%#" .. mode_hl .. "# " .. mode_str .. " %*"

  if not active or mode_str == "T" then
    return mode
  else
    local cols = vim.o.columns - 10 - 10 -- 10 for mode and location, 10 for size
    local lc   = location()
    local gb   = git_branch()
    local gd   = git_diff()
    local fn   = filename()
    local dd   = diagnostics()
    local ls   = lsp_status()
    local fs   = filesize() .. progress() .. " "

    -- trim to cols
    if gb.w + gd.w + fn.lw + dd.w + ls.w < cols then
      return mode .. " " .. gb.s .. gd.s .. " " .. fn.ls .. "%=" .. dd.s .. ls.s .. " " .. fs .. lc
    elseif gb.w + gd.w + fn.w + dd.w + ls.w < cols then
      return mode .. " " .. gb.s .. gd.s .. " " .. fn.s .. "%=" .. dd.s .. ls.s .. " " .. fs .. lc
    elseif fn.w + dd.w < cols then
      return mode .. " " .. fn.s .. "%=" .. dd.s .. fs .. lc
    else
      return mode .. " " .. fn.s .. "%=" .. lc
    end
  end
end

function M.setup()
  setup_highlights()
  vim.o.laststatus = 3 -- globalstatus
  vim.o.statusline = "%!v:lua.require'status'.statusline()"
end

return M
