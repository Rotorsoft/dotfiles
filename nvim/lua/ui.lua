local M = {}

local function apply()
  local hl = vim.api.nvim_set_hl
  local function get_fg(group)
    local h = vim.api.nvim_get_hl(0, { name = group, link = false })
    return h.fg and string.format("#%06x", h.fg) or nil
  end

  local text = get_fg("Normal")
  local dim = get_fg("Comment")
  local sel_bg = get_fg("Visual") or dim

  -- Transparent / minimal chrome
  hl(0, "CursorLine", { bg = "none" })
  hl(0, "CursorColumn", { bg = "none" })
  hl(0, "ColorColumn", { bg = "none" })
  hl(0, "SignColumn", { fg = text, bg = "none" })
  hl(0, "StatusLine", { fg = text, bg = "none" })
  hl(0, "StatusLineNC", { fg = dim, bg = "none" })
  hl(0, "TabLine", { fg = dim, bg = "none" })
  hl(0, "TabLineFill", { fg = dim, bg = "none" })
  hl(0, "TabLineSel", { fg = text, bg = "none" })
  hl(0, "WinSeparator", { fg = dim, bg = "none" })

  -- Plugin UI highlights
  hl(0, "MiniPickMatchCurrent", { fg = text, bg = sel_bg })
  hl(0, "MiniFilesCursorLine", { fg = text, bg = sel_bg })
end

function M.setup()
  apply()

  -- Re-apply after any colorscheme change
  vim.api.nvim_create_autocmd("ColorScheme", { callback = apply })

  -- Hide command line when not in command mode
  vim.o.cmdheight = 0
  vim.api.nvim_create_autocmd({ "CmdlineEnter", "CmdlineLeave" }, {
    callback = function(args) vim.o.cmdheight = args.event == "CmdlineEnter" and 1 or 0 end,
  })
end

return M
