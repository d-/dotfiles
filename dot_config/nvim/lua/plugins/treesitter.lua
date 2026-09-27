-- nvim-treesitter `main` branch (the `master` branch is frozen). Needs the
-- tree-sitter CLI and a C compiler to build parsers.
return {
  {
    'nvim-treesitter/nvim-treesitter',
    branch = 'main',
    lazy = false,
    build = ':TSUpdate',
    config = function()
      local languages = {
        'bash', 'c', 'cmake', 'cpp', 'css', 'diff', 'doxygen', 'fish', 'git_config', 'git_rebase', 'gitcommit',
        'gitignore', 'html', 'javascript', 'json', 'lua', 'luadoc', 'make', 'markdown',
        'markdown_inline', 'python', 'query', 'regex', 'rust', 'toml', 'tsx',
        'typescript', 'vim', 'vimdoc', 'yaml',
      }
      require('nvim-treesitter').install(languages)

      vim.api.nvim_create_autocmd('FileType', {
        group = vim.api.nvim_create_augroup('user_treesitter', { clear = true }),
        callback = function(ev)
          local lang = vim.treesitter.language.get_lang(ev.match)
          if not lang or not pcall(vim.treesitter.start, ev.buf, lang) then
            return
          end
          vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end,
      })
    end,
  },

  -- Text objects and motions over the syntax tree: functions, classes,
  -- parameters, conditionals, loops. The `main` branch ships no keymaps.
  {
    'nvim-treesitter/nvim-treesitter-textobjects',
    branch = 'main',
    event = { 'BufReadPost', 'BufNewFile' },
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    config = function()
      require('nvim-treesitter-textobjects').setup({
        select = { lookahead = true },
        move = { set_jumps = true },
      })
      local select = require('nvim-treesitter-textobjects.select').select_textobject
      local move = require('nvim-treesitter-textobjects.move')
      local swap = require('nvim-treesitter-textobjects.swap')

      local objects = {
        f = { '@function', 'function' },
        c = { '@class', 'class' },
        a = { '@parameter', 'parameter' },
        i = { '@conditional', 'conditional' },
        l = { '@loop', 'loop' },
        ['/'] = { '@comment', 'comment' },
      }
      for key, obj in pairs(objects) do
        local capture, name = obj[1], obj[2]
        vim.keymap.set({ 'x', 'o' }, 'a' .. key, function() select(capture .. '.outer', 'textobjects') end, { desc = 'around ' .. name })
        vim.keymap.set({ 'x', 'o' }, 'i' .. key, function() select(capture .. '.inner', 'textobjects') end, { desc = 'inside ' .. name })
      end

      -- ]f / [f: next / previous function start, ]F / [F: end. ]a / [a: next /
      -- previous parameter. ]C / [C: class (gitsigns owns ]c / [c for hunks).
      vim.keymap.set({ 'n', 'x', 'o' }, ']f', function() move.goto_next_start('@function.outer', 'textobjects') end, { desc = 'Next function' })
      vim.keymap.set({ 'n', 'x', 'o' }, '[f', function() move.goto_previous_start('@function.outer', 'textobjects') end, { desc = 'Previous function' })
      vim.keymap.set({ 'n', 'x', 'o' }, ']F', function() move.goto_next_end('@function.outer', 'textobjects') end, { desc = 'Next function end' })
      vim.keymap.set({ 'n', 'x', 'o' }, '[F', function() move.goto_previous_end('@function.outer', 'textobjects') end, { desc = 'Previous function end' })
      vim.keymap.set({ 'n', 'x', 'o' }, ']a', function() move.goto_next_start('@parameter.inner', 'textobjects') end, { desc = 'Next parameter' })
      vim.keymap.set({ 'n', 'x', 'o' }, '[a', function() move.goto_previous_start('@parameter.inner', 'textobjects') end, { desc = 'Previous parameter' })
      vim.keymap.set({ 'n', 'x', 'o' }, ']C', function() move.goto_next_start('@class.outer', 'textobjects') end, { desc = 'Next class' })
      vim.keymap.set({ 'n', 'x', 'o' }, '[C', function() move.goto_previous_start('@class.outer', 'textobjects') end, { desc = 'Previous class' })

      -- Swap the argument under the cursor with its neighbour.
      vim.keymap.set('n', '<leader>cn', function() swap.swap_next('@parameter.inner') end, { desc = 'Swap parameter forward' })
      vim.keymap.set('n', '<leader>cp', function() swap.swap_previous('@parameter.inner') end, { desc = 'Swap parameter backward' })
    end,
  },

  -- Pin the enclosing function/class/namespace header to the top of the window.
  {
    'nvim-treesitter/nvim-treesitter-context',
    event = { 'BufReadPost', 'BufNewFile' },
    opts = { max_lines = 4, multiline_threshold = 1, trim_scope = 'outer' },
    keys = {
      { '<leader>cc', function() require('treesitter-context').go_to_context(vim.v.count1) end, desc = 'Go to context' },
    },
  },
}
