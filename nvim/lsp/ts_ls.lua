return {
  init_options = { hostInfo = 'neovim' },
  cmd = { 'typescript-language-server', '--stdio' },
  filetypes = { 'javascript', 'javascriptreact', 'javascript.jsx', 'typescript', 'typescriptreact', 'typescript.tsx', },
  root_dir = function(bufnr, on_dir)
    local root_markers = { 'package-lock.json', 'yarn.lock', 'pnpm-lock.yaml', 'bun.lockb', 'bun.lock' }
    -- Give the root markers equal priority by wrapping them in a table
    local project_root = vim.fs.root(bufnr, { root_markers })
    if not project_root then
      return
    end
    on_dir(project_root)
  end,
}
