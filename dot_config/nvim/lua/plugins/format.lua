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
    -- Python always formats on save (black). C/C++ only when the project
    -- carries its own .clang-format: without one clang-format would impose
    -- LLVM style on every save, so those projects stay manual (<leader>cf).
    format_on_save = function(bufnr)
      local ft = vim.bo[bufnr].filetype
      if ft == 'python' then
        return { timeout_ms = 3000, lsp_format = 'fallback' }
      end
      if ft == 'c' or ft == 'cpp' then
        local dir = vim.fs.dirname(vim.api.nvim_buf_get_name(bufnr))
        if vim.fs.find({ '.clang-format', '_clang-format' }, { upward = true, path = dir })[1] then
          return { timeout_ms = 3000, lsp_format = 'never' }
        end
      end
    end,
  },
}
