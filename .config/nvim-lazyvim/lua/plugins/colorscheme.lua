return {
  -- add gruvbox
  { "ellisonleao/gruvbox.nvim", config = { contrast = "hard" } },

  -- Configure LazyVim to load gruvbox
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "gruvbox",
    },
  }
}
