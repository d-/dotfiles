-- A few cyberdream accents layered over the colourscheme, used only where a
-- colour tells elements apart: headings and parameters in man pages, the
-- matched part of a picker entry, the selection caret, which-key groups.
-- Applied now and again on every :colorscheme.
local M = {}

M.colors = {
  blue = '#5ea1ff',   -- structure: headings, prompts, groups
  cyan = '#5ef1ff',   -- parameters / emphasis inside pages
  orange = '#ffbd5e', -- what you typed (matches), version tags
}

-- Set attrs on a group, keeping whatever else the colourscheme gave it.
local function tint(name, attrs)
  local cur = vim.api.nvim_get_hl(0, { name = name, link = false })
  vim.api.nvim_set_hl(0, name, vim.tbl_extend('force', cur, attrs))
end

function M.apply()
  local c = M.colors
  -- man / cppman pages
  tint('manSectionHeading', { fg = c.blue, bold = true })
  tint('manBold', { bold = true })
  tint('manUnderline', { fg = c.cyan, underline = false })
  vim.api.nvim_set_hl(0, 'CppmanVersion', { fg = c.orange })
  -- pickers and completion: the matched text, the caret, the prompt
  tint('TelescopeMatching', { fg = c.orange, bold = true })
  tint('TelescopeSelectionCaret', { fg = c.blue })
  tint('TelescopePromptPrefix', { fg = c.blue })
  tint('BlinkCmpLabelMatch', { fg = c.orange, bold = true })
  -- which-key: groups stand apart from commands
  tint('WhichKeyGroup', { fg = c.blue })
end

vim.api.nvim_create_autocmd('ColorScheme', {
  group = vim.api.nvim_create_augroup('user_accents', { clear = true }),
  callback = M.apply,
})
M.apply()

return M
