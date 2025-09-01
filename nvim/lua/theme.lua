local M = {}

local colors = {
  rosewater   = "#f5e0dc",
  flamingo    = "#f2cdcd",
  pink        = "#f5c2e7",
  mauve       = "#cba6f7",
  red         = "#f38ba8",
  maroon      = "#eba0ac",
  peach       = "#fab387",
  yellow      = "#f9e2af",
  green       = "#a6e3a1",
  teal        = "#94e2d5",
  sky         = "#89dceb",
  sapphire    = "#74c7ec",
  blue        = "#89b4fa",
  lavender    = "#b4befe",

  text        = "#cdd6f4",
  overlay1    = "#7f849c",
  overlay0    = "#6c7086",
  surface1    = "#45475a",
  surface0    = "#313244",
  base        = "#1e1e2e",

  -- treesitter
  fg_default  = "#a0a0a0", -- general foreground
  fg_comment  = "#7f7f7f", -- comments, notes, docstrings
  fg_keyword  = "#888888", -- keywords, operators, modifiers
  fg_string   = "#32ae85", -- strings and string-like values
  fg_function = "#fecb52", -- function names / definitions
  fg_variable = "#32ae85", -- variables
  fg_constant = "#a0a0a0", -- constants
  fg_type     = "#34febb", -- types and class names
  fg_tag      = "#888888", -- XML/HTML tags
  fg_label    = "#fecb52", -- labels (GOTO, etc.)
  fg_punct    = "#666666", -- punctuation, delimiters, brackets
  fg_error    = "#e06c75", -- errors, warnings
  bg_default  = "#121111"  -- editor background
}

local function config_treesitter()
  local hl = vim.api.nvim_set_hl

  -- Variables
  hl(0, "@variable", { fg = colors.fg_variable })
  hl(0, "@variable.builtin", { fg = colors.fg_keyword })
  hl(0, "@variable.parameter", { fg = colors.fg_variable })
  hl(0, "@variable.parameter.builtin", { fg = colors.fg_keyword })
  hl(0, "@variable.member", { fg = colors.fg_variable })

  -- Constants
  hl(0, "@constant", { fg = colors.fg_constant })
  hl(0, "@constant.builtin", { fg = colors.fg_keyword })
  hl(0, "@constant.macro", { fg = colors.fg_keyword })

  -- Modules / Labels
  hl(0, "@module", { fg = colors.fg_keyword })
  hl(0, "@module.builtin", { fg = colors.fg_keyword })
  hl(0, "@label", { fg = colors.fg_label })

  -- Strings
  hl(0, "@string", { fg = colors.fg_string })
  hl(0, "@string.documentation", { fg = colors.fg_comment })
  hl(0, "@string.regexp", { fg = colors.fg_string })
  hl(0, "@string.escape", { fg = colors.fg_string })
  hl(0, "@string.special", { fg = colors.fg_string })
  hl(0, "@string.special.symbol", { fg = colors.fg_string })
  hl(0, "@string.special.path", { fg = colors.fg_string })
  hl(0, "@string.special.url", { fg = colors.fg_string, underline = true })
  hl(0, "@string.template", { fg = colors.peach }) -- new: template string interpolation `${}`

  -- Characters
  hl(0, "@character", { fg = colors.fg_string })
  hl(0, "@character.special", { fg = colors.fg_string })

  -- Booleans & Numbers
  hl(0, "@boolean", { fg = colors.fg_constant })
  hl(0, "@number", { fg = colors.fg_constant })
  hl(0, "@number.float", { fg = colors.fg_constant })

  -- Types & Attributes
  hl(0, "@type", { fg = colors.fg_type })
  hl(0, "@type.builtin", { fg = colors.fg_keyword })
  hl(0, "@type.definition", { fg = colors.fg_type })
  hl(0, "@type.parameter", { fg = colors.lavender }) -- new: generics / type parameters
  hl(0, "@attribute", { fg = colors.mauve })         -- decorators / attributes
  hl(0, "@attribute.builtin", { fg = colors.fg_keyword })
  hl(0, "@property", { fg = colors.fg_variable })

  -- Interface / Type aliases
  hl(0, "@interface", { fg = colors.lavender }) -- new

  -- Enum members
  hl(0, "@enum.member", { fg = colors.peach }) -- new

  -- Functions & Constructors
  hl(0, "@function", { fg = colors.fg_function })
  hl(0, "@function.builtin", { fg = colors.fg_keyword })
  hl(0, "@function.call", { fg = colors.fg_function })
  hl(0, "@function.macro", { fg = colors.fg_keyword })
  hl(0, "@function.method", { fg = colors.fg_function })
  hl(0, "@function.method.call", { fg = colors.fg_function })
  hl(0, "@constructor", { fg = colors.fg_function })

  -- Operators & Keywords
  hl(0, "@operator", { fg = colors.fg_keyword })
  hl(0, "@keyword", { fg = colors.fg_keyword })
  hl(0, "@keyword.coroutine", { fg = colors.fg_keyword })
  hl(0, "@keyword.function", { fg = colors.fg_keyword })
  hl(0, "@keyword.operator", { fg = colors.fg_keyword })
  hl(0, "@keyword.import", { fg = colors.mauve }) -- new: TS/JS import/export specifiers
  hl(0, "@keyword.type", { fg = colors.fg_type })
  hl(0, "@keyword.modifier", { fg = colors.fg_keyword })
  hl(0, "@keyword.repeat", { fg = colors.fg_keyword })
  hl(0, "@keyword.return", { fg = colors.fg_keyword })
  hl(0, "@keyword.debug", { fg = colors.fg_keyword })
  hl(0, "@keyword.exception", { fg = colors.fg_keyword })
  hl(0, "@keyword.conditional", { fg = colors.fg_keyword })
  hl(0, "@keyword.conditional.ternary", { fg = colors.fg_keyword })
  hl(0, "@keyword.directive", { fg = colors.fg_keyword })
  hl(0, "@keyword.directive.define", { fg = colors.fg_keyword })
  hl(0, "@keyword.ts", { fg = colors.sky }) -- new: TS-specific keywords (readonly, implements, etc.)

  -- Punctuation
  hl(0, "@punctuation.delimiter", { fg = colors.fg_punct })
  hl(0, "@punctuation.bracket", { fg = colors.fg_punct })
  hl(0, "@punctuation.special", { fg = colors.fg_punct })
  hl(0, "@punctuation.decorative", { fg = colors.overlay1 }) -- new: brackets/braces highlight for readability

  -- Comments
  hl(0, "@comment", { fg = colors.fg_comment, italic = true })
  hl(0, "@comment.documentation", { fg = colors.fg_comment, italic = true })
  hl(0, "@comment.error", { fg = colors.fg_error, italic = true })
  hl(0, "@comment.warning", { fg = colors.fg_error, italic = true })
  hl(0, "@comment.todo", { fg = colors.fg_comment, italic = true })
  hl(0, "@comment.note", { fg = colors.fg_comment, italic = true })

  -- Markup & Diff
  hl(0, "@markup.strong", { bold = true })
  hl(0, "@markup.italic", { italic = true })
  hl(0, "@markup.strikethrough", { strikethrough = true })
  hl(0, "@markup.underline", { underline = true })
  hl(0, "@markup.heading", { bold = true })
  hl(0, "@markup.quote", { fg = colors.fg_type, italic = true })
  hl(0, "@markup.math", { fg = colors.fg_function })
  hl(0, "@markup.link", { fg = colors.fg_type, underline = true })
  hl(0, "@markup.raw", { fg = colors.fg_default })
  hl(0, "@diff.plus", { fg = colors.fg_variable })
  hl(0, "@diff.minus", { fg = colors.fg_error })

  -- Tags
  hl(0, "@tag", { fg = colors.fg_tag })
  hl(0, "@tag.builtin", { fg = colors.fg_tag })
  hl(0, "@tag.attribute", { fg = colors.fg_variable })
  hl(0, "@tag.delimiter", { fg = colors.fg_punct })
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
  hl(0, "LineNr", { fg = colors.surface0 })
  hl(0, "CursorLineNr", { fg = colors.flamingo, bg = "none", bold = true })
  hl(0, "VertSplit", { fg = colors.surface1 })
  hl(0, "StatusLine", { fg = colors.text, bg = "none" })
  hl(0, "StatusLineNC", { fg = colors.overlay1, bg = "none" })
  hl(0, "Pmenu", { fg = colors.text, bg = "none" })
  hl(0, "PmenuSel", { fg = colors.text, bg = colors.overlay0 })
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
  hl(0, "Folded", { fg = colors.overlay1, bg = "none" })

  -- Yank highlight
  ---@diagnostic disable-next-line: param-type-mismatch
  vim.api.nvim_create_autocmd("TextYankPost", {
    group = vim.api.nvim_create_augroup("highlight-yank", { clear = true }),
    callback = function() vim.hl.on_yank() end,
  })

  -- Hide command line when not in command mode
  vim.o.cmdheight = 0
  ---@diagnostic disable-next-line: param-type-mismatch
  vim.api.nvim_create_autocmd({ "CmdlineEnter" }, {
    callback = function() vim.o.cmdheight = 1 end -- show the command line when entering command mode
  })
  ---@diagnostic disable-next-line: param-type-mismatch
  vim.api.nvim_create_autocmd({ "CmdlineLeave" }, {
    callback = function() vim.o.cmdheight = 0 end -- hide again when leaving command mode
  })

  -- Background for mini
  vim.api.nvim_set_hl(0, "MiniPickMatchCurrent", { fg = colors.text, bg = colors.surface0, })
  vim.api.nvim_set_hl(0, "MiniFilesCursorLine", { fg = colors.text, bg = colors.surface0, })

  config_treesitter()
end

return M
