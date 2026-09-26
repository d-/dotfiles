return {
  'stevearc/conform.nvim',
  event = 'BufWritePre',
  cmd = 'ConformInfo',
  keys = {
    {
      '<leader>cf',
      function() require('conform').format({ async = true, lsp_format = 'fallback' }) end,
      mode = { 'n', 'v' },
      desc = 'Format',
    },
    {
      '<F9>',
      function() require('conform').format({ async = true, lsp_format = 'fallback' }) end,
      mode = { 'n', 'v' },
      desc = 'Format',
    },
  },
  opts = {
    formatters_by_ft = {
      python = { 'black' },
      c = { 'clang_format' },
      cpp = { 'clang_format' },
      lua = { 'stylua' },
      javascript = { 'prettier' },
      typescript = { 'prettier' },
      javascriptreact = { 'prettier' },
      typescriptreact = { 'prettier' },
      json = { 'prettier' },
      jsonc = { 'prettier' },
      yaml = { 'prettier' },
      markdown = { 'prettier' },
      css = { 'prettier' },
      html = { 'prettier' },
    },
    -- Only Python is formatted on save (black), as before.
    format_on_save = function(bufnr)
      if vim.bo[bufnr].filetype == 'python' then
        return { timeout_ms = 3000, lsp_format = 'fallback' }
      end
    end,
  },
}
