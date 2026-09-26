local augroup = function(name)
  return vim.api.nvim_create_augroup('user_' .. name, { clear = true })
end

vim.api.nvim_create_autocmd('TextYankPost', {
  group = augroup('yank_highlight'),
  callback = function()
    vim.hl.on_yank()
  end,
})

-- Transparent background, reapplied whenever the colorscheme changes.
vim.api.nvim_create_autocmd('ColorScheme', {
  group = augroup('transparent_bg'),
  callback = function()
    for _, group in ipairs({ 'Normal', 'NormalNC', 'NormalFloat', 'SignColumn', 'FoldColumn' }) do
      vim.api.nvim_set_hl(0, group, { bg = 'none' })
    end
    vim.api.nvim_set_hl(0, 'LineNr', { bg = 'none', fg = '#666666' })
  end,
})

-- Reopen files at the last cursor position.
vim.api.nvim_create_autocmd('BufReadPost', {
  group = augroup('last_position'),
  callback = function(ev)
    local mark = vim.api.nvim_buf_get_mark(ev.buf, '"')
    local lines = vim.api.nvim_buf_line_count(ev.buf)
    if mark[1] > 0 and mark[1] <= lines then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- Close transient windows with q.
vim.api.nvim_create_autocmd('FileType', {
  group = augroup('close_with_q'),
  pattern = { 'help', 'man', 'qf', 'checkhealth', 'lspinfo', 'git', 'fugitive', 'fugitiveblame' },
  callback = function(ev)
    vim.bo[ev.buf].buflisted = false
    vim.keymap.set('n', 'q', '<Cmd>close<CR>', { buffer = ev.buf, silent = true })
  end,
})

vim.diagnostic.config({
  severity_sort = true,
  virtual_text = { spacing = 2, source = 'if_many' },
  float = { source = 'if_many' },
})
