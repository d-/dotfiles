return {
  {
    'neovim/nvim-lspconfig',
    event = { 'BufReadPre', 'BufNewFile' },
    dependencies = {
      -- No Nerd Font: plain-Unicode package markers in the :Mason window.
      { 'mason-org/mason.nvim', opts = { ui = { icons = { package_installed = '●', package_pending = '◍', package_uninstalled = '○' } } } },
      'mason-org/mason-lspconfig.nvim',
      'WhoIsSethDaniel/mason-tool-installer.nvim',
      'saghen/blink.cmp',
    },
    config = function()
      -- Servers by their lspconfig name; mason-lspconfig installs and enables them.
      require('mason-lspconfig').setup({
        ensure_installed = { 'pyright', 'ts_ls', 'rust_analyzer', 'lua_ls', 'jsonls', 'fish_lsp' },
        -- stylua is a formatter here (conform), not a language server.
        automatic_enable = { exclude = { 'stylua' } },
      })
      -- Non-LSP tools, by their Mason package name.
      require('mason-tool-installer').setup({
        ensure_installed = {
          'black', 'stylua', 'prettier', 'neocmakelsp', 'codelldb',
          -- Linters for lint.lua. cppcheck comes from Homebrew instead.
          'ruff', 'shellcheck', 'markdownlint-cli2', 'yamllint', 'hadolint', 'cmakelint',
        },
      })

      -- Prefer Homebrew's clangd (same as Cursor): it is built with a user
      -- config dir, so ~/Library/Preferences/clangd/config.yaml can route the
      -- fallback compile through ~/.config/clang/clang++.cfg for a C++23
      -- default. Apple's /usr/bin/clangd ignores clang config files and stays
      -- the fallback when brew's LLVM is absent. Not Mason: both track the SDK.
      local brew = os.getenv('HOMEBREW_PREFIX') or '/opt/homebrew'
      local clangd = brew .. '/opt/llvm/bin/clangd'
      if vim.fn.executable(clangd) == 0 then clangd = 'clangd' end
      vim.lsp.config('clangd', {
        cmd = {
          clangd,
          '--background-index',
          '--clang-tidy',
          '--header-insertion=iwyu',
          '--completion-style=detailed',
          '--function-arg-placeholders',
          '--fallback-style=llvm',
          -- Trust Homebrew GCC as a driver so a build dir configured with
          -- g++-16 (the workshop's *-gcc presets) gets the right system
          -- include paths instead of phantom errors.
          '--query-driver=' .. brew .. '/bin/g++-*,' .. brew .. '/bin/gcc-*',
        },
      })
      vim.lsp.enable('clangd')

      vim.lsp.config('*', {
        capabilities = require('blink.cmp').get_lsp_capabilities(),
      })
      vim.lsp.config('lua_ls', {
        settings = {
          Lua = {
            workspace = { checkThirdParty = false },
            completion = { callSnippet = 'Replace' },
          },
        },
      })

      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('user_lsp_attach', { clear = true }),
        callback = function(ev)
          local function map(lhs, rhs, desc, mode)
            vim.keymap.set(mode or 'n', lhs, rhs, { buffer = ev.buf, desc = desc })
          end
          map('gd', '<Cmd>Telescope lsp_definitions<CR>', 'Goto definition')
          map('gD', vim.lsp.buf.declaration, 'Goto declaration')
          map('gr', '<Cmd>Telescope lsp_references<CR>', 'References')
          map('gi', '<Cmd>Telescope lsp_implementations<CR>', 'Goto implementation')
          map('K', vim.lsp.buf.hover, 'Hover')
          map('<C-k>', vim.lsp.buf.signature_help, 'Signature help', 'i')
          map('<leader>cd', '<Cmd>Telescope lsp_type_definitions<CR>', 'Type definition')
          map('<leader>cr', vim.lsp.buf.rename, 'Rename')
          map('<leader>ca', vim.lsp.buf.code_action, 'Code action', { 'n', 'v' })
          map('<leader>wa', vim.lsp.buf.add_workspace_folder, 'Add workspace folder')
          map('<leader>wr', vim.lsp.buf.remove_workspace_folder, 'Remove workspace folder')
          map('<leader>wl', function()
            print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
          end, 'List workspace folders')

          local client = vim.lsp.get_client_by_id(ev.data.client_id)
          if not client then return end

          -- Inlay hints (types, parameter names) on by default; <leader>ch toggles.
          if client:supports_method('textDocument/inlayHint') then
            vim.lsp.inlay_hint.enable(true, { bufnr = ev.buf })
            map('<leader>ch', function()
              vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = ev.buf }), { bufnr = ev.buf })
            end, 'Toggle inlay hints')
          end

          -- Call and type hierarchy are built in (0.10+) but unmapped by default.
          if client:supports_method('callHierarchy/incomingCalls') then
            map('<leader>cI', vim.lsp.buf.incoming_calls, 'Incoming calls')
            map('<leader>cO', vim.lsp.buf.outgoing_calls, 'Outgoing calls')
          end
          if client:supports_method('textDocument/prepareTypeHierarchy') then
            map('<leader>cT', function() vim.lsp.buf.typehierarchy('subtypes') end, 'Subtypes')
            map('<leader>cU', function() vim.lsp.buf.typehierarchy('supertypes') end, 'Supertypes')
          end

          -- Highlight other uses of the symbol under the cursor after `updatetime`.
          if client:supports_method('textDocument/documentHighlight') then
            local group = vim.api.nvim_create_augroup('user_lsp_highlight_' .. ev.buf, { clear = true })
            vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
              group = group, buffer = ev.buf, callback = vim.lsp.buf.document_highlight,
            })
            vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI', 'BufLeave' }, {
              group = group, buffer = ev.buf, callback = vim.lsp.buf.clear_references,
            })
            vim.api.nvim_create_autocmd('LspDetach', {
              group = group, buffer = ev.buf,
              callback = function() vim.api.nvim_clear_autocmds({ group = group }) end,
            })
          end

          if client.name == 'clangd' then
            map('<leader>cs', '<Cmd>LspClangdSwitchSourceHeader<CR>', 'Switch source/header')
            map('<leader>ci', '<Cmd>LspClangdShowSymbolInfo<CR>', 'Symbol info')
          end
        end,
      })
    end,
  },

  -- Lua LSP knows about the Neovim API and plugin sources when editing config.
  { 'folke/lazydev.nvim', ft = 'lua', opts = {} },
}
