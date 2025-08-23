return {
  "echasnovski/mini.nvim",
  version = "*",
  config = function()
    require("mini.ai").setup({ n_lines = 500 })
    require("mini.align").setup()
    require("mini.comment").setup()
    require("mini.operators").setup()
    require("mini.pairs").setup()
    require("mini.surround").setup()
    require("mini.icons").setup()
    require("mini.files").setup()
    require("mini.indentscope").setup()
    require("mini.move").setup()
    require("mini.jump").setup()
    require("mini.jump2d").setup()
    require("mini.sessions").setup({ autoread = true, autowrite = true })

    local hipatterns = require("mini.hipatterns")
    hipatterns.setup({
      highlighters = {
        fixme = { pattern = "%f[%w]()FIXME()%f[%W]", group = "MiniHipatternsFixme" },
        hack = { pattern = "%f[%w]()HACK()%f[%W]", group = "MiniHipatternsHack" },
        todo = { pattern = "%f[%w]()TODO()%f[%W]", group = "MiniHipatternsTodo" },
        note = { pattern = "%f[%w]()NOTE()%f[%W]", group = "MiniHipatternsNote" },
        hex_color = hipatterns.gen_highlighter.hex_color(),
      },
    })
  end,
}
