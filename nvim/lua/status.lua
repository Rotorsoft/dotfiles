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
end

-- Git branch
local function git_branch()
  local branch = vim.b.gitsigns_head
  if not branch or branch == "" then return "" end

  local dict = vim.b.gitsigns_status_dict
  local group = "StGitClean"
  if dict then
    if (dict.added and dict.added > 0) or (dict.changed and dict.changed > 0) or (dict.removed and dict.removed > 0) then
      group = "StGitDirty"
    end
  end
  return "%#" .. group .. "#  " .. branch .. "%*"
end

-- Git diff counts
local function git_diff()
  local gitsigns = vim.b.gitsigns_status_dict
  if not gitsigns then return "" end
  local out = ""
  if gitsigns.added and gitsigns.added > 0 then
    out = out .. "%#StGitAdd#+" .. gitsigns.added .. " %*"
  end
  if gitsigns.changed and gitsigns.changed > 0 then
    out = out .. "%#StGitChange#~" .. gitsigns.changed .. " %*"
  end
  if gitsigns.removed and gitsigns.removed > 0 then
    out = out .. "%#StGitDelete#-" .. gitsigns.removed .. " %*"
  end
  return out
end

-- Filename with status
local function filename()
  local name = vim.fn.expand("%:~:.")
  if name == "" then name = "∅" end
  if vim.bo.modified then
    name = name .. " "
  end
  if not vim.bo.modifiable or vim.bo.readonly then
    name = name .. " "
  end
  return "%#StInfo#" .. name .. "%*"
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

  for _, item in ipairs(groups) do
    local severity, hl_group = item[1], item[2]
    local n = #vim.diagnostic.get(bufnr, { severity = severity })
    if n > 0 then
      table.insert(parts, "%#" .. hl_group .. "#" .. (signs[severity] or "") .. n .. "%* ")
    end
  end
  return table.concat(parts)
end

-- LSP client names
local function lsp_status()
  local clients = vim.lsp.get_clients({ bufnr = 0 })
  if #clients == 0 then return "" end
  local names = {}
  for _, c in ipairs(clients) do table.insert(names, c.name) end
  return "%#StInfo#" .. table.concat(names, ",") .. "%*"
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
  local winid = vim.g.statusline_winid
  local active = (winid == vim.api.nvim_get_current_win())

  if not active then
    -- inactive windows: just show mode
    local m = modes[vim.fn.mode()]
    local mode_str, mode_hl = m and m[1] or vim.fn.mode(), m and m[2] or "StModeNormal"
    return ("%#%s# %s %*"):format(mode_hl, mode_str)
  end

  -- active window: full statusline
  local m = modes[vim.fn.mode()]
  local mode_str, mode_hl = m and m[1] or vim.fn.mode(), m and m[2] or "StModeNormal"

  return table.concat({
    "%#", mode_hl, "# ", mode_str, " %*",
    git_branch(), " ",
    git_diff(),
    filename(), "%=",
    diagnostics(),
    lsp_status(), " ",
    filesize(), progress(), " ",
    location(),
  })
end

function M.setup()
  setup_highlights()
  vim.o.laststatus = 3 -- globalstatus
  vim.o.statusline = "%!v:lua.require'status'.statusline()"
end

return M
