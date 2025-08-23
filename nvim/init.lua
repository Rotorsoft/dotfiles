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
vim.o.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.o.foldtext = ""
vim.o.shiftwidth = 2
vim.o.tabstop = 2
vim.o.softtabstop = 2
vim.o.expandtab = true
vim.o.clipboard = "unnamedplus"
vim.o.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = " " }

require("bootstrap")
require("keymaps")
require("commands")

require("catppuccin").setup({
  flavour = "mocha",
  transparent_background = true,
  float = { transparent = true, solid = false },
})
vim.cmd.colorscheme("catppuccin")
-- override colorscheme for more transparency
vim.api.nvim_set_hl(0, "CursorLine", { bg = "none", underline = false, blend = 20 })
vim.api.nvim_set_hl(0, "CursorLineNr", { fg = "#FFD700", bg = "none", bold = true })

-- List highlight groups with their colors
function List_hl()
  local all_hl = vim.fn.getcompletion("", "highlight") -- get all highlight group names
  for _, name in ipairs(all_hl) do
    if name:match("^Diagnostic") then
      local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = name })
      if ok then
        local fg = hl.fg and string.format("#%06x", hl.fg) or "none"
        local bg = hl.bg and string.format("#%06x", hl.bg) or "none"
        local style = (hl.bold and "bold " or "")
          .. (hl.italic and "italic " or "")
          .. (hl.underline and "underline" or "")
        print(string.format("%-25s fg=%-8s bg=%-8s style=%s", name, fg, bg, style))
      end
    end
  end
end

-- vim: ts=2 sts=2 sw=2 et
