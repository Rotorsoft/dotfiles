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

local function get_fg(group)
  local h = vim.api.nvim_get_hl(0, { name = group, link = false })
  return h.fg and string.format("#%06x", h.fg) or nil
end

local function get_bg(group)
  local h = vim.api.nvim_get_hl(0, { name = group, link = false })
  return h.bg and string.format("#%06x", h.bg) or nil
end

local function setup_highlights()
  local hl = function(group, opts)
    vim.api.nvim_set_hl(0, group, opts)
  end

  local bg = get_bg("Normal") or "#1e1e2e"
  local dim = get_fg("Comment") or "#6c7086"

  -- Fixed mode / status colors (scheme-independent)
  local normal = "#89b4fa"
  local insert = "#a6e3a1"
  local visual = "#fab387"
  local command = "#f9e2af"
  local replace = "#f38ba8"
  local terminal = "#94e2d5"

  hl("StModeNormal", { fg = bg, bg = normal, bold = true })
  hl("StModeInsert", { fg = bg, bg = insert, bold = true })
  hl("StModeVisual", { fg = bg, bg = visual, bold = true })
  hl("StModeCommand", { fg = bg, bg = command, bold = true })
  hl("StModeReplace", { fg = bg, bg = replace, bold = true })
  hl("StModeTerminal", { fg = bg, bg = terminal, bold = true })
  hl("StModeNormalPill", { fg = normal })
  hl("StModeInsertPill", { fg = insert })
  hl("StModeVisualPill", { fg = visual })
  hl("StModeCommandPill", { fg = command })
  hl("StModeReplacePill", { fg = replace })
  hl("StModeTerminalPill", { fg = terminal })

  hl("StGitClean", { fg = insert })
  hl("StGitUncommitted", { fg = command })
  hl("StGitDirty", { fg = replace })
  hl("StGitAdd", { fg = insert })
  hl("StGitChange", { fg = visual })
  hl("StGitDelete", { fg = replace })

  hl("StDiagError", { fg = replace })
  hl("StDiagWarn", { fg = command })
  hl("StDiagInfo", { fg = normal })
  hl("StDiagHint", { fg = terminal })

  hl("StInfo", { fg = dim, bg = "NONE", bold = false })
  hl("StInfoModified", { fg = dim, bg = "NONE", bold = false, italic = true })
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
      utils.git_fetch(function()
        status_cache:invalidate('git')
        vim.cmd("redrawstatus")
      end)
    end
    vim.cmd("redrawstatus")
  end)
end

vim.api.nvim_create_autocmd(
  { "BufEnter", "DirChanged", "BufNewFile", "BufReadPost", "BufWritePost", "FocusGained", "DiagnosticChanged", "LspAttach", "LspDetach" },
  { callback = function(args)
    local fetch = args.event == "BufEnter" or args.event == "DirChanged"
    redraw_status(500, fetch)
  end })
vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, { callback = function() redraw_status(2000, false) end })

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
  vim.api.nvim_create_autocmd("ColorScheme", { callback = setup_highlights })
  vim.o.laststatus = 3 -- globalstatus
  vim.o.statusline = "%!v:lua.require'status'.statusline()"
end

return M
