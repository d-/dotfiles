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

-- Run the current Python file.
map({ 'n', 'i' }, '<F5>', '<Cmd>write<CR><Cmd>!clear; python %<CR>', { desc = 'Run python file' })

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
