return {
  {
    -- If you want to see what colorschemes are already installed, you can use `:Telescope colorscheme`.
    'folke/tokyonight.nvim',
    priority = 1000, -- Make sure to load this before all the other start plugins.
    lazy = false,
    config = function()
      require('tokyonight').setup {
        style = 'night',
        styles = {
          comments = { italic = false }, -- Disable italics in comments
        },
      }

      -- vim.cmd.colorscheme 'tokyonight-night'
    end,
  },
  {
    'ellisonleao/gruvbox.nvim',
    priority = 1000,
    lazy = false,
    config = function()
      require('gruvbox').setup {
        contrast = 'hard', -- can be "hard", "soft" or empty string
        italic = {
          comments = false, -- matches your preference
        },
        transparent_mode = false,
      }

      vim.cmd.colorscheme 'gruvbox'
    end,
  },
}
