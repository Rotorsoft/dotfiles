return {
  "nvim-lualine/lualine.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    require("lualine").setup({
      options = {
        theme = "auto",
        component_separators = { left = "", right = "" },
        section_separators = { left = "", right = "" }, -- pill look
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
          { "filetype", icon_only = true, padding = { left = 1, right = 0 } },
          { "progress" },
        },
        lualine_z = { { "location", padding = { left = 0, right = 1 } } },
      },
      inactive_sections = {
        lualine_c = { "filename" },
        lualine_x = { "location" },
      },
      extensions = {},
    })
  end,
}
