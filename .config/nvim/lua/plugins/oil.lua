return {
  'stevearc/oil.nvim',
  lazy = false,
  keys = {
    { '<leader>o', '<cmd>Oil --float<cr>', desc = 'Open Oil in floating window' },
  },
  ---@module 'oil'
  ---@type oil.SetupOpts
  opts = {
    default_file_explorer = true,
    delete_to_trash = true,
    columns = {
      'icon',
      'permissions',
      'size',
      'mtime',
    },
    view_options = {
      show_hidden = true,
    },
  },
  dependencies = { { 'echasnovski/mini.icons', opts = {} } },
}
