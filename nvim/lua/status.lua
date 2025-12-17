local modes = {
  n = { "N", "StModeNormal" },
  i = { "I", "StModeInsert" },
  v = { "V", "StModeVisual" },
  V = { "VL", "StModeVisual" },
  [""] = { "VB", "StModeVisual" },
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
  hl("StModeNormalPill", { fg = "#89b4fa", })
  hl("StModeInsertPill", { fg = "#a6e3a1", })
  hl("StModeVisualPill", { fg = "#fab387", })
  hl("StModeCommandPill", { fg = "#f9e2af", })
  hl("StModeReplacePill", { fg = "#f38ba8", })
  hl("StModeTerminalPill", { fg = "#94e2d5", })

  hl("StGitClean", { fg = "#a6e3a1", })
  hl("StGitUncommitted", { fg = "#f9e2af", })
  hl("StGitDirty", { fg = "#f38ba8", })
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

local cache = require('cache')
local utils = require('utils')

local status_cache = cache.new()

local git = status_cache:async_wrap("git", utils.git_status, 30, { s = "%#StInfo#...%*", w = 7 }, function()
  vim.cmd("redrawstatus")
end)

local file = status_cache:wrap("file", function()
  local name = vim.fn.expand("%:t")
  if name == "" then
    return { s = "", ls = "", w = 0, lw = 0 }
  else
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
end)

local diagnostics = status_cache:wrap("diagnostics", function()
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
  return { s = table.concat(parts), w = w }
end)

local lsp_status = status_cache:wrap("lsp", function()
  local names = {}
  local w = 0
  local clients = vim.lsp.get_clients({ bufnr = 0 })
  for _, c in ipairs(clients) do
    table.insert(names, c.name)
    w = w + #c.name + 2
  end
  return { s = "%#StInfo#" .. table.concat(names, ",") .. "%*", w = w }
end
)

local debounce_redraw_status = utils.debounce()
local function redraw_status(timeout, fetch)
  debounce_redraw_status(timeout, function()
    status_cache:invalidate('git')
    status_cache:invalidate('file')
    status_cache:invalidate('diagnostics')
    status_cache:invalidate('lsp')
    if fetch then
      utils.git_fetch(function() vim.cmd("redrawstatus") end)
    end
    vim.cmd("redrawstatus")
  end)
end

vim.api.nvim_create_autocmd({ "BufEnter", "DirChanged" }, { callback = function() redraw_status(500, true) end })
vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, { callback = function() redraw_status(2000, false) end })
vim.api.nvim_create_autocmd(
  { "BufNewFile", "BufReadPost", "BufWritePost", "FocusGained", "DiagnosticChanged", "LspAttach", "LspDetach", },
  { callback = function() redraw_status(500, false) end })

-- Assemble statusline
local M = {}
function M.statusline()
  local winid             = vim.g.statusline_winid
  local active            = (winid == vim.api.nvim_get_current_win())
  local m                 = modes[vim.fn.mode()]
  local mode_str, mode_hl = m and m[1] or vim.fn.mode(), m and m[2] or "StModeNormal"
  local mode              = "%#" .. mode_hl .. "Pill#%#" .. mode_hl .. "#" .. mode_str .. "%#" .. mode_hl .. "Pill#%*"

  if not active or mode_str == "T" then
    return mode
  else
    local cl = vim.fn.line(".")
    local lt = vim.fn.line("$")
    local lp = lt > 0 and math.floor(cl / lt * 100) or 0
    local lc = "%#StInfo#" .. lp .. "%% " .. cl .. ":" .. vim.fn.col(".") .. "%*"
    local f  = file()
    local d  = diagnostics()
    local l  = lsp_status()
    -- async status
    git()
    local g = status_cache:get('git') or { s = "...", w = 3 }

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
