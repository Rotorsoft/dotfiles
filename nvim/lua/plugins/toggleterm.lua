return {
  "akinsho/toggleterm.nvim",
  version = "*",
  event = "VeryLazy",
  config = function()
    require("toggleterm").setup({
      size = function(term)
        if term.direction == "horizontal" then
          return 15
        elseif term.direction == "vertical" then
          return vim.o.columns * 0.4
        end
      end,
      hide_numbers = true,
      start_in_insert = true,
      insert_mappings = true,
      persist_size = true,
      direction = "horizontal", -- or "float" for floating terminal
      close_on_exit = true,
      shell = vim.o.shell,
    })
  end,
}
