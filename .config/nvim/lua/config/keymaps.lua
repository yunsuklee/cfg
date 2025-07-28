-- [[ Basic Keymaps ]]
--  See `:help vim.keymap.set()`

-- Clear highlights on search when pressing <Esc> in normal mode
--  See `:help hlsearch`
-- vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>') -- Commented out due to duplicate mapping below

-- Diagnostic keymaps
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

-- Toggle diagnostic virtual text
vim.keymap.set('n', '<leader>td', function()
  local current_config = vim.diagnostic.config()
  if current_config.virtual_text then
    vim.diagnostic.config({ virtual_text = false })
    print('Diagnostic virtual text disabled')
  else
    vim.diagnostic.config({ 
      virtual_text = {
        source = 'if_many',
        spacing = 2,
      }
    })
    print('Diagnostic virtual text enabled')
  end
end, { desc = '[T]oggle [D]iagnostic virtual text' })

-- Keybinds to make split navigation easier.
--  Use CTRL+<hjkl> to switch between windows
--
--  See `:help wincmd` for a list of all window commands
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- NOTE: Some terminals have colliding keymaps or are not able to send distinct keycodes
-- vim.keymap.set("n", "<C-S-h>", "<C-w>H", { desc = "Move window to the left" })
-- vim.keymap.set("n", "<C-S-l>", "<C-w>L", { desc = "Move window to the right" })
-- vim.keymap.set("n", "<C-S-j>", "<C-w>J", { desc = "Move window to the lower" })
-- vim.keymap.set("n", "<C-S-k>", "<C-w>K", { desc = "Move window to the upper" })

-- Resize splits with arrow keys
vim.keymap.set('n', '<C-Up>', '<C-w>+', { desc = 'Increase window height' })
vim.keymap.set('n', '<C-Down>', '<C-w>-', { desc = 'Decrease window height' })
vim.keymap.set('n', '<C-Left>', '<C-w><', { desc = 'Decrease window width' })
vim.keymap.set('n', '<C-Right>', '<C-w>>', { desc = 'Increase window width' })

-- Close floating windows (like LSP hover)
local function close_floating_windows()
  for _, win in pairs(vim.api.nvim_list_wins()) do
    local config = vim.api.nvim_win_get_config(win)
    if config.relative ~= '' then
      vim.api.nvim_win_close(win, false)
    end
  end
end

vim.keymap.set('n', 'q', function()
  close_floating_windows()
end, { desc = 'Close floating windows' })

-- Make Escape also close floating windows in addition to clearing search
vim.keymap.set('n', '<Esc>', function()
  close_floating_windows()
  vim.cmd 'nohlsearch'
end, { desc = 'Clear search and close floating windows' })
