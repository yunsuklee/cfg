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

local function is_executable(cmd)
  return vim.fn.executable(cmd) == 1
end

-- Smart clipboard detection with tmux support
local is_tmux = vim.env.TMUX ~= nil

if vim.fn.has("win32") == 1 or vim.fn.has("win64") == 1 then
  -- Windows native: Use PowerShell
  vim.g.clipboard = {
    name = "powershell",
    copy = {
      ["+"] = "powershell.exe -c [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace(\"`r\", \"\"))",
      ["*"] = "powershell.exe -c [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace(\"`r\", \"\"))",
    },
    paste = {
      ["+"] = "powershell.exe -c Set-Clipboard $input",
      ["*"] = "powershell.exe -c Set-Clipboard $input",
    },
    cache_enabled = true,
  }
elseif vim.fn.has("wsl") == 1 then
  -- WSL: Use clip.exe + powershell (win32yank seems to have issues)
  if is_executable("clip.exe") then
    local ps_paste = "powershell.exe -c [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace(\"`r\", \"\"))"
    
    if is_tmux then
      vim.g.clipboard = {
        name = "wsl-clip-tmux",
        copy = {
          ["+"] = "tee >(clip.exe) | tmux load-buffer -",
          ["*"] = "tee >(clip.exe) | tmux load-buffer -",
        },
        paste = {
          ["+"] = ps_paste,
          ["*"] = ps_paste,
        },
        cache_enabled = true,
      }
    else
      vim.g.clipboard = {
        name = "wsl-clip",
        copy = {
          ["+"] = "clip.exe",
          ["*"] = "clip.exe",
        },
        paste = {
          ["+"] = ps_paste,
          ["*"] = ps_paste,
        },
        cache_enabled = true,
      }
    end
  end
elseif vim.fn.has("mac") == 1 then
  -- macOS: Enhanced with tmux support
  if is_tmux then
    vim.g.clipboard = {
      name = "pbcopy-tmux",
      copy = {
        ["+"] = "tee >(pbcopy) | tmux load-buffer -",
        ["*"] = "tee >(pbcopy) | tmux load-buffer -",
      },
      paste = {
        ["+"] = "pbpaste",
        ["*"] = "pbpaste",
      },
      cache_enabled = true,
    }
  end
elseif vim.fn.has("unix") == 1 then
  -- Unix-like (Linux): Detect Wayland or X11 with tmux support
  local has_wl = os.getenv("WAYLAND_DISPLAY") ~= nil
  local has_x11 = os.getenv("DISPLAY") ~= nil

  if has_wl and is_executable("wl-copy") and is_executable("wl-paste") then
    if is_tmux then
      vim.g.clipboard = {
        name = "wl-clipboard-tmux",
        copy = {
          ["+"] = "tee >(wl-copy --foreground --type text/plain) | tmux load-buffer -",
          ["*"] = "tee >(wl-copy --foreground --type text/plain) | tmux load-buffer -",
        },
        paste = {
          ["+"] = "wl-paste --no-newline",
          ["*"] = "wl-paste --no-newline",
        },
        cache_enabled = true,
      }
    else
      vim.g.clipboard = {
        name = "wl-clipboard",
        copy = {
          ["+"] = "wl-copy --foreground --type text/plain",
          ["*"] = "wl-copy --foreground --type text/plain",
        },
        paste = {
          ["+"] = "wl-paste --no-newline",
          ["*"] = "wl-paste --no-newline",
        },
        cache_enabled = true,
      }
    end
  elseif has_x11 and is_executable("xclip") then
    if is_tmux then
      vim.g.clipboard = {
        name = "xclip-tmux",
        copy = {
          ["+"] = "tee >(xclip -selection clipboard) | tmux load-buffer -",
          ["*"] = "tee >(xclip -selection primary) | tmux load-buffer -",
        },
        paste = {
          ["+"] = "xclip -selection clipboard -o",
          ["*"] = "xclip -selection primary -o",
        },
        cache_enabled = true,
      }
    else
      vim.g.clipboard = {
        name = "xclip",
        copy = {
          ["+"] = "xclip -selection clipboard",
          ["*"] = "xclip -selection primary",
        },
        paste = {
          ["+"] = "xclip -selection clipboard -o",
          ["*"] = "xclip -selection primary -o",
        },
        cache_enabled = true,
      }
    end
  elseif has_x11 and is_executable("xsel") then
    if is_tmux then
      vim.g.clipboard = {
        name = "xsel-tmux",
        copy = {
          ["+"] = "tee >(xsel --clipboard --input) | tmux load-buffer -",
          ["*"] = "tee >(xsel --primary --input) | tmux load-buffer -",
        },
        paste = {
          ["+"] = "xsel --clipboard --output",
          ["*"] = "xsel --primary --output",
        },
        cache_enabled = true,
      }
    else
      vim.g.clipboard = {
        name = "xsel",
        copy = {
          ["+"] = "xsel --clipboard --input",
          ["*"] = "xsel --primary --input",
        },
        paste = {
          ["+"] = "xsel --clipboard --output",
          ["*"] = "xsel --primary --output",
        },
        cache_enabled = true,
      }
    end
  end
end

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
