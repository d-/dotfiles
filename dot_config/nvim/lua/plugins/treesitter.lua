-- nvim-treesitter `main` branch (the `master` branch is frozen). Needs the
-- tree-sitter CLI and a C compiler to build parsers.
return {
  'nvim-treesitter/nvim-treesitter',
  branch = 'main',
  lazy = false,
  build = ':TSUpdate',
  config = function()
    local languages = {
      'bash', 'c', 'cmake', 'cpp', 'css', 'diff', 'doxygen', 'fish', 'git_config', 'git_rebase', 'gitcommit',
      'gitignore', 'html', 'javascript', 'json', 'lua', 'luadoc', 'make', 'markdown',
      'markdown_inline', 'python', 'query', 'regex', 'rust', 'toml', 'tsx',
      'typescript', 'vim', 'vimdoc', 'yaml',
    }
    require('nvim-treesitter').install(languages)

    vim.api.nvim_create_autocmd('FileType', {
      group = vim.api.nvim_create_augroup('user_treesitter', { clear = true }),
      callback = function(ev)
        local lang = vim.treesitter.language.get_lang(ev.match)
        if not lang or not pcall(vim.treesitter.start, ev.buf, lang) then
          return
        end
        vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
      end,
    })
  end,
}
