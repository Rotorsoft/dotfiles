vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.o.number = true
vim.o.relativenumber = true
vim.o.mouse = "a"
vim.o.showmode = false
vim.o.breakindent = true
vim.o.undofile = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.signcolumn = "yes"
vim.o.splitright = true
vim.o.splitbelow = true
vim.o.inccommand = "split"
vim.o.cursorline = true
vim.o.scrolloff = 10
vim.o.confirm = true
vim.o.foldenable = true
vim.o.foldlevel = 99
vim.o.foldlevelstart = 99
vim.o.foldnestmax = 4
vim.o.foldmethod = "expr"
vim.o.foldtext = ""
vim.o.shiftwidth = 2
vim.o.tabstop = 2
vim.o.softtabstop = 2
vim.o.expandtab = true
vim.o.winborder = "rounded"
vim.o.termguicolors = true
vim.o.clipboard = "unnamedplus"
vim.o.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = " " }

vim.pack.add({
  { src = "https://github.com/mason-org/mason.nvim" },
  { src = "https://github.com/supermaven-inc/supermaven-nvim" },
  { src = "https://github.com/catppuccin/nvim" },
  { src = "https://github.com/nvim-lualine/lualine.nvim" },
  { src = "https://github.com/echasnovski/mini.nvim" },
  { src = "https://github.com/lewis6991/gitsigns.nvim" },
})

-- Theme
require("catppuccin").setup({
  flavour = "mocha",
  transparent_background = true,
  float = { transparent = true },
})
vim.cmd.colorscheme("catppuccin")

-- LSP
vim.lsp.enable({ "lua_ls", "ts_ls" })
vim.diagnostic.config({
  severity_sort = true,
  underline = { severity = vim.diagnostic.severity.ERROR },
  virtual_text = { source = true, spacing = 4 },
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = "󰅚 ",
      [vim.diagnostic.severity.WARN] = "󰀪 ",
      [vim.diagnostic.severity.INFO] = "󰋽 ",
      [vim.diagnostic.severity.HINT] = "󰌶 ",
    },
  },
})

-- Plugins
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    require("mini.sessions").setup({ autoread = true, autowrite = true })
    require("mini.ai").setup({ n_lines = 500 })
    require("mini.surround").setup()
    require("mini.comment").setup()
    require("mini.pairs").setup()
    require("mini.icons").setup()
    require("mini.indentscope").setup()
    require("mini.move").setup()
    require("mini.files").setup()
    require("mini.pick").setup({ window = { config = { border = "rounded" } } })
    require("mini.extra").setup()
    require("mini.notify").setup()
    require("mini.hipatterns").setup({
      highlighters = {
        fixme = { pattern = "%f[%w]()FIXME()%f[%W]", group = "MiniHipatternsFixme" },
        hack = { pattern = "%f[%w]()HACK()%f[%W]", group = "MiniHipatternsHack" },
        todo = { pattern = "%f[%w]()TODO()%f[%W]", group = "MiniHipatternsTodo" },
        note = { pattern = "%f[%w]()NOTE()%f[%W]", group = "MiniHipatternsNote" },
        hex_color = require("mini.hipatterns").gen_highlighter.hex_color(),
      },
    })
    require("tui")
    require("git")
    require("map")
    require("mason").setup()
    require("supermaven-nvim").setup({ disable_inline_completion = false })
  end,
})
