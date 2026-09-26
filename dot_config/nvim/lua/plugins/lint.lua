-- Linters that are not language servers. LSP diagnostics (pyright, lua_ls,
-- ts_ls, clangd with clang-tidy) still come from lsp.lua; this adds the
-- standalone tools on top. Tools come from Mason (see lsp.lua) except
-- cppcheck (Homebrew) and fish (the shell itself).
return {
  'mfussenegger/nvim-lint',
  event = { 'BufReadPost', 'BufNewFile', 'BufWritePost' },
  keys = {
    { '<leader>cl', function() require('lint').try_lint() end, desc = 'Lint now' },
  },
  config = function()
    local lint = require('lint')

    lint.linters_by_ft = {
      python = { 'ruff' },
      sh = { 'shellcheck' },
      bash = { 'shellcheck' },
      fish = { 'fish' },
      c = { 'cppcheck' },
      cpp = { 'cppcheck' },
      cmake = { 'cmakelint' },
      markdown = { 'markdownlint-cli2' },
      yaml = { 'yamllint' },
      dockerfile = { 'hadolint' },
    }

    -- cppcheck: clangd's clang-tidy already covers style, so keep cppcheck to
    -- the checks that find real bugs, and read the project's compile database
    -- when there is one so headers resolve.
    local cppcheck = lint.linters.cppcheck
    cppcheck.args = {
      '--enable=warning,performance,portability',
      '--inline-suppr',
      '--quiet',
      '--template={file}:{line}:{column}: [{id}] {severity}: {message}',
      function()
        local db = vim.fs.find('compile_commands.json', { upward = true, path = vim.fn.expand('%:p:h') })[1]
        return db and ('--project=' .. db) or ('--language=' .. (vim.bo.filetype == 'c' and 'c' or 'c++'))
      end,
    }

    -- yamllint: warnings for the noisy defaults (document-start, line-length).
    lint.linters.yamllint.args = {
      '-d', '{extends: default, rules: {document-start: disable, line-length: {max: 120, level: warning}}}',
      '--format', 'parsable', '-',
    }

    -- Only run linters whose executable is actually present, so a fresh
    -- machine gets diagnostics as tools arrive rather than error popups.
    local function try_lint()
      local names = lint._resolve_linter_by_ft(vim.bo.filetype)
      names = vim.tbl_filter(function(name)
        local linter = lint.linters[name]
        local cmd = type(linter.cmd) == 'function' and linter.cmd() or linter.cmd
        return vim.fn.executable(cmd) == 1
      end, names)
      if #names > 0 then lint.try_lint(names) end
    end

    -- Lint on open and save immediately; debounce while typing.
    local timer = assert(vim.uv.new_timer())
    local group = vim.api.nvim_create_augroup('user_lint', { clear = true })
    vim.api.nvim_create_autocmd({ 'BufReadPost', 'BufWritePost' }, { group = group, callback = try_lint })
    vim.api.nvim_create_autocmd({ 'InsertLeave', 'TextChanged' }, {
      group = group,
      callback = function()
        timer:stop()
        timer:start(500, 0, vim.schedule_wrap(try_lint))
      end,
    })

    vim.api.nvim_create_user_command('LintInfo', function()
      local ft = vim.bo.filetype
      local configured = lint._resolve_linter_by_ft(ft)
      local lines = { 'filetype: ' .. ft }
      for _, name in ipairs(configured) do
        local linter = lint.linters[name]
        local cmd = type(linter.cmd) == 'function' and linter.cmd() or linter.cmd
        lines[#lines + 1] = string.format('  %-18s %s', name, vim.fn.executable(cmd) == 1 and vim.fn.exepath(cmd) or 'NOT FOUND: ' .. cmd)
      end
      if #configured == 0 then lines[#lines + 1] = '  (no linters configured)' end
      local running = lint.get_running()
      if #running > 0 then lines[#lines + 1] = 'running: ' .. table.concat(running, ', ') end
      vim.notify(table.concat(lines, '\n'))
    end, { desc = 'Show linters for this buffer' })
  end,
}
