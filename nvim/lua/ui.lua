local M = {}

local function apply()
  local hl = vim.api.nvim_set_hl
  local function attr(group, key)
    local h = vim.api.nvim_get_hl(0, { name = group, link = false })
    return h[key] and string.format("#%06x", h[key]) or nil
  end
  local function lighten(hex, amount)
    local r = math.min(255, tonumber(hex:sub(2, 3), 16) + amount)
    local g = math.min(255, tonumber(hex:sub(4, 5), 16) + amount)
    local b = math.min(255, tonumber(hex:sub(6, 7), 16) + amount)
    return string.format("#%02x%02x%02x", r, g, b)
  end

  local text = attr("Normal", "fg")
  local dim = attr("Comment", "fg")
  local bg = attr("Normal", "bg")
  local sel_bg = attr("Visual", "bg") or dim
  local cursor_bg = bg and lighten(bg, 12) or "none"

  -- Transparent / minimal chrome
  hl(0, "CursorLine", { bg = cursor_bg })
  hl(0, "CursorColumn", { bg = "none" })
  hl(0, "ColorColumn", { bg = "none" })
  hl(0, "SignColumn", { fg = text, bg = "none" })
  hl(0, "StatusLine", { fg = text, bg = "none" })
  hl(0, "StatusLineNC", { fg = dim, bg = "none" })
  hl(0, "TabLine", { fg = dim, bg = "none" })
  hl(0, "TabLineFill", { fg = dim, bg = "none" })
  hl(0, "TabLineSel", { fg = text, bg = "none" })
  hl(0, "WinSeparator", { fg = dim, bg = "none" })

  -- Plugin UI highlights (bg only — preserve syntax fg in selected row)
  hl(0, "MiniPickMatchCurrent", { bg = sel_bg })
  hl(0, "MiniFilesCursorLine", { bg = sel_bg })
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
