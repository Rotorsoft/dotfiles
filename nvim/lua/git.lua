local gs = require("gitsigns")
gs.setup({
  preview_config = { border = "rounded" },
  on_attach = function(bufnr)
    local function map(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
    end
    map("n", "<C-M-j>", function()
      --- @diagnostic disable-next-line: param-type-mismatch
      gs.nav_hunk("next", { target = "all", preview = true })
    end, "Next Hunk")
    map("n", "<C-M-k>", function()
      --- @diagnostic disable-next-line: param-type-mismatch
      gs.nav_hunk("prev", { target = "all", preview = true })
    end, "Previous Hunk")
    map("n", "<C-M-Space>", gs.stage_hunk, "Toggle Stage")
    map("n", "<leader>gr", gs.reset_hunk, "Reset Hunk")
    map("n", "<leader>gb", gs.blame_line, "Blame Line")
    map("n", "<leader>gl", gs.toggle_current_line_blame, "Toggle Line Blame")
    map("n", "<leader>gS", gs.stage_buffer, "Stage Buffer")
    map("n", "<leader>gR", gs.reset_buffer, "Reset Buffer")
  end,
})
