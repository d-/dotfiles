-- Leader must be set before lazy.nvim loads any plugin.
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Remote-plugin providers are unused; disabling them speeds startup and
-- silences :checkhealth noise.
vim.g.loaded_python3_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_node_provider = 0

require('config.options')
require('config.keymaps')
require('config.autocmds')

-- Colourscheme lives in colors/duogreen.lua (lua/duogreen.lua holds the
-- palette), so it needs no plugin and loads before any of them.
vim.cmd.colorscheme('duogreen')

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.uv.fs_stat(lazypath) then
  local out = vim.fn.system({
    'git', 'clone', '--filter=blob:none', '--branch=stable',
    'https://github.com/folke/lazy.nvim.git', lazypath,
  })
  if vim.v.shell_error ~= 0 then
    error('Failed to clone lazy.nvim:\n' .. out)
  end
end
vim.opt.rtp:prepend(lazypath)

require('lazy').setup({
  spec = { { import = 'plugins' } },
  install = { colorscheme = { 'duogreen' } },
  checker = { enabled = false },
  change_detection = { notify = false },
  rocks = { enabled = false },
  -- No Nerd Font: plain-Unicode icons for the :Lazy window.
  ui = {
    icons = {
      cmd = '⌘', config = '🛠', event = '📅', ft = '📂', init = '⚙', keys = '🗝',
      plugin = '🔌', runtime = '💻', require = '🌙', source = '📄', start = '🚀',
      task = '📌', lazy = '💤 ',
    },
  },
})
