-- [[ Basic Autocommands ]]
--  See `:help lua-guide-autocommands`

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.hl.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
})

-- Set proper filetype for bash files
vim.api.nvim_create_autocmd({ 'BufRead', 'BufNewFile' }, {
  desc = 'Set bash filetype for shell scripts',
  group = vim.api.nvim_create_augroup('bash-filetype', { clear = true }),
  pattern = { '*.sh', '*.bash', '.bashrc', '.bash_profile', '.bash_aliases' },
  callback = function()
    vim.bo.filetype = 'bash'
  end,
})
