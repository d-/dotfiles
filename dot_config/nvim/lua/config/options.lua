local o = vim.o

-- Line numbers
o.number = true
o.relativenumber = true
o.numberwidth = 2
o.signcolumn = 'yes'

-- Indentation (vim-sleuth overrides these per-file when it can detect them)
o.expandtab = true
o.shiftwidth = 4
o.tabstop = 4
o.breakindent = true

-- Folding: treesitter-based, everything open by default. z1..z9 set the depth.
o.foldmethod = 'expr'
o.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
o.foldlevel = 99
o.foldtext = ''

-- Search
o.hlsearch = false
o.ignorecase = true
o.smartcase = true
o.inccommand = 'split'

-- UI
o.termguicolors = true
o.background = 'dark'
o.mouse = 'a'
o.cursorline = true
o.scrolloff = 6
o.splitright = true
o.splitbelow = true
o.showmode = false
o.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }
vim.opt.fillchars = { eob = ' ' }
o.winborder = 'rounded'

-- Behaviour
o.clipboard = 'unnamedplus'
o.undofile = true
o.confirm = true
o.updatetime = 250
o.timeoutlen = 300
o.completeopt = 'menuone,noselect'
