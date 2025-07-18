return {
  -- {
  --   'folke/tokyonight.nvim',
  --   priority = 1000, -- Make sure to load this before all the other start plugins.
  --   lazy = false,
  --   config = function()
  --     require('tokyonight').setup {
  --       style = 'night',
  --       styles = {
  --         comments = { italic = false }, -- Disable italics in comments
  --       },
  --     }
  --
  --     -- vim.cmd.colorscheme 'tokyonight-night'
  --   end,
  -- },
  {
    'ellisonleao/gruvbox.nvim',
    priority = 1000,
    lazy = false,
    config = function()
      require('gruvbox').setup {
        -- contrast = 'hard', -- can be "hard", "soft" or empty string
        italic = {
          comments = false,
        },
        transparent_mode = false,
      }

      vim.cmd.colorscheme 'gruvbox'
    end,
  },
}
