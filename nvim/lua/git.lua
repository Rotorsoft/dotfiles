local gs = require("gitsigns")
gs.setup({
  preview_config = { border = "rounded" },
  on_attach = function(bufnr)
    local function mapn(lhs, rhs, desc)
      vim.keymap.set("n", lhs, rhs, { buffer = bufnr, desc = desc })
    end
    --- @diagnostic disable-next-line: param-type-mismatch
    mapn("<C-M-j>", function() gs.nav_hunk("next", { target = "all", preview = true }) end, "Next Hunk")
    --- @diagnostic disable-next-line: param-type-mismatch
    mapn("<C-M-k>", function() gs.nav_hunk("prev", { target = "all", preview = true }) end, "Previous Hunk")
    mapn("<C-M-Space>", gs.stage_hunk, "Toggle Stage")
    mapn("<leader>gr", gs.reset_hunk, "Reset Hunk")
    mapn("<leader>gb", gs.blame_line, "Blame Line")
    mapn("<leader>gl", gs.toggle_current_line_blame, "Toggle Line Blame")
    mapn("<leader>gS", gs.stage_buffer, "Stage Buffer")
    mapn("<leader>gR", gs.reset_buffer, "Reset Buffer")
  end,
})
