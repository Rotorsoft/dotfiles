vim.g.mapleader      = " "
vim.g.maplocalleader = " "
vim.o.wrap           = false
vim.o.number         = true
vim.o.relativenumber = true
vim.o.mouse          = "a"
vim.o.showmode       = false
vim.o.breakindent    = true
vim.o.undofile       = true
vim.o.swapfile       = false
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
vim.o.foldexpr       = 'v:lua.vim.treesitter.foldexpr()'
vim.o.indentexpr     = "v:lua.require'nvim-treesitter'.indentexpr()"
vim.o.foldmethod     = 'expr'
vim.o.foldlevel      = 99
vim.opt.listchars    = { tab = "» ", trail = "·", nbsp = " " }
vim.opt.fillchars    = "fold:·,eob: "

vim.pack.add({
  "https://github.com/supermaven-inc/supermaven-nvim",
  "https://github.com/echasnovski/mini.nvim",
  "https://github.com/tpope/vim-fugitive",
  "https://github.com/prettier/vim-prettier",
  { src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "main" },
})

vim.lsp.enable({ "lua_ls", "ts_ls" })

vim.api.nvim_create_autocmd('VimEnter', {
  callback = function()
    local languages = { "javascript", "typescript", "typescriptreact", "html", "json", "css" }
    require("nvim-treesitter").setup()
    require("nvim-treesitter").install(languages)
    vim.api.nvim_create_autocmd('FileType', {
      pattern = languages,
      callback = function() vim.treesitter.start() end,
    })

    require("mini.sessions").setup({ autoread = true, autowrite = true })
    require("mini.ai").setup({ n_lines = 500 })
    require("mini.surround").setup()
    require("mini.comment").setup()
    require("mini.pairs").setup()
    require("mini.icons").setup()
    require("mini.move").setup()
    require("mini.files").setup({ mappings = { close = "<Esc>" }, windows = { preview = true, width_preview = 80 } })
    require("mini.pick").setup({
      mappings = {
        move_start = "<C-g>",
        move_down = "<C-j>",
        move_up = "<C-k>",
        toggle_info = "<C-i>",
        toggle_preview = "<C-p>",
      },
      window = { config = { border = "rounded" } }
    })
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
    -- override ui_select
    vim.ui.select = require("mini.pick").ui_select

    require("supermaven-nvim").setup({ disable_inline_completion = false })
    require("theme").setup()
    require("status").setup()
    require("map")
  end,
})
