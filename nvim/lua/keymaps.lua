-- Core mappings
vim.keymap.set("n", "<leader>w", function()
  vim.cmd.w()
end, { desc = "write buffer" })
vim.keymap.set("n", "<leader>q", function()
  vim.cmd.qa()
end, { desc = "quit all" })
vim.keymap.set("n", "<leader>x", ":bdelete<CR>", { desc = "close buffer" })
vim.keymap.set("n", "<Tab>", ":bnext<CR>", { desc = "next open buffer" })
vim.keymap.set("n", "<leader>e", function()
  require("mini.files").open()
end, { desc = "explore files" })

-- Navigation between splits
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "move to left split" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "move to below split" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "move to above split" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "move to right split" })

-- Resize splits with arrow keys
vim.keymap.set("n", "<Up>", ":resize +4<CR>", { desc = "increase height" })
vim.keymap.set("n", "<Down>", ":resize -4<CR>", { desc = "decrease height" })
vim.keymap.set("n", "<Left>", ":vertical resize -4<CR>", { desc = "decrease width" })
vim.keymap.set("n", "<Right>", ":vertical resize +4<CR>", { desc = "increase width" })

-- Clear highlights on search when pressing <Esc> in normal mode
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- Easy terminal escape
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "exit terminal mode" })

-- Show Lazy
vim.keymap.set("n", "<leader>l", ":Lazy<CR>", { desc = "lazy" })

-- Show terminal
vim.keymap.set("n", "<leader>th", ":ToggleTerm direction=horizontal<CR>", { desc = "horizontal terminal" })
vim.keymap.set("n", "<leader>tv", ":ToggleTerm direction=vertical<CR>", { desc = "vertical terminal" })
vim.keymap.set("n", "<leader>tf", ":ToggleTerm direction=float<CR>", { desc = "float terminal" })

-- Telescope mappings
local builtin = require("telescope.builtin")
vim.keymap.set("n", "<leader><leader>", function()
  builtin.buffers({ prompt_title = "Open Buffers", initial_mode = "normal" })
end, { desc = "open buffers" })
vim.keymap.set("n", "<leader>/", function()
  builtin.current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
    winblend = 10,
    previewer = false,
  }))
end, { desc = "fuzzy find files" })
vim.keymap.set("n", "<C-f>", builtin.grep_string, { desc = "find word" })
vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "find files" })
vim.keymap.set("n", "<leader>fo", builtin.oldfiles, { desc = "old files" })
vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "help" })
vim.keymap.set("n", "<leader>fk", builtin.keymaps, { desc = "keymaps" })
vim.keymap.set("n", "<leader>fb", builtin.builtin, { desc = "builtins" })
vim.keymap.set("n", "<leader>fr", builtin.resume, { desc = "resume find" })
vim.keymap.set("n", "<leader>fw", builtin.grep_string, { desc = "find word" })
vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "live grep" })
vim.keymap.set("n", "<leader>f/", function()
  builtin.live_grep({
    grep_open_files = true,
    prompt_title = "Live Grep in Open Buffers",
  })
end, { desc = "grep open buffers" })
vim.keymap.set("n", "<leader>fn", function()
  builtin.find_files({ cwd = vim.fn.stdpath("config") })
end, { desc = "find neovim files" })

-- LSP related keymaps (F2 to rename, F4 to code action, F12 to goto definition)
vim.keymap.set("n", "<F2>", vim.lsp.buf.rename, { desc = "rename symbol" })
vim.keymap.set({ "n", "x" }, "<F4>", vim.lsp.buf.code_action, { desc = "code action" })
vim.keymap.set("n", "<F12>", builtin.lsp_definitions, { desc = "goto definition" })
-- Diagnostics
vim.keymap.set("n", "<leader>dd", vim.diagnostic.open_float, { desc = "show diagnostics" })
vim.keymap.set("n", "<leader>df", builtin.diagnostics, { desc = "find diagnostics" })
-- Other code related LSP
vim.keymap.set("n", "<leader>cr", builtin.lsp_references, { desc = "lsp references" })
vim.keymap.set("n", "<leader>ct", builtin.lsp_type_definitions, { desc = "lsp type definitions" })
vim.keymap.set("n", "<leader>ci", builtin.lsp_implementations, { desc = "lsp implementations" })
vim.keymap.set("n", "<leader>cs", builtin.lsp_document_symbols, { desc = "lsp document symbols" })
vim.keymap.set("n", "<leader>cw", builtin.lsp_dynamic_workspace_symbols, { desc = "lsp workspace symbols" })
vim.keymap.set("n", "<leader>cf", function()
  require("conform").format({ async = true, lsp_format = "fallback" })
end, { desc = "format buffer" })

-- Session management
local sessions = require("mini.sessions")
vim.keymap.set("n", "<leader>ss", sessions.select, { desc = "select session" })
vim.keymap.set("n", "<leader>sw", function()
  sessions.write(vim.fn.fnamemodify(vim.fn.getcwd(), ":t") .. ".vim")
end, { desc = "write session" })

-- Git mappings
local gs = require("gitsigns")
gs.setup({
  on_attach = function(bufnr)
    local function map(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
    end
    map("n", "<leader>gj", function()
      --- @diagnostic disable-next-line: param-type-mismatch
      gs.nav_hunk("next")
    end, "next hunk")
    map("n", "<leader>gk", function()
      --- @diagnostic disable-next-line: param-type-mismatch
      gs.nav_hunk("prev")
    end, "previous hunk")
    map("n", "<leader>gd", gs.diffthis, "diff")
    map("n", "<leader>gp", gs.preview_hunk, "preview hunk")
    map("n", "<leader>gi", gs.preview_hunk_inline, "preview hunk inline")
    map("n", "<leader>gs", gs.stage_hunk, "stage hunk")
    map("n", "<leader>gr", gs.reset_hunk, "reset hunk")
    map("n", "<leader>gS", gs.stage_buffer, "stage buffer")
    map("n", "<leader>gR", gs.reset_buffer, "reset buffer")
    map("n", "<leader>gb", gs.blame_line, "blame line")
    map("n", "<leader>gl", gs.toggle_current_line_blame, "toggle line blame")
  end,
})

-- Mini clues for keymaps
local miniclue = require("mini.clue")
miniclue.setup({
  triggers = {
    -- Leader triggers
    { mode = "n", keys = "<leader>" },
    { mode = "x", keys = "<leader>" },
    { mode = "v", keys = "<leader>" },
    { mode = "t", keys = "<leader>" },
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
    miniclue.gen_clues.builtin_completion(),
    miniclue.gen_clues.g(),
    miniclue.gen_clues.marks(),
    miniclue.gen_clues.registers(),
    miniclue.gen_clues.z(),
    -- Groups
    { mode = "n", keys = "<leader>f", desc = " find" },
    { mode = "n", keys = "<leader>t", desc = "󰆍 terminal" },
    { mode = "n", keys = "<leader>g", desc = " git" },
    { mode = "n", keys = "<leader>d", desc = " diagnostics" },
    { mode = "n", keys = "<leader>c", desc = " lsp" },
    { mode = "n", keys = "<leader>s", desc = " session" },
  },
  window = { config = { width = 60 }, delay = 0 },
})
