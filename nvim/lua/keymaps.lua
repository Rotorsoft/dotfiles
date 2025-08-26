vim.keymap.set("n", "<leader>w", function()
  vim.cmd.w()
end, { desc = "Write" })
vim.keymap.set("n", "<leader>q", function()
  vim.cmd.qa()
end, { desc = "Quit" })
vim.keymap.set("n", "<leader>x", ":bdelete<CR>", { desc = "Close" })
vim.keymap.set("n", "<Tab>", ":bnext<CR>", { desc = "Next Buffer" })

-- Navigation between splits
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Move to left split" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Move to below split" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Move to above split" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Move to right split" })

-- Resize splits with arrow keys
vim.keymap.set("n", "<Up>", ":resize +4<CR>", { desc = "Increase height" })
vim.keymap.set("n", "<Down>", ":resize -4<CR>", { desc = "Decrease height" })
vim.keymap.set("n", "<Left>", ":vertical resize -4<CR>", { desc = "Decrease width" })
vim.keymap.set("n", "<Right>", ":vertical resize +4<CR>", { desc = "Increase width" })

-- Clear highlights on search when pressing <Esc> in normal mode
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- Easy terminal escape
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit Terminal Mode" })

local clue = require("mini.clue")
clue.setup({
  triggers = {
    -- Leader triggers
    { mode = "n", keys = "<leader>" },
    { mode = "x", keys = "<leader>" },
    { mode = "v", keys = "<leader>" },
    -- Built-in completion
    { mode = "i", keys = "<C-x>" },
    -- `g` key
    { mode = "n", keys = "g" },
    { mode = "x", keys = "g" },
    -- Marks
    { mode = "n", keys = "'" },
    { mode = "n", keys = "`" },
    { mode = "x", keys = "'" },
    { mode = "x", keys = "`" },
    -- Registers
    { mode = "n", keys = '"' },
    { mode = "x", keys = '"' },
    { mode = "i", keys = "<C-r>" },
    { mode = "c", keys = "<C-r>" },
    -- `z` key
    { mode = "n", keys = "z" },
    { mode = "x", keys = "z" },
    -- Bracketed
    { mode = "n", keys = "[" },
    { mode = "n", keys = "]" },
  },
  clues = {
    clue.gen_clues.builtin_completion(),
    clue.gen_clues.g(),
    clue.gen_clues.marks(),
    clue.gen_clues.registers(),
    clue.gen_clues.z(),

    { mode = "n", keys = "<leader>f", desc = " Find" },
    { mode = "n", keys = "<leader>g", desc = " Git" },
    { mode = "n", keys = "<leader>c", desc = " Code (LSP)" },
    { mode = "n", keys = "<leader>s", desc = " Session" },
  },
  window = { config = { width = 60 }, delay = 0 },
})
