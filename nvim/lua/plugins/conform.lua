return {
  "stevearc/conform.nvim",
  event = { "BufWritePre", "BufNewFile" },
  cmd = { "ConformInfo" },
  opts = {
    format_on_save = {
      lsp_format = "fallback",
      timeout_ms = 500,
    },
    formatters_by_ft = {
      lua = { "stylua" },
      typescript = { "prettier" },
      typescriptreact = { "prettier" },
      json = { "prettier" },
      markdown = { "prettier" },
      -- python = { "isort", "black" },
    },
  },
}
