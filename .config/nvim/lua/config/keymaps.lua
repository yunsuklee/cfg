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
    vim.diagnostic.config { virtual_text = false }
    print 'Diagnostic virtual text disabled'
  else
    vim.diagnostic.config {
      virtual_text = {
        source = 'if_many',
        spacing = 2,
      },
    }
    print 'Diagnostic virtual text enabled'
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

-- Make Escape also close floating windows in addition to clearing search
vim.keymap.set('n', '<Esc>', function()
  close_floating_windows()
  vim.cmd 'nohlsearch'
end, { desc = 'Clear search and close floating windows' })

-- Better indenting - keeps selection after indenting
vim.keymap.set('v', '<', '<gv', { desc = 'Indent left and keep selection' })
vim.keymap.set('v', '>', '>gv', { desc = 'Indent right and keep selection' })

-- Paste without overwriting yank register
vim.keymap.set('v', 'p', '"_dP', { desc = 'Paste without overwriting register' })

-- Prevent c and d from copying to clipboard (use black hole register)
vim.keymap.set('n', 'c', '"_c', { desc = 'Change without copying to clipboard' })
vim.keymap.set('n', 'C', '"_C', { desc = 'Change to end of line without copying' })
vim.keymap.set('n', 'd', '"_d', { desc = 'Delete without copying to clipboard' })
vim.keymap.set('n', 'D', '"_D', { desc = 'Delete to end of line without copying' })
vim.keymap.set('v', 'c', '"_c', { desc = 'Change without copying to clipboard' })
vim.keymap.set('v', 'd', '"_d', { desc = 'Delete without copying to clipboard' })
vim.keymap.set('n', 'dd', '"_dd', { desc = 'Delete line without copying to clipboard' })
vim.keymap.set('n', 'x', '"_x', { desc = 'Delete character without copying to clipboard' })

-- Cut to clipboard with capital X
vim.keymap.set('v', 'X', 'd', { desc = 'Cut selection to clipboard' })
vim.keymap.set('n', 'X', 'dd', { desc = 'Cut line to clipboard' })

-- Terminal mode keymaps
vim.keymap.set('t', '<C-n>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })
vim.keymap.set('t', '<C-h>', '<C-\\><C-n><C-w>h', { desc = 'Move to left window from terminal' })
vim.keymap.set('t', '<C-j>', '<C-\\><C-n><C-w>j', { desc = 'Move to lower window from terminal' })
vim.keymap.set('t', '<C-k>', '<C-\\><C-n><C-w>k', { desc = 'Move to upper window from terminal' })
vim.keymap.set('t', '<C-l>', '<C-\\><C-n><C-w>l', { desc = 'Move to right window from terminal' })
