local map = vim.keymap.set

-- Space is the leader; stop it moving the cursor.
map({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

-- Move by screen line when no count is given (wrapped lines).
map('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
map('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- Save without leaving insert mode. <C-s> works everywhere; <M-s> needs
-- kitty's macos_option_as_alt.
map({ 'i', 'n' }, '<C-s>', '<Cmd>silent write<CR>', { desc = 'Save' })
map({ 'i', 'n' }, '<M-s>', '<Cmd>silent write<CR>', { desc = 'Save' })

-- z1..z9: show folds down to that depth.
for n = 1, 9 do
  map('n', 'z' .. n, function()
    vim.wo.foldlevel = n - 1
  end, { desc = 'Fold level ' .. (n - 1) })
end

-- Run the current file. C++ needs no -std flag: Homebrew clang++ reads
-- ~/.config/clang/clang++.cfg, which defaults to C++23. Spelled out in full
-- so it still works when nvim is launched without brew shellenv on PATH.
local runners = {
  python = 'python %',
  cpp = '/opt/homebrew/opt/llvm/bin/clang++ % -o /tmp/a && /tmp/a',
  c = '/opt/homebrew/opt/llvm/bin/clang % -o /tmp/a && /tmp/a',
}
map({ 'n', 'i' }, '<F5>', function()
  local cmd = runners[vim.bo.filetype]
  if not cmd then
    vim.notify('No runner for filetype ' .. vim.bo.filetype, vim.log.levels.WARN)
    return
  end
  vim.cmd('write')
  cmd = vim.fn.expandcmd(cmd) -- expand % while the source file is still current
  -- Run in a terminal split below so the output stays visible. Reuse the
  -- previous run's window if it is still open.
  if vim.g.run_win and vim.api.nvim_win_is_valid(vim.g.run_win) then
    vim.api.nvim_set_current_win(vim.g.run_win)
  else
    vim.cmd('botright 15split')
    vim.g.run_win = vim.api.nvim_get_current_win()
  end
  -- term = true turns the *current* buffer into the terminal, so give it a
  -- fresh empty one rather than the source file.
  vim.cmd('enew')
  vim.fn.jobstart(cmd, { term = true })
  vim.keymap.set('n', 'q', '<Cmd>close<CR>', { buffer = true, desc = 'Close run output' })
  vim.cmd('wincmd p')
end, { desc = 'Run current file' })

-- Windows
map('n', '<C-h>', '<C-w>h', { desc = 'Window left' })
map('n', '<C-j>', '<C-w>j', { desc = 'Window down' })
map('n', '<C-k>', '<C-w>k', { desc = 'Window up' })
map('n', '<C-l>', '<C-w>l', { desc = 'Window right' })

-- Keep the visual selection when indenting.
map('v', '<', '<gv')
map('v', '>', '>gv')

-- Diagnostics
map('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Line diagnostics' })
map('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Diagnostics to loclist' })
map('n', '[d', function() vim.diagnostic.jump({ count = -1, float = true }) end, { desc = 'Previous diagnostic' })
map('n', ']d', function() vim.diagnostic.jump({ count = 1, float = true }) end, { desc = 'Next diagnostic' })

map('n', '<leader>L', '<Cmd>Lazy<CR>', { desc = 'Lazy' })
map('n', '<leader>M', '<Cmd>Mason<CR>', { desc = 'Mason' })
