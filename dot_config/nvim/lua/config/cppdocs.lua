-- C++ reference lookups for the word under the cursor (or the visual selection):
--   cppman pages (cppreference rendered as man pages, cached offline),
--   a Telescope picker over cppman's whole cppreference index,
--   and browser jumps to cppreference or the ISO C++ working draft.
-- Attached per buffer from after/ftplugin/{c,cpp}.lua.
local M = {}

local function notify(msg, level)
  vim.notify(msg, level or vim.log.levels.INFO, { title = 'C++ docs' })
end

local function urlencode(s)
  return (s:gsub('[^%w%-_.~]', function(c) return string.format('%%%02X', c:byte()) end))
end

-- Qualified name under the cursor (std::ranges::views::filter, not just
-- "filter"), or the visual selection when called from visual mode.
local function term_under_cursor()
  local mode = vim.fn.mode()
  if mode == 'v' or mode == 'V' or mode == '\22' then
    local lines = vim.fn.getregion(vim.fn.getpos('v'), vim.fn.getpos('.'), { type = mode })
    vim.cmd('normal! \27')
    return vim.trim(table.concat(lines, ' '))
  end
  local line, col = vim.api.nvim_get_current_line(), vim.fn.col('.')
  local function ok(i) return line:sub(i, i):match('[%w_:]') ~= nil end
  if not ok(col) then return vim.fn.expand('<cword>') end
  local s, e = col, col
  while s > 1 and ok(s - 1) do s = s - 1 end
  while e < #line and ok(e + 1) do e = e + 1 end
  return (line:sub(s, e):gsub('^:+', ''):gsub(':+$', ''))
end

-- Run fn with the term under the cursor, or prompt for one when there is none.
local function with_term(prompt, fn)
  local term = term_under_cursor()
  if term ~= '' then return fn(term) end
  vim.ui.input({ prompt = prompt }, function(input)
    if input and input ~= '' then fn(input) end
  end)
end

-- Scratch window for rendered pages; reused across lookups.
local function show_page(title, lines)
  local win
  for _, w in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if vim.b[vim.api.nvim_win_get_buf(w)].cppman then win = w end
  end
  if win then
    vim.api.nvim_set_current_win(win)
  else
    vim.cmd('botright vsplit')
    vim.api.nvim_win_set_width(0, math.min(84, math.floor(vim.o.columns / 2)))
  end
  local buf = vim.api.nvim_create_buf(false, true)
  vim.b[buf].cppman = true
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.api.nvim_buf_set_name(buf, 'cppman://' .. title)
  vim.bo[buf].buftype, vim.bo[buf].bufhidden, vim.bo[buf].swapfile = 'nofile', 'wipe', false
  vim.bo[buf].modifiable, vim.bo[buf].readonly = false, true
  vim.bo[buf].filetype = 'man'
  vim.api.nvim_win_set_buf(0, buf)
  vim.wo.wrap, vim.wo.number, vim.wo.relativenumber, vim.wo.signcolumn = false, false, false, 'no'
  -- Follow references inside the page.
  vim.keymap.set('n', 'K', function() M.man(term_under_cursor()) end, { buffer = buf, desc = 'cppman: follow' })
  vim.keymap.set('n', '<CR>', function() M.man(term_under_cursor()) end, { buffer = buf, desc = 'cppman: follow' })
  vim.keymap.set('n', 'q', '<Cmd>close<CR>', { buffer = buf, desc = 'Close' })
end

--- Show the cppreference page for `term` via cppman.
function M.man(term)
  if vim.fn.executable('cppman') == 0 then
    return notify('cppman is not installed (brew install cppman)', vim.log.levels.WARN)
  end
  -- cppman pipes through $PAGER only when its own pager setting is "system";
  -- setting it is idempotent and cheap, so do it before every fetch.
  vim.system({ 'cppman', '--pager=system' }, {}, function()
    vim.system({ 'cppman', term }, { text = true, env = { PAGER = 'cat' } }, vim.schedule_wrap(function(res)
      local out = res.stdout or ''
      if res.code ~= 0 or not out:find('%S') then
        return notify(term .. ': no cppreference page. <leader>cM searches the index.', vim.log.levels.WARN)
      end
      -- Drop man's overstrike bold/underline (x^Hx, _^Hx), as `col -bx` would.
      out = out:gsub('.\8', '')
      show_page(term, vim.split(out, '\n', { plain = true }))
    end))
  end)
end

local index_cache
local function index_entries()
  if index_cache then return index_cache end
  local db = vim.fn.glob('/opt/homebrew/opt/cppman/libexec/lib/python*/site-packages/cppman/lib/index.db', true, true)[1]
  if not db then return nil, 'cppman index.db not found (brew install cppman)' end
  if vim.fn.executable('sqlite3') == 0 then return nil, 'sqlite3 not found' end
  local rows = vim.fn.systemlist({
    'sqlite3', '-separator', '\t', db,
    'SELECT k.keyword, t.title, t.url FROM "cppreference.com_keywords" k JOIN "cppreference.com" t ON t.id = k.id ORDER BY k.keyword',
  })
  index_cache = {}
  for _, row in ipairs(rows) do
    local kw, title, url = row:match('^(.-)\t(.-)\t(.*)$')
    if kw then index_cache[#index_cache + 1] = { kw = kw, title = title, url = url } end
  end
  return index_cache
end

--- Fuzzy-search the whole cppreference index; <CR> opens the cppman page,
--- <C-o> opens the page on cppreference.com instead.
function M.search(initial)
  local entries, err = index_entries()
  if not entries then return notify(err, vim.log.levels.WARN) end
  local pickers, finders = require('telescope.pickers'), require('telescope.finders')
  local conf = require('telescope.config').values
  local actions, state = require('telescope.actions'), require('telescope.actions.state')
  pickers.new({}, {
    prompt_title = 'cppreference',
    default_text = initial,
    finder = finders.new_table({
      results = entries,
      entry_maker = function(e)
        return { value = e, display = string.format('%-44s %s', e.kw, e.title), ordinal = e.kw .. ' ' .. e.title }
      end,
    }),
    sorter = conf.generic_sorter({}),
    attach_mappings = function(bufnr, map)
      actions.select_default:replace(function()
        local e = state.get_selected_entry()
        actions.close(bufnr)
        if e then M.man(e.value.kw) end
      end)
      map({ 'i', 'n' }, '<C-o>', function()
        local e = state.get_selected_entry()
        actions.close(bufnr)
        if e then vim.ui.open(e.value.url) end
      end)
      return true
    end,
  }):find()
end

--- cppreference.com in the browser (first search hit).
function M.cppreference(term)
  vim.ui.open('https://duckduckgo.com/?q=' .. urlencode('\\ site:en.cppreference.com ' .. term))
end

--- The ISO C++ working draft (eel.is/c++draft) in the browser (first search hit).
function M.standard(term)
  vim.ui.open('https://duckduckgo.com/?q=' .. urlencode('\\ site:eel.is/c++draft ' .. term))
end

function M.attach(buf)
  local function map(lhs, rhs, desc, modes)
    vim.keymap.set(modes or { 'n', 'x' }, lhs, rhs, { buffer = buf, desc = desc })
  end
  map('<leader>cm', function() with_term('cppman: ', M.man) end, 'cppreference page (cppman)')
  map('<leader>cM', function() M.search(vim.fn.expand('<cword>')) end, 'Search cppreference index', 'n')
  map('<leader>cr', function() with_term('cppreference: ', M.cppreference) end, 'cppreference.com in browser')
  map('<leader>cS', function() with_term('C++ draft: ', M.standard) end, 'ISO C++ draft in browser')
end

return M
