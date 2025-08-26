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
vim.o.clipboard = "unnamedplus"
vim.o.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = " " }

vim.pack.add({
  -- LSP
  { src = "https://github.com/neovim/nvim-lspconfig" },
  { src = "https://github.com/mason-org/mason.nvim" },
  { src = "https://github.com/mason-org/mason-lspconfig.nvim" },
  { src = "https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim" },
  -- Completion
  { src = "https://github.com/hrsh7th/nvim-cmp" },
  { src = "https://github.com/hrsh7th/cmp-nvim-lsp" },
  { src = "https://github.com/hrsh7th/cmp-buffer" },
  { src = "https://github.com/hrsh7th/cmp-path" },
  { src = "https://github.com/L3MON4D3/LuaSnip" },
  { src = "https://github.com/supermaven-inc/supermaven-nvim" },
  -- Formatting
  { src = "https://github.com/stevearc/conform.nvim" },
  -- UI
  { src = "https://github.com/catppuccin/nvim" },
  { src = "https://github.com/nvim-lualine/lualine.nvim" },
  { src = "https://github.com/echasnovski/mini.nvim" },
  -- Git
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
require("lsp")

-- Sessions
local sessions = require("mini.sessions")
sessions.setup({ autoread = true, autowrite = true })
vim.keymap.set("n", "<leader>ss", sessions.select, { desc = "Select" })
vim.keymap.set("n", "<leader>sw", function()
  sessions.write(vim.fn.fnamemodify(vim.fn.getcwd(), ":t") .. ".vim")
end, { desc = "Write" })

-- Plugins
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    require("tui")
    require("git")
    require("keymaps")
  end,
})
