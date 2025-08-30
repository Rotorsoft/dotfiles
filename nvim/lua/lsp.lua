vim.lsp.config = {
  _configs = {},
  lua_ls = {
    cmd = { "lua-language-server" },
    filetypes = { "lua" },
    root_markers = { ".luarc.json", ".luarc.jsonc", ".luacheckrc", ".stylua.toml", "stylua.toml", "selene.toml", "selene.yml", ".git", },
    settings = {
      Lua = {
        runtime = { version = "LuaJIT" },
        diagnostics = { globals = { "vim", "require" } },
        workspace = { library = vim.api.nvim_get_runtime_file("", true) },
        telemetry = { enable = false },
      },
    },
  },
  ts_ls = {
    init_options = { hostInfo = 'neovim' },
    cmd = { 'typescript-language-server', '--stdio' },
    filetypes = { 'javascript', 'javascriptreact', 'javascript.jsx', 'typescript', 'typescriptreact', 'typescript.tsx', },
    root_dir = function(bufnr, on_dir)
      -- The project root is where the LSP can be started from
      -- As stated in the documentation above, this LSP supports monorepos and simple projects.
      -- We select then from the project root, which is identified by the presence of a package
      -- manager lock file.
      local root_markers = { 'package-lock.json', 'yarn.lock', 'pnpm-lock.yaml', 'bun.lockb', 'bun.lock' }
      -- Give the root markers equal priority by wrapping them in a table
      root_markers = vim.fn.has('nvim-0.11.3') == 1 and { root_markers } or root_markers
      local project_root = vim.fs.root(bufnr, root_markers)
      if not project_root then
        return
      end
      on_dir(project_root)
    end,
    handlers = {
      -- handle rename request for certain code actions like extracting functions / types
      ['_typescript.rename'] = function(_, result, ctx)
        local client = assert(vim.lsp.get_client_by_id(ctx.client_id))
        vim.lsp.util.show_document({
          uri = result.textDocument.uri,
          range = {
            start = result.position,
            ['end'] = result.position,
          },
        }, client.offset_encoding)
        vim.lsp.buf.rename()
        return vim.NIL
      end,
    },
    commands = {
      ['editor.action.showReferences'] = function(command, ctx)
        local client = assert(vim.lsp.get_client_by_id(ctx.client_id))
        local file_uri, position, references = unpack(command.arguments)
        --- @diagnostic disable-next-line: param-type-mismatch
        local quickfix_items = vim.lsp.util.locations_to_items(references, client.offset_encoding)
        vim.fn.setqflist({}, ' ', {
          title = command.title,
          items = quickfix_items,
          context = {
            command = command,
            bufnr = ctx.bufnr,
          },
        })
        vim.lsp.util.show_document({
          --- @diagnostic disable-next-line: assign-type-mismatch
          uri = file_uri,
          range = {
            --- @diagnostic disable-next-line: assign-type-mismatch
            start = position,
            --- @diagnostic disable-next-line: assign-type-mismatch
            ['end'] = position,
          },
        }, client.offset_encoding)

        vim.cmd('botright copen')
      end,
    },
    on_attach = function(client, bufnr)
      -- ts_ls provides `source.*` code actions that apply to the whole file. These only appear in
      -- `vim.lsp.buf.code_action()` if specified in `context.only`.
      vim.api.nvim_buf_create_user_command(bufnr, 'LspTypescriptSourceAction', function()
        local source_actions = vim.tbl_filter(function(action)
          return vim.startswith(action, 'source.')
        end, client.server_capabilities.codeActionProvider.codeActionKinds)

        vim.lsp.buf.code_action({
          --- @diagnostic disable-next-line: missing-fields
          context = {
            only = source_actions,
          },
        })
      end, {})
    end,
  }
}
vim.lsp.enable({ "lua_ls", "ts_ls" })
