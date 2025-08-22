-- [[ Setting options ]]
-- See `:help vim.o`
-- NOTE: You can change these options as you wish!
--  For more options, you can see `:help option-list`

-- Make line numbers default
vim.o.number = true
-- You can also add relative line numbers, to help with jumping.
--  Experiment for yourself to see if you like it!
vim.o.relativenumber = true

-- Enable mouse mode, can be useful for resizing splits for example!
vim.o.mouse = 'a'

-- Don't show the mode, since it's already in the status line
vim.o.showmode = false

-- Sync clipboard between OS and Neovim
vim.schedule(function()
  vim.o.clipboard = 'unnamedplus'
end)

local function setup_clipboard()
  local is_tmux = vim.env.TMUX ~= nil
  local is_wsl = vim.fn.has('wsl') == 1
  local is_windows = vim.fn.has('win32') == 1 or vim.fn.has('win64') == 1
  local is_wayland = vim.env.WAYLAND_DISPLAY ~= nil or vim.env.XDG_SESSION_TYPE == 'wayland'
  
  -- Windows (native)
  if is_windows then
    vim.g.clipboard = {
      name = 'windows',
      copy = {
        ['+'] = 'clip',
        ['*'] = 'clip',
      },
      paste = {
        ['+'] = 'powershell -noprofile -command Get-Clipboard',
        ['*'] = 'powershell -noprofile -command Get-Clipboard',
      },
      cache_enabled = 0,
    }
  -- WSL
  elseif is_wsl then
    -- Try win32yank first (fastest), then fallback to clip.exe + powershell
    if vim.fn.executable('win32yank.exe') == 1 then
      if is_tmux then
        vim.g.clipboard = {
          name = 'win32yank-wsl-tmux',
          copy = {
            ['+'] = 'win32yank.exe -i --crlf; echo "$REPLY" | tmux load-buffer -',
            ['*'] = 'win32yank.exe -i --crlf; echo "$REPLY" | tmux load-buffer -',
          },
          paste = {
            ['+'] = 'win32yank.exe -o --lf',
            ['*'] = 'win32yank.exe -o --lf',
          },
          cache_enabled = 0,
        }
      else
        vim.g.clipboard = {
          name = 'win32yank-wsl',
          copy = {
            ['+'] = 'win32yank.exe -i --crlf',
            ['*'] = 'win32yank.exe -i --crlf',
          },
          paste = {
            ['+'] = 'win32yank.exe -o --lf',
            ['*'] = 'win32yank.exe -o --lf',
          },
          cache_enabled = 0,
        }
      end
    else
      if is_tmux then
        vim.g.clipboard = {
          name = 'WslClipboard-tmux',
          copy = {
            ['+'] = 'tee >(clip.exe) | tmux load-buffer -',
            ['*'] = 'tee >(clip.exe) | tmux load-buffer -',
          },
          paste = {
            ['+'] = 'powershell.exe -c [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))',
            ['*'] = 'powershell.exe -c [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))',
          },
          cache_enabled = 0,
        }
      else
        vim.g.clipboard = {
          name = 'WslClipboard',
          copy = {
            ['+'] = 'clip.exe',
            ['*'] = 'clip.exe',
          },
          paste = {
            ['+'] = 'powershell.exe -c [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))',
            ['*'] = 'powershell.exe -c [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))',
          },
          cache_enabled = 0,
        }
      end
    end
  -- Linux with Wayland
  elseif is_wayland and vim.fn.executable('wl-copy') == 1 then
    if is_tmux then
      vim.g.clipboard = {
        name = 'wl-clipboard-tmux',
        copy = {
          ['+'] = 'tee >(wl-copy) | tmux load-buffer -',
          ['*'] = 'tee >(wl-copy) | tmux load-buffer -',
        },
        paste = {
          ['+'] = 'wl-paste --no-newline',
          ['*'] = 'wl-paste --no-newline',
        },
        cache_enabled = 0,
      }
    else
      vim.g.clipboard = {
        name = 'wl-clipboard',
        copy = {
          ['+'] = 'wl-copy',
          ['*'] = 'wl-copy',
        },
        paste = {
          ['+'] = 'wl-paste --no-newline',
          ['*'] = 'wl-paste --no-newline',
        },
        cache_enabled = 0,
      }
    end
  -- Linux with X11
  elseif vim.fn.executable('xclip') == 1 then
    if is_tmux then
      vim.g.clipboard = {
        name = 'xclip-tmux',
        copy = {
          ['+'] = 'tee >(xclip -selection clipboard) | tmux load-buffer -',
          ['*'] = 'tee >(xclip -selection primary) | tmux load-buffer -',
        },
        paste = {
          ['+'] = 'xclip -selection clipboard -o',
          ['*'] = 'xclip -selection primary -o',
        },
        cache_enabled = 0,
      }
    else
      vim.g.clipboard = {
        name = 'xclip',
        copy = {
          ['+'] = 'xclip -selection clipboard',
          ['*'] = 'xclip -selection primary',
        },
        paste = {
          ['+'] = 'xclip -selection clipboard -o',
          ['*'] = 'xclip -selection primary -o',
        },
        cache_enabled = 0,
      }
    end
  -- Fallback to xsel if available
  elseif vim.fn.executable('xsel') == 1 then
    if is_tmux then
      vim.g.clipboard = {
        name = 'xsel-tmux',
        copy = {
          ['+'] = 'tee >(xsel --clipboard --input) | tmux load-buffer -',
          ['*'] = 'tee >(xsel --primary --input) | tmux load-buffer -',
        },
        paste = {
          ['+'] = 'xsel --clipboard --output',
          ['*'] = 'xsel --primary --output',
        },
        cache_enabled = 0,
      }
    else
      vim.g.clipboard = {
        name = 'xsel',
        copy = {
          ['+'] = 'xsel --clipboard --input',
          ['*'] = 'xsel --primary --input',
        },
        paste = {
          ['+'] = 'xsel --clipboard --output',
          ['*'] = 'xsel --primary --output',
        },
        cache_enabled = 0,
      }
    end
  -- Fallback for tmux-only environments
  elseif is_tmux then
    vim.g.clipboard = {
      name = 'tmux-only',
      copy = {
        ['+'] = 'tmux load-buffer -',
        ['*'] = 'tmux load-buffer -',
      },
      paste = {
        ['+'] = 'tmux save-buffer -',
        ['*'] = 'tmux save-buffer -',
      },
      cache_enabled = 0,
    }
  end
end

setup_clipboard()

-- Enable break indent
vim.o.breakindent = true

-- Save undo history
vim.o.undofile = true

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.o.ignorecase = true
vim.o.smartcase = true

-- Keep signcolumn on by default
vim.o.signcolumn = 'yes'

-- Decrease update time
vim.o.updatetime = 250

-- Decrease mapped sequence wait time
vim.o.timeoutlen = 300
vim.o.ttimeoutlen = 5

-- Fix escape sequence delays (ttyfast is deprecated and no longer needed)

-- Configure how new splits should be opened
vim.o.splitright = true
vim.o.splitbelow = true

-- Sets how neovim will display certain whitespace characters in the editor.
--  See `:help 'list'`
--  and `:help 'listchars'`
--
--  Notice listchars is set using `vim.opt` instead of `vim.o`.
--  It is very similar to `vim.o` but offers an interface for conveniently interacting with tables.
--   See `:help lua-options`
--   and `:help lua-options-guide`
vim.o.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- Preview substitutions live, as you type!
vim.o.inccommand = 'split'

-- Show which line your cursor is on
vim.o.cursorline = true

-- Minimal number of screen lines to keep above and below the cursor.
vim.o.scrolloff = 10

-- if performing an operation that would fail due to unsaved changes in the buffer (like `:q`),
-- instead raise a dialog asking if you wish to save the current file(s)
-- See `:help 'confirm'`
vim.o.confirm = true
