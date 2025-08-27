local map = vim.keymap.set
local function mapn(lhs, rhs, desc, buffer)
  map("n", lhs, rhs, { desc = desc, buffer = buffer })
end

mapn("<leader>w", function() vim.cmd.w() end, "Write")
mapn("<leader>q", function() vim.cmd.qa() end, "Quit")
mapn("<leader>x", ":bdelete<CR>", "Close")
mapn("<Tab>", ":bnext<CR>", "Next Buffer")

mapn("<C-h>", "<C-w>h", "Move to left split")
mapn("<C-j>", "<C-w>j", "Move to below split")
mapn("<C-k>", "<C-w>k", "Move to above split")
mapn("<C-l>", "<C-w>l", "Move to right split")

mapn("<Up>", ":resize +4<CR>", "Increase height")
mapn("<Down>", ":resize -4<CR>", "Decrease height")
mapn("<Left>", ":vertical resize -4<CR>", "Decrease width")
mapn("<Right>", ":vertical resize +4<CR>", "Increase width")

-- Clear highlights on search when pressing <Esc> in normal mode
mapn("<Esc>", "<cmd>nohlsearch<CR>")

-- Easy terminal escape
map("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit Terminal Mode" })

mapn("<leader>d", vim.diagnostic.open_float, "Diagnostic")
mapn("<leader>e", function() require("mini.files").open() end, "Explore")

local bp = require("mini.pick").builtin
mapn("<leader><leader>", bp.buffers, "Buffers")
mapn("<leader>ff", bp.files, "Files")
mapn("<leader>fg", bp.grep, "Grep")
mapn("<leader>fl", bp.grep_live, "Live Grep")
mapn("<leader>f?", bp.help, "Help")
mapn("<leader>f.", bp.resume, "Resume")

local ep = require("mini.extra").pickers
mapn("<leader>fo", ep.oldfiles, "Old Files")
mapn("<leader>fc", ep.commands, "Commands")
mapn("<leader>fk", ep.keymaps, "Keymaps")
mapn("<leader>fm", ep.marks, "Marks")
mapn("<leader>fr", ep.registers, "Registers")
mapn("<leader>fh", ep.history, "History")
mapn("<leader>fe", ep.explorer, "Explorer")
mapn("<leader>ft", ep.treesitter, "Treesitter")
mapn("<leader>fs", ep.colorschemes, "Color Schemes")

local sessions = require("mini.sessions")
mapn("<leader>ss", sessions.select, "Select")
mapn("<leader>sw", function() sessions.write(vim.fn.fnamemodify(vim.fn.getcwd(), ":t") .. ".vim") end, "Write")

mapn("<F2>", vim.lsp.buf.rename, "Rename")
mapn("<F4>", vim.lsp.buf.code_action, "Code Action")
mapn("<F12>", vim.lsp.buf.definition, "Goto Definition")
mapn("<leader>cf", vim.lsp.buf.format, "Format Buffer")

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
          callback = function()
            vim.lsp.buf.format { bufnr = bufnr, id = client.id, async = false, }
          end
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
    mapn("<leader>cd", function() p.diagnostic() end, "Diagnostics", bufnr)
    mapn("<leader>ce", function() p.lsp({ scope = "declaration" }) end, "Declaration", bufnr)
    mapn("<leader>ci", function() p.lsp({ scope = "implementation" }) end, "Implementation", bufnr)
    mapn("<leader>cr", function() p.lsp({ scope = "references" }) end, "References", bufnr)
    mapn("<leader>ct", function() p.lsp({ scope = "type_definition" }) end, "Type Definition", bufnr)
    mapn("<leader>cs", function() p.lsp({ scope = "document_symbol" }) end, "Document Symbols", bufnr)
    mapn("<leader>cw", function() p.lsp({ scope = "workspace_symbol" }) end, "Workspace Symbols", bufnr)
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
    { mode = "n", keys = "<leader>f", desc = " Find" },
    { mode = "n", keys = "<leader>g", desc = " Git" },
    { mode = "n", keys = "<leader>c", desc = " Code (LSP)" },
    { mode = "n", keys = "<leader>s", desc = " Session" },
  },
  window = { config = { width = 60 }, delay = 0 },
})
