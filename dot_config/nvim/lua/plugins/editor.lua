return {
  { 'tpope/vim-sleuth', event = { 'BufReadPre', 'BufNewFile' } },

  {
    'tpope/vim-fugitive',
    dependencies = { 'tpope/vim-rhubarb' },
    cmd = { 'Git', 'G', 'Gdiffsplit', 'Gvdiffsplit', 'GBrowse', 'Gread', 'Gwrite', 'Gclog' },
    keys = {
      { '<leader>gg', '<Cmd>Git<CR>', desc = 'Fugitive status' },
      { '<leader>gB', '<Cmd>Git blame<CR>', desc = 'Blame file' },
      { '<leader>gl', '<Cmd>Git log --oneline<CR>', desc = 'Log' },
    },
  },

  -- phaazon/hop.nvim was deleted from GitHub; smoka7/hop.nvim is the maintained fork.
  {
    'smoka7/hop.nvim',
    version = '*',
    opts = { keys = 'etovxqpdygfblzhckisuran' },
    keys = {
      { '<leader>hw', '<Cmd>HopWord<CR>', mode = { 'n', 'v', 'o' }, desc = 'Hop to word' },
      { '<leader>hl', '<Cmd>HopLineStart<CR>', mode = { 'n', 'v', 'o' }, desc = 'Hop to line' },
      { '<leader>hc', '<Cmd>HopChar1<CR>', mode = { 'n', 'v', 'o' }, desc = 'Hop to char' },
      { '<leader>hp', '<Cmd>HopPattern<CR>', mode = { 'n', 'v', 'o' }, desc = 'Hop to pattern' },
    },
  },

  {
    'nvim-telescope/telescope.nvim',
    cmd = 'Telescope',
    dependencies = {
      'nvim-lua/plenary.nvim',
      { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
      'nvim-telescope/telescope-file-browser.nvim',
    },
    keys = {
      { '<leader>ff', '<Cmd>Telescope find_files<CR>', desc = 'Files' },
      { '<leader>fg', '<Cmd>Telescope live_grep<CR>', desc = 'Grep' },
      { '<leader>fw', '<Cmd>Telescope grep_string<CR>', desc = 'Word under cursor' },
      { '<leader>fb', '<Cmd>Telescope buffers<CR>', desc = 'Buffers' },
      { '<leader>fr', '<Cmd>Telescope oldfiles<CR>', desc = 'Recent files' },
      { '<leader>fh', '<Cmd>Telescope help_tags<CR>', desc = 'Help' },
      { '<leader>fk', '<Cmd>Telescope keymaps<CR>', desc = 'Keymaps' },
      { '<leader>fd', '<Cmd>Telescope diagnostics<CR>', desc = 'Diagnostics' },
      { '<leader>fs', '<Cmd>Telescope lsp_document_symbols<CR>', desc = 'Document symbols' },
      { '<leader>fe', '<Cmd>Telescope file_browser path=%:p:h select_buffer=true<CR>', desc = 'File browser' },
      { '<leader>f.', '<Cmd>Telescope resume<CR>', desc = 'Resume last picker' },
      { '<leader>/', '<Cmd>Telescope current_buffer_fuzzy_find<CR>', desc = 'Search in buffer' },
      { '<leader><leader>', '<Cmd>Telescope buffers<CR>', desc = 'Buffers' },
    },
    config = function()
      local telescope = require('telescope')
      telescope.setup({
        defaults = {
          path_display = { 'filename_first' },
          mappings = {
            i = { ['<C-u>'] = false, ['<C-d>'] = false },
          },
        },
        pickers = {
          find_files = { hidden = true, file_ignore_patterns = { '^%.git/' } },
        },
        extensions = {
          file_browser = { hijack_netrw = true },
        },
      })
      telescope.load_extension('fzf')
      telescope.load_extension('file_browser')
    end,
  },

  -- Python REPL. hkupty/iron.nvim moved to the Vigemus org.
  {
    'Vigemus/iron.nvim',
    cmd = { 'IronRepl', 'IronRestart', 'IronFocus', 'IronHide' },
    keys = {
      { '<leader>rs', '<Cmd>IronRepl<CR>', desc = 'Start REPL' },
      { '<leader>rR', '<Cmd>IronRestart<CR>', desc = 'Restart REPL' },
      { '<leader>rF', '<Cmd>IronFocus<CR>', desc = 'Focus REPL' },
      { '<leader>rh', '<Cmd>IronHide<CR>', desc = 'Hide REPL' },
      { '<leader>rc', mode = { 'n', 'v' }, desc = 'Send to REPL' },
      { '<leader>rl', desc = 'Send line' },
      { '<leader>rf', desc = 'Send file' },
    },
    config = function()
      local iron = require('iron.core')
      iron.setup({
        config = {
          scratch_repl = true,
          repl_definition = {
            python = {
              command = function()
                return vim.fn.executable('ipython') == 1 and { 'ipython', '--no-autoindent' } or { 'python' }
              end,
              format = require('iron.fts.common').bracketed_paste_python,
            },
          },
          repl_open_cmd = require('iron.view').split.vertical.botright(0.4),
        },
        keymaps = {
          send_motion = '<leader>rc',
          visual_send = '<leader>rc',
          send_line = '<leader>rl',
          send_file = '<leader>rf',
          send_until_cursor = '<leader>ru',
          cr = '<leader>r<CR>',
          interrupt = '<leader>r<C-c>',
          exit = '<leader>rq',
          clear = '<leader>rx',
        },
        highlight = { italic = true },
        ignore_blank_lines = true,
      })
    end,
  },
}
