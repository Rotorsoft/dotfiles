-- override colorscheme for more transparency
vim.api.nvim_set_hl(0, "CursorLine", { bg = "none", underline = false, blend = 20 })
vim.api.nvim_set_hl(0, "CursorLineNr", { fg = "#FFD700", bg = "none", bold = true })
-- override floating window border to rounded by default
do
  local orig = vim.lsp.util.open_floating_preview
  ---@diagnostic disable-next-line duplicate field
  function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
    opts = opts or {}
    opts.border = opts.border or "rounded"
    return orig(contents, syntax, opts, ...)
  end
end

-- yank highlight
vim.api.nvim_create_autocmd("TextYankPost", {
  group = vim.api.nvim_create_augroup("highlight-yank", { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
})

require("lualine").setup({
  options = {
    theme = "auto",
    component_separators = { left = "", right = "" },
    section_separators = { left = "", right = "" },
    globalstatus = true,
  },
  sections = {
    -- Left side
    lualine_a = { { "mode" } },
    lualine_b = {
      { "branch", icon = "" },
      { "diff", colored = true, symbols = { added = " ", modified = " ", removed = " " } },
    },
    lualine_c = {
      {
        "filename",
        path = 1, -- relative path of file
        filestatus = true,
        symbols = {
          modified = "  ",
          readonly = " ",
          unnamed = "∅ ",
        },
      },
    },
    -- Right side
    lualine_x = {
      {
        "diagnostics",
        sources = { "nvim_lsp" },
        symbols = { error = " ", warn = " ", info = " ", hint = "󰌶 " },
      },
    },
    lualine_y = {
      { "lsp_status", padding = { left = 1, right = 0 } },
      { "filesize", separator = "/", padding = { left = 1, right = 0 } },
      { "progress", padding = { left = 0, right = 1 } },
    },
    lualine_z = { { "location" } },
  },
  inactive_sections = {
    lualine_c = { "filename" },
    lualine_x = { "location" },
  },
  extensions = {},
})

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

local hipatterns = require("mini.hipatterns")
hipatterns.setup({
  highlighters = {
    fixme = { pattern = "%f[%w]()FIXME()%f[%W]", group = "MiniHipatternsFixme" },
    hack = { pattern = "%f[%w]()HACK()%f[%W]", group = "MiniHipatternsHack" },
    todo = { pattern = "%f[%w]()TODO()%f[%W]", group = "MiniHipatternsTodo" },
    note = { pattern = "%f[%w]()NOTE()%f[%W]", group = "MiniHipatternsNote" },
    hex_color = hipatterns.gen_highlighter.hex_color(),
  },
})

vim.keymap.set("n", "<leader>e", function()
  require("mini.files").open()
end, { desc = "Explore Files" })

local builtin_pickers = require("mini.pick").builtin
vim.keymap.set("n", "<leader><leader>", builtin_pickers.buffers, { desc = "Buffers" })
vim.keymap.set("n", "<leader>ff", builtin_pickers.files, { desc = "Files" })
vim.keymap.set("n", "<leader>fg", builtin_pickers.grep, { desc = "Grep" })
vim.keymap.set("n", "<leader>fl", builtin_pickers.grep_live, { desc = "Live Grep" })
vim.keymap.set("n", "<leader>f?", builtin_pickers.help, { desc = "Help" })
vim.keymap.set("n", "<leader>f.", builtin_pickers.resume, { desc = "Resume" })

local extra_pickers = require("mini.extra").pickers
vim.keymap.set("n", "<leader>fo", extra_pickers.oldfiles, { desc = "Old Files" })
vim.keymap.set("n", "<leader>fc", extra_pickers.commands, { desc = "Commands" })
vim.keymap.set("n", "<leader>fk", extra_pickers.keymaps, { desc = "Keymaps" })
vim.keymap.set("n", "<leader>fm", extra_pickers.marks, { desc = "Marks" })
vim.keymap.set("n", "<leader>fr", extra_pickers.registers, { desc = "Registers" })
vim.keymap.set("n", "<leader>fh", extra_pickers.history, { desc = "History" })
vim.keymap.set("n", "<leader>fe", extra_pickers.explorer, { desc = "Explorer" })
vim.keymap.set("n", "<leader>ft", extra_pickers.treesitter, { desc = "Treesitter" })
