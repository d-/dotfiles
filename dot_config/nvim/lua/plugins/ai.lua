-- Inline Copilot suggestions live in completion.lua (Tab accepts them).
return {
  -- Claude Code running inside Neovim, with selection sharing and diff review.
  {
    'coder/claudecode.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
    cmd = { 'ClaudeCode', 'ClaudeCodeFocus', 'ClaudeCodeAdd', 'ClaudeCodeSend' },
    keys = {
      { '<leader>ac', '<Cmd>ClaudeCode<CR>', desc = 'Toggle Claude Code' },
      { '<leader>af', '<Cmd>ClaudeCodeFocus<CR>', desc = 'Focus Claude Code' },
      { '<leader>ar', '<Cmd>ClaudeCode --resume<CR>', desc = 'Claude: resume session' },
      { '<leader>aC', '<Cmd>ClaudeCode --continue<CR>', desc = 'Claude: continue' },
      { '<leader>ab', '<Cmd>ClaudeCodeAdd %<CR>', desc = 'Claude: add current buffer' },
      { '<leader>as', '<Cmd>ClaudeCodeSend<CR>', mode = 'v', desc = 'Claude: send selection' },
      { '<leader>aa', '<Cmd>ClaudeCodeDiffAccept<CR>', desc = 'Claude: accept diff' },
      { '<leader>ad', '<Cmd>ClaudeCodeDiffDeny<CR>', desc = 'Claude: deny diff' },
    },
    opts = {
      terminal = { provider = 'native', split_side = 'right', split_width_percentage = 0.4 },
    },
  },

  -- Copilot Chat: explain / review / fix / tests on the current selection.
  {
    'CopilotC-Nvim/CopilotChat.nvim',
    dependencies = { 'github/copilot.vim', 'nvim-lua/plenary.nvim' },
    cmd = { 'CopilotChat', 'CopilotChatToggle', 'CopilotChatExplain', 'CopilotChatReview', 'CopilotChatFix', 'CopilotChatOptimize', 'CopilotChatTests', 'CopilotChatDocs' },
    keys = {
      { '<leader>ap', '<Cmd>CopilotChatToggle<CR>', mode = { 'n', 'v' }, desc = 'Toggle Copilot Chat' },
      { '<leader>ae', '<Cmd>CopilotChatExplain<CR>', mode = { 'n', 'v' }, desc = 'Copilot: explain' },
      { '<leader>aR', '<Cmd>CopilotChatReview<CR>', mode = { 'n', 'v' }, desc = 'Copilot: review' },
      { '<leader>ax', '<Cmd>CopilotChatFix<CR>', mode = { 'n', 'v' }, desc = 'Copilot: fix' },
      { '<leader>ao', '<Cmd>CopilotChatOptimize<CR>', mode = { 'n', 'v' }, desc = 'Copilot: optimize' },
      { '<leader>at', '<Cmd>CopilotChatTests<CR>', mode = { 'n', 'v' }, desc = 'Copilot: tests' },
      { '<leader>aD', '<Cmd>CopilotChatDocs<CR>', mode = { 'n', 'v' }, desc = 'Copilot: docs' },
    },
    opts = { window = { layout = 'vertical', width = 0.4 } },
  },
}
