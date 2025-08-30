vim.g.mapleader      = " "
vim.g.maplocalleader = " "
vim.o.number         = true
vim.o.relativenumber = true
vim.o.mouse          = "a"
vim.o.showmode       = false
vim.o.breakindent    = true
vim.o.undofile       = true
vim.o.ignorecase     = true
vim.o.smartcase      = true
vim.o.signcolumn     = "yes"
vim.o.splitright     = true
vim.o.splitbelow     = true
vim.o.inccommand     = "split"
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
vim.opt.listchars    = { tab = "» ", trail = "·", nbsp = " " }
vim.opt.fillchars    = "fold:·,eob: "
vim.wo.foldexpr      = 'v:lua.vim.treesitter.foldexpr()'
vim.wo.foldmethod    = 'expr'
vim.wo.foldlevel     = 99

vim.pack.add({
  { src = "https://github.com/mason-org/mason.nvim" },
  { src = "https://github.com/supermaven-inc/supermaven-nvim" },
  { src = "https://github.com/echasnovski/mini.nvim" },
  { src = "https://github.com/lewis6991/gitsigns.nvim" },
  { src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "main" },
})

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

vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    require("nvim-treesitter.configs").setup({
      ensure_installed = { "javascript", "typescript", "tsx", "html", "json", "css" },
      highlight = { enable = true, },
      indent = { enable = true, },
      auto_install = true,
      sync_install = true,
      modules = {},
      ignore_install = {},
    })
    require("mini.sessions").setup({ autoread = true, autowrite = true })
    require("mini.ai").setup({ n_lines = 500 })
    require("mini.surround").setup()
    require("mini.comment").setup()
    require("mini.pairs").setup()
    require("mini.icons").setup()
    require("mini.move").setup()
    require("mini.files").setup({ mappings = { close = "<Esc>" }, windows = { preview = true, width_preview = 80 } })
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
    require("mason").setup()
    require("supermaven-nvim").setup({ disable_inline_completion = false })

    -- override ui_select
    vim.ui.select = require("mini.pick").ui_select

    -- my plugins
    require("terminal").setup()
    require("theme").setup()
    require("status").setup()

    -- my keymaps
    require("map")
  end,
})
