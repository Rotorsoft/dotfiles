return {
  {
    "folke/lazydev.nvim",
    ft = { "lua", "typescript" },
    opts = {
      library = {
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
      },
    },
  },
  {
    "saghen/blink.cmp",
    event = "VeryLazy",
    version = "1.*",
    dependencies = {
      {
        "L3MON4D3/LuaSnip",
        version = "2.*",
        build = (function()
          if vim.fn.has("win32") == 1 or vim.fn.executable("make") == 0 then
            return
          end
          return "make install_jsregexp"
        end)(),
        dependencies = {
          {
            "rafamadriz/friendly-snippets",
            config = function()
              require("luasnip.loaders.from_vscode").lazy_load()
            end,
          },
        },
      },
      "folke/lazydev.nvim",
      "saghen/blink.compat",
      "supermaven-inc/supermaven-nvim",
    },
    --- @module 'blink.cmp'
    --- @type blink.cmp.Config
    opts = {
      keymap = {
        preset = "default",
        ["<CR>"] = { "accept", "fallback" },
        ["<C-j>"] = { "select_next", "snippet_forward" },
        ["<C-k>"] = { "select_prev", "snippet_backward" },
      },
      completion = {
        documentation = { auto_show = false, auto_show_delay_ms = 500 },
      },
      sources = {
        default = { "lsp", "path", "snippets", "lazydev" },
        providers = {
          lazydev = { module = "lazydev.integrations.blink", score_offset = 100 },
          supermaven = { name = "supermaven", module = "blink.compat.source", score_offset = 3 },
        },
      },
      snippets = { preset = "luasnip" },
      fuzzy = { implementation = "prefer_rust_with_warning" },
      signature = { enabled = true },
    },
  },
}
