return {
  "supermaven-inc/supermaven-nvim",
  config = function()
    require("supermaven-nvim").setup({
      keymaps = {
        accept_suggestion = "<Tab>",
        accept_word = "<C-j>",
        clear_suggestion = "<C-k>",
      },
      disable_inline_completion = false,
    })
  end,
}
