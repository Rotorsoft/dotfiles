vim.cmd("highlight clear")
vim.g.colors_name = "grapevine"

local hl = vim.api.nvim_set_hl

-- Grape Vine palette
local c = {
  -- Core
  text      = "#d4d0c8",
  base      = "#1c1e1a",
  shade1    = "#38803b",
  shade0    = "#4a704c",

  -- Syntax / treesitter
  keyword   = "#6a8a6c",
  keyword_fn = "#9787b0",
  string    = "#8cc4b0",
  function_ = "#ffd166",
  variable  = "#7cc47f",
  constant  = "#e8cc99",
  type_     = "#52e0c4",
  tag       = "#c678dd",
  label     = "#ffd166",
  punct     = "#6a6a5e",
  comment   = "#555549",
  error     = "#e06c75",
  number    = "#c9b896",
  attribute = "#cba6f7",
  enum      = "#fab387",
  url       = "#7cc47f",
  template  = "#fab387",
  heading   = "#52e0c4",
  link      = "#52e0c4",
}

-- Editor syntax-related highlights
hl(0, "Normal", { fg = c.text, bg = c.base })
hl(0, "NormalNC", { fg = c.text, bg = c.base })
hl(0, "NormalFloat", { fg = c.text, bg = c.base })
hl(0, "FloatBorder", { fg = c.text, bg = c.base })
hl(0, "LineNr", { fg = c.comment, bg = "none" })
hl(0, "CursorLineNr", { fg = c.label, bg = "none", bold = true })
hl(0, "Visual", { bg = c.shade0 })
hl(0, "Search", { fg = c.base, bg = c.label })
hl(0, "IncSearch", { fg = c.base, bg = c.template })
hl(0, "Pmenu", { fg = c.text, bg = c.base })
hl(0, "PmenuSel", { fg = c.text, bg = c.shade0 })
hl(0, "PmenuSbar", { fg = c.text, bg = c.base })
hl(0, "PmenuThumb", { fg = c.text, bg = c.shade0 })
hl(0, "Folded", { fg = c.shade1, bg = "none" })

-- Treesitter highlights

-- Variables
hl(0, "@variable", { fg = c.variable })
hl(0, "@variable.builtin", { fg = c.keyword })
hl(0, "@variable.parameter.builtin", { fg = c.keyword })

-- Constants
hl(0, "@constant", { fg = c.constant })
hl(0, "@constant.builtin", { fg = c.keyword })
hl(0, "@constant.macro", { fg = c.keyword })

-- Modules / Labels
hl(0, "@module", { fg = c.keyword })
hl(0, "@label", { fg = c.label })

-- Strings
hl(0, "@string", { fg = c.string })
hl(0, "@string.documentation", { fg = c.comment })
hl(0, "@string.special.url", { fg = c.url, underline = true })
hl(0, "@string.template", { fg = c.template })

-- Characters
hl(0, "@character", { fg = c.string })

-- Booleans & Numbers
hl(0, "@boolean", { fg = c.constant })
hl(0, "@number", { fg = c.number })

-- Types & Attributes
hl(0, "@type", { fg = c.type_ })
hl(0, "@type.builtin", { fg = c.keyword })
hl(0, "@type.parameter", { fg = c.heading })
hl(0, "@attribute", { fg = c.attribute })
hl(0, "@attribute.builtin", { fg = c.keyword })
hl(0, "@property", { fg = c.variable })

-- Interface / Type aliases
hl(0, "@interface", { fg = c.heading })

-- Enum members
hl(0, "@enum.member", { fg = c.enum })

-- Functions & Constructors
hl(0, "@function", { fg = c.function_ })
hl(0, "@function.builtin", { fg = c.keyword })
hl(0, "@function.macro", { fg = c.keyword })
hl(0, "@constructor", { fg = c.function_ })

-- Operators & Keywords
hl(0, "@operator", { fg = c.keyword })
hl(0, "@keyword", { fg = c.keyword })
hl(0, "@keyword.import", { fg = c.attribute })
hl(0, "@keyword.function", { fg = c.keyword_fn })
hl(0, "@keyword.return", { fg = c.keyword_fn })
hl(0, "@keyword.coroutine", { fg = c.keyword_fn })
hl(0, "@keyword.type", { fg = c.type_ })
hl(0, "@keyword.ts", { fg = c.heading })

-- Punctuation
hl(0, "@punctuation.delimiter", { fg = c.punct })
hl(0, "@punctuation.bracket", { fg = c.punct })
hl(0, "@punctuation.special", { fg = c.punct })
hl(0, "@punctuation.decorative", { fg = c.shade1 })

-- Comments
hl(0, "@comment", { fg = c.comment, italic = true })
hl(0, "@comment.error", { fg = c.error, italic = true })
hl(0, "@comment.warning", { fg = c.error, italic = true })

-- Markup & Diff
hl(0, "@markup.strong", { bold = true })
hl(0, "@markup.italic", { italic = true })
hl(0, "@markup.strikethrough", { strikethrough = true })
hl(0, "@markup.underline", { underline = true })
hl(0, "@markup.heading", { bold = true })
hl(0, "@markup.quote", { fg = c.type_, italic = true })
hl(0, "@markup.math", { fg = c.function_ })
hl(0, "@markup.link", { fg = c.link, underline = true })
hl(0, "@markup.raw", { fg = c.text })
hl(0, "@diff.plus", { fg = c.variable })
hl(0, "@diff.minus", { fg = c.error })

-- HTML / JSON enhancements
hl(0, "@tag", { fg = c.tag })
hl(0, "@tag.attribute", { fg = c.attribute })
hl(0, "@property.json", { fg = c.keyword })
hl(0, "@null.json", { fg = c.constant })
