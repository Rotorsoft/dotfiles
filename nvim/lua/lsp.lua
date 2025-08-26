require("mason").setup()
require("mason-lspconfig").setup()
require("mason-tool-installer").setup({ ensure_installed = { "lua_ls", "stylua", "ts_ls", "prettier" } })

require("supermaven-nvim").setup({
  keymaps = {
    accept_suggestion = "<Tab>",
    accept_word = "<C-j>",
    clear_suggestion = "<C-k>",
  },
  disable_inline_completion = false,
})

local cmp = require("cmp")
local capabilities = require("cmp_nvim_lsp").default_capabilities()
cmp.setup({
  snippet = {
    expand = function(args)
      require("luasnip").lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ["<C-Space>"] = cmp.mapping.complete(),
    ["<CR>"] = cmp.mapping.confirm({ select = true }),
    ["<C-j>"] = cmp.mapping.select_next_item(),
    ["<C-k>"] = cmp.mapping.select_prev_item(),
    ["<Tab>"] = cmp.mapping(function(fallback)
      if vim.g.ai_accept and vim.g.ai_accept() then
        return
      end
      fallback()
    end, { "i", "s" }),
  }),
  sources = {
    { name = "supermaven" },
    { name = "nvim_lsp" },
    { name = "luasnip" },
    { name = "buffer" },
    { name = "path" },
  },
  window = {
    completion = cmp.config.window.bordered({ border = "rounded" }),
    documentation = cmp.config.window.bordered({ border = "rounded" }),
  },
})

vim.lsp.config("lua_ls", {
  capabilities = capabilities,
  settings = {
    Lua = {
      runtime = { version = "LuaJIT" },
      diagnostics = { globals = { "vim", "require" } },
      workspace = {
        library = vim.api.nvim_get_runtime_file("", true),
      },
      telemetry = { enable = false },
    },
  },
})

vim.lsp.config("ts_ls", { capabilities = capabilities })

vim.diagnostic.config({
  severity_sort = true,
  float = { border = "rounded", source = true },
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
vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float, { desc = "Open Diagnostic" })

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local bufnr = args.buf
    local pickers = require("mini.extra").pickers

    vim.keymap.set("n", "<F2>", vim.lsp.buf.rename, { desc = "Rename" })
    vim.keymap.set("n", "<F4>", vim.lsp.buf.code_action, { desc = "Code Action" })
    vim.keymap.set("n", "<F12>", vim.lsp.buf.definition, { desc = "Goto Definition" })

    vim.keymap.set("n", "<leader>cd", function()
      pickers.diagnostic()
    end, { buffer = bufnr, desc = "Diagnostics" })
    vim.keymap.set("n", "<leader>cs", function()
      pickers.lsp({ scope = "document_symbol" })
    end, { buffer = bufnr, desc = "Document Symbols" })
    vim.keymap.set("n", "<leader>cw", function()
      pickers.lsp({ scope = "workspace_symbol" })
    end, { buffer = bufnr, desc = "Workspace Symbols" })
    vim.keymap.set("n", "<leader>ce", function()
      pickers.lsp({ scope = "declaration" })
    end, { buffer = bufnr, desc = "Declaration" })
    vim.keymap.set("n", "<leader>ci", function()
      pickers.lsp({ scope = "implementation" })
    end, { buffer = bufnr, desc = "Implementation" })
    vim.keymap.set("n", "<leader>cr", function()
      pickers.lsp({ scope = "references" })
    end, { buffer = bufnr, desc = "References" })
    vim.keymap.set("n", "<leader>ct", function()
      pickers.lsp({ scope = "type_definition" })
    end, { buffer = bufnr, desc = "Type Definition" })
  end,
})

local conform = require("conform")
conform.setup({
  format_on_save = { timeout_ms = 500, lsp_format = "fallback" },
  formatters_by_ft = {
    lua = { "stylua" },
    typescript = { "prettier" },
    typescriptreact = { "prettier" },
    json = { "prettier" },
    markdown = { "prettier" },
  },
})
vim.keymap.set("n", "<leader>cf", function()
  conform.format({ async = true, lsp_format = "fallback" })
end, { desc = "Format Buffer" })
