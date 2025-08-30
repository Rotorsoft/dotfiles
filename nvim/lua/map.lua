local map = vim.keymap.set
local function mapn(lhs, rhs, desc, buffer)
  map("n", lhs, rhs, { desc = desc, buffer = buffer, silent = true, noremap = true })
end

mapn("<leader>w", function() vim.cmd.w() end, "Write")
mapn("<leader>q", function() vim.cmd.qa() end, "Quit")
mapn("<leader>x", function() vim.cmd.bd() end, "Close")
mapn("<Tab>", function() vim.cmd.bn() end, "Next Buffer")

mapn("<C-h>", "<C-w>h", "Move to left split")
mapn("<C-j>", "<C-w>j", "Move to below split")
mapn("<C-k>", "<C-w>k", "Move to above split")
mapn("<C-l>", "<C-w>l", "Move to right split")
mapn("<Up>", function() vim.cmd("resize +4") end, "Increase height")
mapn("<Down>", function() vim.cmd("resize -4") end, "Decrease height")
mapn("<Left>", function() vim.cmd("vertical resize -4") end, "Decrease width")
mapn("<Right>", function() vim.cmd("vertical resize +4") end, "Increase width")

-- Clear highlights on search when pressing <Esc> in normal mode
mapn("<Esc>", function() vim.cmd.nohlsearch() end)

-- Easy terminal escape
map("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit Terminal Mode" })

local bp = require("mini.pick").builtin
local ep = require("mini.extra").pickers
mapn("<leader><leader>", bp.files, "Files")
mapn("<leader>b", bp.buffers, "Buffers")
mapn("<leader>d", vim.diagnostic.open_float, "Diagnostic")
mapn("<leader>e", function() require("mini.files").open() end, "Explore")
mapn("<leader>f", bp.grep_live, "Grep")
mapn("<leader>h", ep.history, "History")
mapn("<leader>k", ep.keymaps, "Keymaps")
mapn("<leader>m", ep.marks, "Marks")
mapn("<leader>o", ep.oldfiles, "Old Files")
mapn("<leader>r", ep.registers, "Registers")
mapn("<leader>t", ep.treesitter, "Treesitter")
mapn("<leader>:", ep.commands, "Commands")
mapn("<leader>.", bp.resume, "Resume")
mapn("<leader>/", bp.grep, "Grep Pattern")
mapn("<leader>?", bp.help, "Help")

local sessions = require("mini.sessions")
mapn("<leader>ss", sessions.select, "Select")
mapn("<leader>sw", function() sessions.write(vim.fn.fnamemodify(vim.fn.getcwd(), ":t") .. ".vim") end, "Write")

mapn("<F2>", vim.lsp.buf.rename, "Rename")
mapn("<F4>", vim.lsp.buf.code_action, "Code Action")
mapn("<F12>", vim.lsp.buf.definition, "Goto Definition")

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("MyLspGroup", { clear = true }),
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    local bufnr = args.buf
    if client then
      -- Format on save
      if client:supports_method("textDocument/formatting") then
        vim.api.nvim_create_autocmd("BufWritePre", {
          buffer = bufnr,
          callback = function() vim.lsp.buf.format { bufnr = bufnr, id = client.id, async = false, } end
        })
      end
      -- Completion
      if client:supports_method("textDocument/completion") then
        vim.opt.completeopt = { "menu", "menuone", "noinsert", "fuzzy", "popup" }
        vim.lsp.completion.enable(true, client.id, bufnr, { autotrigger = true })
        map("i", "<C-Space>", function() vim.lsp.completion.get() end, { desc = "Trigger LSP Completion" })
      end
      if client:supports_method("textDocument/inlineCompletion") then
        vim.opt.completeopt = { "menu", "menuone", "noinsert", "fuzzy", "popup" }
        vim.lsp.inline_completion.enable(true)
        map("i", "<Tab>", function()
          if not vim.lsp.inline_completion.get() then return "<Tab>" end
        end, { expr = true, replace_keycodes = true, desc = "Accept Inline Completion" })
      end
      if client:supports_method('textDocument/signatureHelp') then
        map('n', '<C-s>', function() vim.lsp.buf.signature_help() end, { desc = "Trigger Lsp Signature Help" })
      end
    end

    local p = require("mini.extra").pickers
    mapn("<leader>ld", function() p.diagnostic() end, "Diagnostics", bufnr)
    mapn("<leader>lf", function() vim.lsp.buf.format { bufnr = bufnr, async = true } end, "Format Buffer")
    mapn("<leader>le", function() p.lsp({ scope = "declaration" }) end, "Declaration", bufnr)
    mapn("<leader>li", function() p.lsp({ scope = "implementation" }) end, "Implementation", bufnr)
    mapn("<leader>lr", function() p.lsp({ scope = "references" }) end, "References", bufnr)
    mapn("<leader>lt", function() p.lsp({ scope = "type_definition" }) end, "Type Definition", bufnr)
    mapn("<leader>ls", function() p.lsp({ scope = "document_symbol" }) end, "Document Symbols", bufnr)
    mapn("<leader>lw", function() p.lsp({ scope = "workspace_symbol" }) end, "Workspace Symbols", bufnr)
  end,
})

require("gitsigns").setup({
  preview_config = { border = "rounded" },
  on_attach = function(bufnr)
    local gs = require("gitsigns")

    -- Git Navigation using <C-M-?> prefix
    --- @diagnostic disable-next-line: param-type-mismatch
    mapn("<C-M-j>", function() gs.nav_hunk("next", { target = "all", preview = true }) end, "Next Hunk", bufnr)
    --- @diagnostic disable-next-line: param-type-mismatch
    mapn("<C-M-k>", function() gs.nav_hunk("prev", { target = "all", preview = true }) end, "Previous Hunk", bufnr)
    --- @diagnostic disable-next-line: param-type-mismatch
    mapn("<C-M-u>", function() gs.nav_hunk("next", { target = "unstaged", preview = true }) end, "Next Unstaged Hunk",
      bufnr)
    --- @diagnostic disable-next-line: param-type-mismatch
    mapn("<C-M-U>", function() gs.nav_hunk("prev", { target = "unstaged", preview = true }) end, "Previous Unstaged Hunk",
      bufnr)

    mapn("<C-M-Space>", gs.stage_hunk, "Toggle Stage", bufnr)
    mapn("<C-M-r>", gs.reset_hunk, "Reset Hunk", bufnr)
    mapn("<C-M-b>", gs.blame_line, "Show Line Blame", bufnr)
    mapn("<C-M-l>", gs.toggle_current_line_blame, "Toggle Line Blame", bufnr)
    mapn("<C-M-S>", gs.stage_buffer, "Stage Buffer", bufnr)
    mapn("<C-M-R>", gs.reset_buffer, "Reset Buffer", bufnr)
    mapn("<C-M-g>", function() ep.git_hunks() end, "Status")
  end,
})

-- Clues
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
    -- Groups
    { mode = "n", keys = "<leader>l", desc = " LSP" },
    { mode = "n", keys = "<leader>s", desc = " Session" },
  },
  window = { config = { width = "auto" }, delay = 0 },
})
