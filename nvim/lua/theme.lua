local M = {}

-- Palette
local colors = {
  -- Main
  rosewater = "#f5e0dc",
  flamingo  = "#f2cdcd",
  pink      = "#f5c2e7",
  mauve     = "#cba6f7",
  red       = "#f38ba8",
  maroon    = "#eba0ac",
  peach     = "#fab387",
  yellow    = "#f9e2af",
  green     = "#a6e3a1",
  teal      = "#94e2d5",
  sky       = "#89dceb",
  sapphire  = "#74c7ec",
  blue      = "#89b4fa",
  lavender  = "#b4befe",

  -- Neutral / gray
  text      = "#cdd6f4",
  overlay1  = "#7f849c",
  overlay0  = "#6c7086",
  surface1  = "#45475a",
  surface0  = "#313244",
  base      = "#1e1e2e",
}

-- Function to set highlights
function M.setup()
  local hl = vim.api.nvim_set_hl

  -- Editor UI
  hl(0, "Normal", { fg = colors.text, bg = "none" })
  hl(0, "NormalNC", { fg = colors.text, bg = "none" })
  hl(0, "NormalFloat", { fg = colors.text, bg = "none" })
  hl(0, "FloatBorder", { fg = colors.text, bg = "none" })
  hl(0, "CursorLine", { bg = "none" })
  hl(0, "CursorColumn", { bg = "none" })
  hl(0, "ColorColumn", { bg = "none" })
  hl(0, "SignColumn", { fg = colors.text, bg = "none" })
  hl(0, "LineNr", { fg = colors.surface0 })
  hl(0, "CursorLineNr", { fg = colors.flamingo, bg = "none", bold = true })
  hl(0, "VertSplit", { fg = colors.surface1 })
  hl(0, "StatusLine", { fg = colors.text, bg = "none" })
  hl(0, "StatusLineNC", { fg = colors.overlay1, bg = "none" })
  hl(0, "Pmenu", { fg = colors.text, bg = "none" })
  hl(0, "PmenuSel", { fg = colors.base, bg = "none" })
  hl(0, "PmenuSbar", { fg = colors.text, bg = "none" })
  hl(0, "PmenuThumb", { fg = colors.text, bg = "none" })
  hl(0, "TabLine", { fg = colors.overlay1, bg = "none" })
  hl(0, "TabLineFill", { fg = colors.overlay1, bg = "none" })
  hl(0, "TabLineSel", { fg = colors.text, bg = "none" })
  hl(0, "VertSplit", { fg = colors.surface1, bg = "none" })
  hl(0, "WinSeparator", { fg = colors.surface1, bg = "none" })
  hl(0, "Visual", { bg = colors.surface0 })
  hl(0, "Search", { fg = colors.base, bg = colors.yellow })
  hl(0, "IncSearch", { fg = colors.base, bg = colors.peach })

  -- Comments & Whitespace
  hl(0, "Comment", { fg = colors.overlay0, italic = true })
  hl(0, "Whitespace", { fg = colors.overlay1 })

  -- Syntax highlighting
  -- hl(0, "Constant", { fg = colors.peach })
  -- hl(0, "String", { fg = colors.green })
  -- hl(0, "Character", { fg = colors.green })
  -- hl(0, "Number", { fg = colors.peach })
  -- hl(0, "Boolean", { fg = colors.peach })
  -- hl(0, "Float", { fg = colors.peach })
  -- hl(0, "Identifier", { fg = colors.lavender })
  -- hl(0, "Function", { fg = colors.blue })
  -- hl(0, "Statement", { fg = colors.red })
  -- hl(0, "Conditional", { fg = colors.red })
  -- hl(0, "Repeat", { fg = colors.red })
  -- hl(0, "Label", { fg = colors.red })
  -- hl(0, "Operator", { fg = colors.text })
  -- hl(0, "Keyword", { fg = colors.red })
  -- hl(0, "Exception", { fg = colors.red })
  -- hl(0, "PreProc", { fg = colors.yellow })
  -- hl(0, "Include", { fg = colors.yellow })
  -- hl(0, "Define", { fg = colors.yellow })
  -- hl(0, "Macro", { fg = colors.yellow })
  -- hl(0, "Type", { fg = colors.yellow })
  -- hl(0, "StorageClass", { fg = colors.yellow })
  -- hl(0, "Structure", { fg = colors.yellow })
  -- hl(0, "Typedef", { fg = colors.yellow })
  -- hl(0, "Special", { fg = colors.teal })
  -- hl(0, "SpecialChar", { fg = colors.teal })
  -- hl(0, "Tag", { fg = colors.peach })
  -- hl(0, "Delimiter", { fg = colors.overlay1 })
  -- hl(0, "SpecialComment", { fg = colors.overlay1 })
  -- hl(0, "Debug", { fg = colors.red })
  -- hl(0, "Underlined", { fg = colors.blue, underline = true })
  -- hl(0, "Ignore", { fg = colors.overlay0 })
  -- hl(0, "Error", { fg = colors.red, bold = true })
  -- hl(0, "Todo", { fg = colors.peach, bold = true })

  -- Yank highlight
  vim.api.nvim_create_autocmd("TextYankPost", {
    group = vim.api.nvim_create_augroup("highlight-yank", { clear = true }),
    callback = function() vim.hl.on_yank() end,
  })
  -- Hide command line when not in command mode
  vim.o.cmdheight = 0
  vim.api.nvim_create_autocmd({ "CmdlineEnter" }, {
    callback = function() vim.o.cmdheight = 1 end -- show the command line when entering command mode
  })
  vim.api.nvim_create_autocmd({ "CmdlineLeave" }, {
    callback = function() vim.o.cmdheight = 0 end -- hide again when leaving command mode
  })
  -- Background for mini
  vim.api.nvim_set_hl(0, "MiniPickMatchCurrent", { fg = colors.text, bg = colors.surface0, })
  vim.api.nvim_set_hl(0, "MiniFilesCursorLine", { fg = colors.text, bg = colors.surface0, })
end

return M
