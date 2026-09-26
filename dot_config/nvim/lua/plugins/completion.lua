return {
  {
    'github/copilot.vim',
    event = 'InsertEnter',
    -- Also load on :Copilot (setup, status, ...). Without this stub the
    -- command does not exist before the first insert, and `:Copilot` then
    -- matches the CopilotChat* stubs as a prefix: E464 ambiguous command.
    cmd = 'Copilot',
    init = function()
      -- Tab is handled by blink.cmp below so the two don't fight.
      vim.g.copilot_no_tab_map = true
    end,
  },

  {
    'saghen/blink.cmp',
    version = '1.*',
    event = 'InsertEnter',
    dependencies = { 'rafamadriz/friendly-snippets', 'folke/lazydev.nvim' },
    opts = {
      keymap = {
        preset = 'enter',
        -- Tab: accept a Copilot suggestion if one is showing, else move through the
        -- completion menu, else jump in a snippet, else insert a tab.
        ['<Tab>'] = {
          function()
            if vim.g.loaded_copilot ~= 1 then return end
            local ok, suggestion = pcall(vim.fn['copilot#GetDisplayedSuggestion'])
            if not ok or not suggestion or suggestion.text == '' then return end
            vim.api.nvim_feedkeys(vim.fn['copilot#Accept'](''), 'n', false)
            return true
          end,
          'select_next', 'snippet_forward', 'fallback',
        },
        ['<S-Tab>'] = { 'select_prev', 'snippet_backward', 'fallback' },
        ['<C-d>'] = { 'scroll_documentation_up', 'fallback' },
        ['<C-f>'] = { 'scroll_documentation_down', 'fallback' },
      },
      completion = {
        list = { selection = { preselect = true, auto_insert = false } },
        documentation = { auto_show = true, auto_show_delay_ms = 200 },
        menu = {
          draw = {
            treesitter = { 'lsp' },
            -- Kind as a word, not a Nerd Font glyph (none installed).
            columns = { { 'label', 'label_description', gap = 1 }, { 'kind' } },
          },
        },
      },
      signature = { enabled = true },
      sources = {
        default = { 'lsp', 'path', 'snippets', 'buffer', 'lazydev' },
        providers = {
          lazydev = { name = 'LazyDev', module = 'lazydev.integrations.blink', score_offset = 100 },
        },
      },
      fuzzy = { implementation = 'prefer_rust_with_warning' },
    },
    opts_extend = { 'sources.default' },
  },
}
