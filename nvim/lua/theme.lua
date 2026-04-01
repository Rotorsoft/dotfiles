local M = {}

-- Unified palette
local colors = {
  -- Core UI
  text      = "#e6e6e6",
  base      = "#1a1a1a",
  shade1    = "#38803b",
  shade0    = "#4a704c",

  -- Syntax / treesitter
  keyword   = "#6bb36d",
  string    = "#7cc47f",
  function_ = "#ffd166",
  variable  = "#a2d39c",
  constant  = "#d0d0d0",
  type_     = "#52e0c4",
  tag       = "#c678dd",
  label     = "#ffd166",
  punct     = "#909090",
  comment   = "#7a7a7a",
  error     = "#e06c75",
  number    = "#d0d0d0",
  attribute = "#cba6f7",
  enum      = "#fab387",
  url       = "#7cc47f",
  template  = "#fab387",
  heading   = "#52e0c4",
  link      = "#52e0c4"
}

local function config_treesitter()
  local hl = vim.api.nvim_set_hl

  -- Variables
  hl(0, "@variable", { fg = colors.variable })
  hl(0, "@variable.builtin", { fg = colors.keyword })
  hl(0, "@variable.parameter.builtin", { fg = colors.keyword })

  -- Constants
  hl(0, "@constant", { fg = colors.constant })
  hl(0, "@constant.builtin", { fg = colors.keyword })
  hl(0, "@constant.macro", { fg = colors.keyword })

  -- Modules / Labels
  hl(0, "@module", { fg = colors.keyword })
  hl(0, "@label", { fg = colors.label })

  -- Strings
  hl(0, "@string", { fg = colors.string })
  hl(0, "@string.documentation", { fg = colors.comment })
  hl(0, "@string.special.url", { fg = colors.url, underline = true })
  hl(0, "@string.template", { fg = colors.template })

  -- Characters
  hl(0, "@character", { fg = colors.string })

  -- Booleans & Numbers
  hl(0, "@boolean", { fg = colors.constant })
  hl(0, "@number", { fg = colors.number })

  -- Types & Attributes
  hl(0, "@type", { fg = colors.type_ })
  hl(0, "@type.builtin", { fg = colors.keyword })
  hl(0, "@type.parameter", { fg = colors.heading })
  hl(0, "@attribute", { fg = colors.attribute })
  hl(0, "@attribute.builtin", { fg = colors.keyword })
  hl(0, "@property", { fg = colors.variable })

  -- Interface / Type aliases
  hl(0, "@interface", { fg = colors.heading })

  -- Enum members
  hl(0, "@enum.member", { fg = colors.enum })

  -- Functions & Constructors
  hl(0, "@function", { fg = colors.function_ })
  hl(0, "@function.builtin", { fg = colors.keyword })
  hl(0, "@function.macro", { fg = colors.keyword })
  hl(0, "@constructor", { fg = colors.function_ })

  -- Operators & Keywords
  hl(0, "@operator", { fg = colors.keyword })
  hl(0, "@keyword", { fg = colors.keyword })
  hl(0, "@keyword.import", { fg = colors.attribute })
  hl(0, "@keyword.type", { fg = colors.type_ })
  hl(0, "@keyword.ts", { fg = colors.heading })

  -- Punctuation
  hl(0, "@punctuation.delimiter", { fg = colors.punct })
  hl(0, "@punctuation.bracket", { fg = colors.punct })
  hl(0, "@punctuation.special", { fg = colors.punct })
  hl(0, "@punctuation.decorative", { fg = colors.shade1 })

  -- Comments
  hl(0, "@comment", { fg = colors.comment, italic = true })
  hl(0, "@comment.error", { fg = colors.error, italic = true })
  hl(0, "@comment.warning", { fg = colors.error, italic = true })

  -- Markup & Diff
  hl(0, "@markup.strong", { bold = true })
  hl(0, "@markup.italic", { italic = true })
  hl(0, "@markup.strikethrough", { strikethrough = true })
  hl(0, "@markup.underline", { underline = true })
  hl(0, "@markup.heading", { bold = true })
  hl(0, "@markup.quote", { fg = colors.type_, italic = true })
  hl(0, "@markup.math", { fg = colors.function_ })
  hl(0, "@markup.link", { fg = colors.link, underline = true })
  hl(0, "@markup.raw", { fg = colors.text })
  hl(0, "@diff.plus", { fg = colors.variable })
  hl(0, "@diff.minus", { fg = colors.error })

  -- HTML / JSON enhancements
  hl(0, "@tag", { fg = colors.tag })
  hl(0, "@tag.attribute", { fg = colors.attribute })
  hl(0, "@property.json", { fg = colors.keyword })
  hl(0, "@null.json", { fg = colors.constant })
end

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
  hl(0, "LineNr", { fg = colors.comment, bg = "none" })
  hl(0, "CursorLineNr", { fg = colors.label, bg = "none", bold = true })
  hl(0, "StatusLine", { fg = colors.text, bg = "none" })
  hl(0, "StatusLineNC", { fg = colors.shade1, bg = "none" })
  hl(0, "Pmenu", { fg = colors.text, bg = "none" })
  hl(0, "PmenuSel", { fg = colors.text, bg = colors.shade0 })
  hl(0, "PmenuSbar", { fg = colors.text, bg = "none" })
  hl(0, "PmenuThumb", { fg = colors.text, bg = "none" })
  hl(0, "TabLine", { fg = colors.shade1, bg = "none" })
  hl(0, "TabLineFill", { fg = colors.shade1, bg = "none" })
  hl(0, "TabLineSel", { fg = colors.text, bg = "none" })
  hl(0, "WinSeparator", { fg = colors.shade1, bg = "none" })
  hl(0, "Visual", { bg = colors.shade0 })
  hl(0, "Search", { fg = colors.base, bg = colors.label })
  hl(0, "IncSearch", { fg = colors.base, bg = colors.template })
  hl(0, "Folded", { fg = colors.shade1, bg = "none" })

  -- Hide command line when not in command mode
  vim.o.cmdheight = 0
  vim.api.nvim_create_autocmd({ "CmdlineEnter", "CmdlineLeave" }, {
    callback = function(args) vim.o.cmdheight = args.event == "CmdlineEnter" and 1 or 0 end,
  })

  -- Background for mini
  vim.api.nvim_set_hl(0, "MiniPickMatchCurrent", { fg = colors.text, bg = colors.shade0, })
  vim.api.nvim_set_hl(0, "MiniFilesCursorLine", { fg = colors.text, bg = colors.shade0, })

  config_treesitter()
end

return M
