-- override ui selector
vim.ui.select = require("mini.pick").ui_select

-- override colorscheme for more transparency
vim.api.nvim_set_hl(0, "CursorLine", { bg = "none", underline = false, blend = 20 })
vim.api.nvim_set_hl(0, "CursorLineNr", { fg = "#FFD700", bg = "none", bold = true })

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
      { "filesize",   separator = "/",                  padding = { left = 1, right = 0 } },
      { "progress",   padding = { left = 0, right = 1 } },
    },
    lualine_z = { { "location" } },
  },
  inactive_sections = {
    lualine_c = { "filename" },
    lualine_x = { "location" },
  },
  extensions = {},
})
