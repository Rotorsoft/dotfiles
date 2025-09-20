local map = vim.keymap.set
local function mapn(lhs, rhs, desc, buffer)
  map("n", lhs, rhs, { desc = desc, buffer = buffer, silent = true, noremap = true })
end

mapn("<leader>w", function()
  local name = vim.api.nvim_buf_get_name(0)
  if name == "" then
    vim.notify("Buffer has no name, use :w filename", vim.log.levels.ERROR)
  else
    vim.cmd.write()
  end
end, "Write")
mapn("<leader>x", function()
  if vim.api.nvim_get_current_buf() > 0 then
    vim.cmd.bdelete()
  else
    vim.notify("No buffer to delete", vim.log.levels.WARN)
  end
end, "Close")
mapn("<leader>q", function() vim.cmd.qa() end, "Quit")

-- Clear highlights on search when pressing <Esc> in normal mode
mapn("<Esc>", function() vim.cmd.nohlsearch() end)

-- Easy terminal escape
map("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit Terminal Mode", silent = true, noremap = true })

local pick = require("mini.pick")
mapn("<leader><leader>", pick.builtin.files, "Files")
mapn("<leader>b", pick.builtin.buffers, "Buffers")
mapn("<leader>d", vim.diagnostic.open_float, "Diagnostic")
mapn("<leader>e", function() require("mini.files").open(vim.fn.expand("%:p:h")) end, "Explore Here")
mapn("<leader>E", function() require("mini.files").open() end, "Explore All")
mapn("<leader>G", function() pick.builtin.cli({ command = { 'rg', '--files', '--hidden', '--no-ignore' }, }) end,
  "Grep All")
mapn("<leader>g", pick.builtin.grep_live, "Grep")
mapn("<leader>.", pick.builtin.resume, "Resume")
mapn("<leader>/", pick.builtin.grep, "Grep Pattern")
mapn("<leader>?", pick.builtin.help, "Help")

local extra = require("mini.extra")
mapn("<leader>fb", extra.pickers.git_branches, "Git Branches")
mapn("<leader>fh", extra.pickers.history, "History")
mapn("<leader>fk", extra.pickers.keymaps, "Keymaps")
mapn("<leader>fm", extra.pickers.marks, "Marks")
mapn("<leader>fo", extra.pickers.oldfiles, "Old Files")
mapn("<leader>fr", extra.pickers.registers, "Registers")
mapn("<leader>fT", extra.pickers.treesitter, "Treesitter")
mapn("<leader>f:", extra.pickers.commands, "Commands")
mapn("<leader>fq", function() extra.pickers.list({ scope = 'quickfix' }) end, "Quickfix List")
mapn("<leader>fl", function() extra.pickers.list({ scope = 'location' }) end, "Location List")
mapn("<leader>fj", function() extra.pickers.list({ scope = 'jump' }) end, "Jump List")
mapn("<leader>fc", function() extra.pickers.list({ scope = 'change' }) end, "Change List")

local sessions = require("mini.sessions")
mapn("<leader>ss", sessions.select, "Select")
mapn("<leader>sw", function() sessions.write(vim.fn.fnamemodify(vim.fn.getcwd(), ":t") .. ".vim") end, "Write")

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("MyLspGroup", { clear = true }),
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    local bufnr = args.buf

    if client then
      -- Show all supported code actions
      local code_actions = function()
        vim.lsp.buf.code_action({
          apply = false,
          context = {
            only = client.server_capabilities.codeActionProvider.codeActionKinds,
            diagnostics = vim.diagnostic.get(bufnr),
          },
          filter = function(action)
            return not action.disabled
          end,
        })
      end

      -- Organize imports and format buffer
      local function organize_and_format()
        local params = {
          textDocument = vim.lsp.util.make_text_document_params(bufnr),
          range = {
            start = { line = 0, character = 0 },
            ["end"] = { line = vim.api.nvim_buf_line_count(bufnr), character = 0 },
          },
          context = {
            only = { "source.organizeImports" },
            diagnostics = vim.diagnostic.get(bufnr),
            triggerKind = vim.lsp.protocol.CodeActionTriggerKind.Invoked,
          },
        }
        -- Make sync request so it completes before write
        local results = vim.lsp.buf_request_sync(bufnr, "textDocument/codeAction", params, 1000)
        for _, res in pairs(results or {}) do
          for _, action in ipairs(res.result or {}) do
            -- Apply edits first (respect client offset encoding)
            if action.edit then
              vim.lsp.util.apply_workspace_edit(action.edit, client.offset_encoding)
            end
            -- Then execute any command
            if action.command then
              client:exec_cmd(action.command, { bufnr = bufnr })
            end
          end
        end

        -- format buffer
        if client:supports_method("textDocument/formatting") then
          vim.lsp.buf.format { bufnr = bufnr, async = false }
        end
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

      -- Organize imports and format on save
      if client:supports_method("textDocument/formatting") then
        vim.api.nvim_create_autocmd("BufWritePre", { buffer = bufnr, callback = organize_and_format })
      end

      local p = require("mini.extra").pickers
      mapn("<F2>", vim.lsp.buf.rename, "Rename")
      mapn("<F4>", code_actions, "Code Actions")
      mapn("<F12>", vim.lsp.buf.definition, "Goto Definition")
      mapn("<leader>lf", organize_and_format, "Organize Imports/Format Buffer")
      mapn("<leader>ld", function() p.diagnostic() end, "Diagnostics", bufnr)
      mapn("<leader>le", function() p.lsp({ scope = "declaration" }) end, "Declaration", bufnr)
      mapn("<leader>li", function() p.lsp({ scope = "implementation" }) end, "Implementation", bufnr)
      mapn("<leader>lr", function() p.lsp({ scope = "references" }) end, "References", bufnr)
      mapn("<leader>lt", function() p.lsp({ scope = "type_definition" }) end, "Type Definition", bufnr)
      mapn("<leader>ls", function() p.lsp({ scope = "document_symbol" }) end, "Document Symbols", bufnr)
      mapn("<leader>lw", function() p.lsp({ scope = "workspace_symbol" }) end, "Workspace Symbols", bufnr)
    end
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
    { mode = "n", keys = "<leader>l", desc = " LSP" },
    { mode = "n", keys = "<leader>s", desc = " Session" },
  },
  window = { config = { width = "auto" }, delay = 0 },
})
