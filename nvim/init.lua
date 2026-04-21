-- Leader
vim.g.mapleader      = " "
vim.g.maplocalleader = " "

-- Options
vim.o.wrap           = false
vim.o.number         = true
vim.o.relativenumber = true
vim.o.showmode       = false
vim.o.breakindent    = true
vim.o.swapfile       = false
vim.o.ignorecase     = true
vim.o.smartcase      = true
vim.o.signcolumn     = "yes"
vim.o.splitright     = true
vim.o.splitbelow     = true
vim.o.cursorline     = true
vim.o.scrolloff      = 10
vim.o.confirm        = true
vim.o.shiftwidth     = 2
vim.o.tabstop        = 2
vim.o.softtabstop    = 2
vim.o.expandtab      = true
vim.o.winborder      = "rounded"
vim.o.clipboard      = "unnamedplus"
vim.o.list           = true
vim.o.timeoutlen     = 300
vim.o.foldexpr       = 'v:lua.vim.treesitter.foldexpr()'
vim.o.indentexpr     = "v:lua.require'nvim-treesitter'.indentexpr()"
vim.o.foldmethod     = 'expr'
vim.o.foldlevel      = 99
vim.opt.completeopt  = { "menu", "menuone", "noinsert", "fuzzy", "popup" }
vim.opt.listchars    = { tab = "» ", trail = "·", nbsp = " " }
vim.opt.fillchars    = "fold:·,eob: "

-- Diagnostics
vim.diagnostic.config({ virtual_text = true })

-- Packages
vim.pack.add({
  "https://github.com/neovim/nvim-lspconfig",
  "https://github.com/nvim-treesitter/nvim-treesitter",
  "https://github.com/supermaven-inc/supermaven-nvim",
  "https://github.com/echasnovski/mini.nvim",
  "https://github.com/tpope/vim-fugitive",
  "https://github.com/rotorsoft/act-nvim",
  "https://github.com/MeanderingProgrammer/render-markdown.nvim",
})

-- LSP
vim.lsp.enable({ "lua_ls", "ts_ls", "biome" })
vim.lsp.config["lua_ls"] = { settings = { Lua = { workspace = { library = vim.api.nvim_get_runtime_file("", true) } } } }
vim.lsp.config["ts_ls"] = {
  on_attach = function(client)
    client.server_capabilities.documentFormattingProvider = false
  end,
}

-- Treesitter
local languages = { "javascript", "typescript", "html", "json", "css", "markdown", "markdown_inline" }
require("nvim-treesitter").setup({ highlight = { enable = true } })
vim.api.nvim_create_autocmd('VimEnter', {
  callback = function() require("nvim-treesitter").install(languages) end,
})
vim.api.nvim_create_autocmd('FileType', {
  pattern = languages,
  callback = function() vim.treesitter.start() end,
})
vim.api.nvim_create_autocmd('FileType', {
  pattern = "markdown",
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true
  end,
})

-- Mini
require("mini.ai").setup({ n_lines = 500 })
require("mini.surround").setup()
require("mini.pairs").setup()
require("mini.icons").setup()
require("mini.files").setup({
  mappings = { close = "<Esc>" },
  windows = { preview = true, width_preview = math.max(20, math.floor(vim.o.columns * 0.4)) },
})
require("mini.pick").setup({
  mappings = {
    move_start = "<C-g>",
    move_down = "<C-j>",
    move_up = "<C-k>",
    toggle_info = "<C-i>",
    toggle_preview = "<C-p>",
  },
})
require("mini.extra").setup()
require("mini.diff").setup({ view = { style = "sign" } })
require("mini.hipatterns").setup({
  highlighters = {
    fixme = { pattern = "%f[%w]()FIXME()%f[%W]", group = "MiniHipatternsFixme" },
    hack = { pattern = "%f[%w]()HACK()%f[%W]", group = "MiniHipatternsHack" },
    todo = { pattern = "%f[%w]()TODO()%f[%W]", group = "MiniHipatternsTodo" },
    note = { pattern = "%f[%w]()NOTE()%f[%W]", group = "MiniHipatternsNote" },
    hex_color = require("mini.hipatterns").gen_highlighter.hex_color(),
  },
})
vim.ui.select = require("mini.pick").ui_select

-- Plugins
require("supermaven-nvim").setup({})
require("act-nvim").setup({ auto_open = true, browser = "Brave Browser" })
require("render-markdown").setup({})

-- Local
--vim.cmd.colorscheme("catppuccin")
require("theme").setup()
require("status").setup()
require("map")

-- vim ui2
require('vim._core.ui2').enable({
  enable = true,
  msg = {
    target = "cmd",
    pager = { height = 0.5 },
    dialog = { height = 0.5 },
    cmd = { height = 0.5 },
    msg = { height = 0.5, timeout = 4500 },
  }
})
