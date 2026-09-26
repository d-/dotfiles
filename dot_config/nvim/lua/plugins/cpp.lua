-- C++ build and debug. clangd itself is configured in lsp.lua.
return {
  -- CMake: configure/build/run/debug from inside Neovim (like the VS Code extension).
  {
    'Civitasv/cmake-tools.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
    ft = { 'c', 'cpp', 'cmake' },
    cmd = { 'CMakeGenerate', 'CMakeBuild', 'CMakeRun', 'CMakeDebug', 'CMakeSelectBuildType', 'CMakeSelectBuildTarget', 'CMakeSelectLaunchTarget', 'CMakeClean', 'CMakeOpenExecutor' },
    keys = {
      { '<leader>bg', '<Cmd>CMakeGenerate<CR>', desc = 'CMake generate' },
      { '<leader>bb', '<Cmd>CMakeBuild<CR>', desc = 'CMake build' },
      { '<leader>br', '<Cmd>CMakeRun<CR>', desc = 'CMake run' },
      { '<leader>bd', '<Cmd>CMakeDebug<CR>', desc = 'CMake debug' },
      { '<leader>bt', '<Cmd>CMakeSelectBuildTarget<CR>', desc = 'Select build target' },
      { '<leader>bl', '<Cmd>CMakeSelectLaunchTarget<CR>', desc = 'Select launch target' },
      { '<leader>bT', '<Cmd>CMakeSelectBuildType<CR>', desc = 'Select build type' },
      { '<leader>bc', '<Cmd>CMakeClean<CR>', desc = 'CMake clean' },
      { '<leader>bo', '<Cmd>CMakeOpenExecutor<CR>', desc = 'Open build output' },
    },
    opts = {
      cmake_command = 'cmake',
      cmake_build_directory = 'build/${variant:buildType}',
      cmake_generate_options = { '-DCMAKE_EXPORT_COMPILE_COMMANDS=1', '-G', 'Ninja' },
      cmake_build_options = { '-j' },
      -- Symlink compile_commands.json into the project root so clangd finds it.
      cmake_soft_link_compile_commands = true,
      cmake_executor = { name = 'quickfix', opts = { show = 'only_on_error' } },
      cmake_runner = { name = 'terminal' },
      cmake_dap_configuration = {
        name = 'cpp',
        type = 'codelldb',
        request = 'launch',
        stopOnEntry = false,
        runInTerminal = true,
        console = 'integratedTerminal',
      },
    },
  },

  -- Debugging via codelldb (installed by Mason).
  {
    'mfussenegger/nvim-dap',
    dependencies = {
      { 'rcarriga/nvim-dap-ui', dependencies = { 'nvim-neotest/nvim-nio' } },
      'theHamsta/nvim-dap-virtual-text',
    },
    keys = {
      { '<leader>db', function() require('dap').toggle_breakpoint() end, desc = 'Toggle breakpoint' },
      { '<leader>dB', function() require('dap').set_breakpoint(vim.fn.input('Condition: ')) end, desc = 'Conditional breakpoint' },
      { '<leader>dc', function() require('dap').continue() end, desc = 'Continue / start' },
      { '<leader>dC', function() require('dap').run_to_cursor() end, desc = 'Run to cursor' },
      { '<leader>di', function() require('dap').step_into() end, desc = 'Step into' },
      { '<leader>do', function() require('dap').step_over() end, desc = 'Step over' },
      { '<leader>dO', function() require('dap').step_out() end, desc = 'Step out' },
      { '<leader>dr', function() require('dap').repl.toggle() end, desc = 'REPL' },
      { '<leader>dl', function() require('dap').run_last() end, desc = 'Run last' },
      { '<leader>dt', function() require('dap').terminate() end, desc = 'Terminate' },
      { '<leader>du', function() require('dapui').toggle() end, desc = 'Toggle debug UI' },
      { '<leader>de', function() require('dapui').eval() end, mode = { 'n', 'v' }, desc = 'Evaluate' },
    },
    config = function()
      local dap, dapui = require('dap'), require('dapui')
      dapui.setup()
      require('nvim-dap-virtual-text').setup({})

      dap.listeners.after.event_initialized['dapui'] = function() dapui.open() end
      dap.listeners.before.event_terminated['dapui'] = function() dapui.close() end
      dap.listeners.before.event_exited['dapui'] = function() dapui.close() end

      dap.adapters.codelldb = {
        type = 'server',
        port = '${port}',
        executable = { command = 'codelldb', args = { '--port', '${port}' } },
      }
      dap.configurations.cpp = {
        {
          name = 'Launch executable',
          type = 'codelldb',
          request = 'launch',
          program = function()
            return vim.fn.input('Executable: ', vim.fn.getcwd() .. '/build/', 'file')
          end,
          cwd = '${workspaceFolder}',
          stopOnEntry = false,
        },
      }
      dap.configurations.c = dap.configurations.cpp
      dap.configurations.rust = dap.configurations.cpp

      vim.fn.sign_define('DapBreakpoint', { text = '●', texthl = 'DiagnosticError' })
      vim.fn.sign_define('DapBreakpointCondition', { text = '◆', texthl = 'DiagnosticWarn' })
      vim.fn.sign_define('DapStopped', { text = '▶', texthl = 'DiagnosticInfo', linehl = 'CursorLine' })
    end,
  },
}
