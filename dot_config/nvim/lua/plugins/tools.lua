-- Test running, assembly inspection, doc-comment generation and a diagnostics
-- panel. C++-focused but language-neutral where the plugin allows.
return {
  -- Run/debug tests from the buffer. CTest adapter: anything CMake registers
  -- with add_test() (doctest, gtest, catch2) shows up, no framework plugin needed.
  {
    'nvim-neotest/neotest',
    dependencies = {
      'nvim-neotest/nvim-nio',
      'nvim-lua/plenary.nvim',
      'nvim-treesitter/nvim-treesitter',
      'orjangj/neotest-ctest',
    },
    keys = {
      { '<leader>tt', function() require('neotest').run.run() end, desc = 'Run nearest test' },
      { '<leader>tf', function() require('neotest').run.run(vim.fn.expand('%')) end, desc = 'Run file tests' },
      { '<leader>ta', function() require('neotest').run.run(vim.uv.cwd()) end, desc = 'Run all tests' },
      { '<leader>td', function() require('neotest').run.run({ strategy = 'dap' }) end, desc = 'Debug nearest test' },
      { '<leader>tl', function() require('neotest').run.run_last() end, desc = 'Run last test' },
      { '<leader>ts', function() require('neotest').summary.toggle() end, desc = 'Test summary' },
      { '<leader>to', function() require('neotest').output.open({ enter = true, auto_close = true }) end, desc = 'Test output' },
      { '<leader>tO', function() require('neotest').output_panel.toggle() end, desc = 'Test output panel' },
      { '<leader>tS', function() require('neotest').run.stop() end, desc = 'Stop tests' },
      { ']t', function() require('neotest').jump.next({ status = 'failed' }) end, desc = 'Next failed test' },
      { '[t', function() require('neotest').jump.prev({ status = 'failed' }) end, desc = 'Previous failed test' },
    },
    opts = function()
      return {
        adapters = {
          require('neotest-ctest').setup({
            -- Debug a test through the codelldb adapter from cpp.lua.
            dap_adapter = 'codelldb',
            -- Default only matches *_test.cpp; the workshop names them *_ut.cpp.
            is_test_file = function(path)
              local name = vim.fs.basename(path)
              return name:match('%.c[cp]?[px]?$') ~= nil
                and (name:match('_test%.') or name:match('_ut%.') or name:match('^test_') or name:match('Test%.')) ~= nil
            end,
          }),
        },
        -- No Nerd Font: plain-Unicode status and tree markers.
        icons = {
          passed = '✓', failed = '✗', running = '…', skipped = '○', unknown = '?', watching = '◉',
          expanded = '▾', collapsed = '▸', final_child_prefix = '└', child_prefix = '├',
          child_indent = '│', final_child_indent = ' ', non_collapsible = '─',
          running_animated = { '⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏' },
        },
        summary = { open = 'botright vsplit | vertical resize 44' },
        output = { open_on_run = false },
        quickfix = { enabled = false },
      }
    end,
  },

  -- Compiler Explorer (godbolt.org): assembly for the buffer or a selection.
  {
    'krady21/compiler-explorer.nvim',
    cmd = { 'CECompile', 'CECompileLive', 'CEFormat', 'CEAddLibrary', 'CELoadExample', 'CEOpenWebsite', 'CEDeleteCache', 'CEShowTooltip', 'CEGotoLabel' },
    keys = {
      { '<leader>ce', '<Cmd>CECompile<CR>', mode = { 'n', 'v' }, desc = 'Compiler Explorer' },
      { '<leader>cE', '<Cmd>CECompileLive<CR>', desc = 'Compiler Explorer (live)' },
    },
    opts = {
      -- Assembly in a vertical split; the matching asm is highlighted as the
      -- cursor moves through the source. Compiler and flags are picked via
      -- vim.ui.select on each :CECompile.
      split = 'vsplit',
      line_match = { highlight = true, jump = false },
      open_qflist = false,
    },
  },

  -- Doxygen comment skeleton for the function/class under the cursor.
  {
    'danymat/neogen',
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    cmd = 'Neogen',
    keys = {
      { '<leader>cg', function() require('neogen').generate() end, desc = 'Generate doc comment' },
    },
    opts = {
      snippet_engine = 'nvim',
      languages = {
        cpp = { template = { annotation_convention = 'doxygen' } },
        c = { template = { annotation_convention = 'doxygen' } },
      },
    },
  },

  -- Diagnostics / quickfix / references / symbols in one panel.
  {
    'folke/trouble.nvim',
    cmd = 'Trouble',
    keys = {
      { '<leader>xx', '<Cmd>Trouble diagnostics toggle<CR>', desc = 'Diagnostics (workspace)' },
      { '<leader>xX', '<Cmd>Trouble diagnostics toggle filter.buf=0<CR>', desc = 'Diagnostics (buffer)' },
      { '<leader>xs', '<Cmd>Trouble symbols toggle focus=false<CR>', desc = 'Symbols' },
      { '<leader>xr', '<Cmd>Trouble lsp toggle focus=false win.position=right<CR>', desc = 'LSP references / definitions' },
      { '<leader>xq', '<Cmd>Trouble qflist toggle<CR>', desc = 'Quickfix list' },
      { '<leader>xl', '<Cmd>Trouble loclist toggle<CR>', desc = 'Location list' },
    },
    opts = {
      -- No Nerd Font: text markers instead of glyphs.
      icons = {
        indent = {
          top = '│ ', middle = '├╴', last = '└╴', fold_open = '▾ ', fold_closed = '▸ ', ws = '  ',
        },
        folder_closed = '▸ ', folder_open = '▾ ',
        kinds = {
          Array = '[] ', Boolean = 'bool ', Class = 'class ', Constant = 'const ', Constructor = 'ctor ',
          Enum = 'enum ', EnumMember = 'enum ', Event = 'event ', Field = 'field ', File = 'file ',
          Function = 'fn ', Interface = 'iface ', Key = 'key ', Method = 'method ', Module = 'mod ',
          Namespace = 'ns ', Null = 'null ', Number = 'num ', Object = 'obj ', Operator = 'op ',
          Package = 'pkg ', Property = 'prop ', String = 'str ', Struct = 'struct ', TypeParameter = 'T ',
          Variable = 'var ',
        },
      },
    },
  },
}
