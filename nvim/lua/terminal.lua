local M = { floating = { buf = -1, win = -1, } }

local function create_floating_window(opts)
  opts = opts or {}
  local width = opts.width or math.floor(vim.o.columns * 0.8)
  local height = opts.height or math.floor(vim.o.lines * 0.8)
  local col = math.floor((vim.o.columns - width) / 2)
  local row = math.floor((vim.o.lines - height) / 2)

  local buf = nil
  if vim.api.nvim_buf_is_valid(opts.buf) then
    buf = opts.buf
  else
    buf = vim.api.nvim_create_buf(false, true)
  end

  local win = vim.api.nvim_open_win(buf, true,
    {
      relative = "editor",
      width = width,
      height = height,
      col = col,
      row = row,
      style = "minimal",
      border = "rounded",
    }
  )
  return { buf = buf, win = win }
end

function M.toggle()
  if not vim.api.nvim_win_is_valid(M.floating.win) then
    M.floating = create_floating_window { buf = M.floating.buf }
    if vim.bo[M.floating.buf].buftype ~= "terminal" then
      vim.cmd.terminal()
    end
  else
    vim.api.nvim_win_hide(M.floating.win)
  end
end

function M.setup()
  vim.api.nvim_create_user_command("ToggleTerminal", M.toggle, {})
end

return M
