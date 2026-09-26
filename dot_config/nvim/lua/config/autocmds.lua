local augroup = function(name)
  return vim.api.nvim_create_augroup('user_' .. name, { clear = true })
end

vim.api.nvim_create_autocmd('TextYankPost', {
  group = augroup('yank_highlight'),
  callback = function()
    vim.hl.on_yank()
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

-- Terminal buffers: no editor chrome (line numbers, sign gutter, cursorline,
-- listchars) inherited from the window they were split from.
vim.api.nvim_create_autocmd('TermOpen', {
  group = augroup('terminal_ui'),
  callback = function()
    vim.wo.number = false
    vim.wo.relativenumber = false
    vim.wo.signcolumn = 'no'
    vim.wo.cursorline = false
    vim.wo.list = false
    vim.wo.scrolloff = 0
  end,
})

vim.diagnostic.config({
  severity_sort = true,
  virtual_text = { spacing = 2, source = 'if_many' },
  float = { source = 'if_many' },
})
