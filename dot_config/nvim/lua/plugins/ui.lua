return {
  -- Colourscheme: cyberdream (high-contrast, vibrant) on a true black palette.
  -- The palette overrides feed every highlight group, so floats, pickers and
  -- the statusline all sit on black instead of cyberdream's default #16181a.
  {
    'scottmckendry/cyberdream.nvim',
    lazy = false,
    priority = 1000,
    opts = {
      variant = 'default',
      italic_comments = true,
      borderless_pickers = true,
      terminal_colors = true,
      colors = {
        bg = '#000000',
        bg_alt = '#0a0a0a',
        bg_highlight = '#262626',
      },
      overrides = function(c)
        return {
          CursorLine = { bg = '#101010' },
          CursorLineNr = { fg = c.cyan, bold = true },
          LineNr = { fg = '#4a5060' },
          Visual = { bg = '#2b3040' },
          WinSeparator = { fg = '#2a2a2a' },
          FloatBorder = { fg = '#3a3f4a', bg = '#0a0a0a' },
          NormalFloat = { bg = '#0a0a0a' },
          Pmenu = { bg = '#0a0a0a' },
          PmenuSel = { bg = '#262626', fg = c.fg, bold = true },
          MatchParen = { fg = c.yellow, bg = '#262626', bold = true },
          -- Whitespace markers (listchars) should whisper, not shout.
          Whitespace = { fg = '#2a2a2a' },
          NonText = { fg = '#2a2a2a' },
          -- Diagnostic underlines pop against black without extra noise.
          DiagnosticUnderlineError = { sp = c.red, undercurl = true },
          DiagnosticUnderlineWarn = { sp = c.orange, undercurl = true },
          -- Indent guides: faint lines, brighter current scope.
          IblIndent = { fg = '#1e1e1e' },
          IblScope = { fg = '#3a3f4a' },
        }
      end,
    },
    config = function(_, opts)
      require('cyberdream').setup(opts)
      vim.cmd.colorscheme('cyberdream')
    end,
  },

  -- Statusline. No Nerd Font in the terminal, so text and plain Unicode only.
  {
    'nvim-lualine/lualine.nvim',
    event = 'VeryLazy',
    config = function()
      -- cyberdream ships a lualine theme built from its stock palette; repaint
      -- it onto the black background used above.
      local theme = require('lualine.themes.cyberdream')
      for _, mode in pairs(theme) do
        for _, section in pairs(mode) do
          if type(section) == 'table' then section.bg = '#000000' end
        end
      end
      for _, section in pairs(theme.inactive or {}) do
        if type(section) == 'table' then section.fg = '#4a5060' end
      end

      local function lsp_clients()
        local names = {}
        for _, c in ipairs(vim.lsp.get_clients({ bufnr = 0 })) do
          if c.name ~= 'copilot' then names[#names + 1] = c.name end
        end
        return table.concat(names, ' ')
      end

      require('lualine').setup({
        options = {
          theme = theme,
          icons_enabled = false,
          globalstatus = true,
          component_separators = { left = '│', right = '│' },
          section_separators = { left = '', right = '' },
          disabled_filetypes = { statusline = { 'lazy', 'mason' } },
        },
        sections = {
          lualine_a = { { 'mode', fmt = function(m) return m:sub(1, 3) end } },
          lualine_b = { 'branch', { 'diff', symbols = { added = '+', modified = '~', removed = '-' } } },
          lualine_c = {
            { 'filename', path = 1, symbols = { modified = ' ●', readonly = ' ⊘', unnamed = '[no name]' } },
            { 'diagnostics', symbols = { error = 'E', warn = 'W', info = 'I', hint = 'H' } },
          },
          lualine_x = { lsp_clients, 'filetype' },
          lualine_y = { 'progress' },
          lualine_z = { 'location' },
        },
        inactive_sections = {
          lualine_c = { { 'filename', path = 1 } },
          lualine_x = { 'location' },
        },
      })
    end,
  },

  {
    'folke/which-key.nvim',
    event = 'VeryLazy',
    opts = {
      delay = 300,
      -- No Nerd Font in the terminal: drop mapping icons and use plain
      -- Unicode for the special-key labels (the defaults are Nerd glyphs).
      icons = {
        mappings = false,
        breadcrumb = '»',
        separator = '→',
        group = '+',
        keys = {
          Up = '↑ ', Down = '↓ ', Left = '← ', Right = '→ ',
          C = 'C-', M = 'M-', D = 'Cmd-', S = 'S-',
          CR = '↵ ', Esc = 'Esc ', ScrollWheelDown = '⇣ ', ScrollWheelUp = '⇡ ',
          NL = '↵ ', BS = '⌫ ', Space = '␣ ', Tab = '⇥ ',
          F1 = 'F1', F2 = 'F2', F3 = 'F3', F4 = 'F4', F5 = 'F5', F6 = 'F6',
          F7 = 'F7', F8 = 'F8', F9 = 'F9', F10 = 'F10', F11 = 'F11', F12 = 'F12',
        },
      },
      spec = {
        { '<leader>a', group = 'ai' },
        { '<leader>b', group = 'build' },
        { '<leader>c', group = 'code' },
        { '<leader>d', group = 'debug' },
        { '<leader>f', group = 'find' },
        { '<leader>g', group = 'git' },
        { '<leader>h', group = 'hop' },
        { '<leader>r', group = 'repl' },
        { '<leader>w', group = 'workspace' },
      },
    },
  },

  {
    'lukas-reineke/indent-blankline.nvim',
    main = 'ibl',
    event = { 'BufReadPost', 'BufNewFile' },
    opts = {
      indent = { char = '│' },
      scope = { enabled = true, show_start = true },
      exclude = { filetypes = { 'help', 'lazy', 'mason', 'TelescopePrompt' } },
    },
  },

  { 'j-hui/fidget.nvim', event = 'LspAttach', opts = {} },

  {
    'lewis6991/gitsigns.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    opts = {
      on_attach = function(bufnr)
        local gs = require('gitsigns')
        local function map(mode, lhs, rhs, desc)
          vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
        end
        map('n', ']c', function() gs.nav_hunk('next') end, 'Next hunk')
        map('n', '[c', function() gs.nav_hunk('prev') end, 'Previous hunk')
        map('n', '<leader>gs', gs.stage_hunk, 'Stage hunk')
        map('n', '<leader>gr', gs.reset_hunk, 'Reset hunk')
        map('v', '<leader>gs', function() gs.stage_hunk({ vim.fn.line('.'), vim.fn.line('v') }) end, 'Stage hunk')
        map('v', '<leader>gr', function() gs.reset_hunk({ vim.fn.line('.'), vim.fn.line('v') }) end, 'Reset hunk')
        map('n', '<leader>gp', gs.preview_hunk, 'Preview hunk')
        map('n', '<leader>gb', function() gs.blame_line({ full = true }) end, 'Blame line')
        map('n', '<leader>gd', gs.diffthis, 'Diff against index')
      end,
    },
  },
}
