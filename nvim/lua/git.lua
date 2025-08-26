local gs = require("gitsigns")
gs.setup({
  on_attach = function(bufnr)
    local function map(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
    end
    map("n", "<leader>gj", function()
      --- @diagnostic disable-next-line: param-type-mismatch
      gs.nav_hunk("next")
    end, "Next Hunk")
    map("n", "<leader>gk", function()
      --- @diagnostic disable-next-line: param-type-mismatch
      gs.nav_hunk("prev")
    end, "Previous Hunk")
    map("n", "<leader>gd", gs.diffthis, "Diff")
    map("n", "<leader>gp", gs.preview_hunk, "Preview Hunk")
    map("n", "<leader>gi", gs.preview_hunk_inline, "Preview Hunk Inline")
    map("n", "<leader>gs", gs.stage_hunk, "Stage Hunk")
    map("n", "<leader>gr", gs.reset_hunk, "Reset Hunk")
    map("n", "<leader>gS", gs.stage_buffer, "Stage Buffer")
    map("n", "<leader>gR", gs.reset_buffer, "Reset Buffer")
    map("n", "<leader>gB", gs.blame_line, "Blame Line")
    map("n", "<leader>gl", gs.toggle_current_line_blame, "Toggle Line Blame")

    local pickers = require("mini.extra").pickers
    vim.keymap.set("n", "<leader>gc", function()
      pickers.git_commits()
    end, { buffer = bufnr, desc = "Git Commits" })
    vim.keymap.set("n", "<leader>gb", function()
      pickers.git_branches()
    end, { buffer = bufnr, desc = "Git Branches" })
  end,
})
