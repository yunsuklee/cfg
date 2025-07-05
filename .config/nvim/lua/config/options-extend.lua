-- Indentation settings
vim.o.expandtab = true
vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.o.softtabstop = 4
vim.o.smartindent = true
vim.o.autoindent = true

-- Disable archive/compressions built-in plugins
vim.g.loaded_gzip = 1 -- Reading .gz files
vim.g.loaded_zip = 1 -- Reading .zip files
vim.g.loaded_zipPlugin = 1 -- More zip functionality
vim.g.loaded_tar = 1 -- Reading .tar files
vim.g.loaded_tarPlugin = 1 -- More tar functionality
vim.g.loaded_vimball = 1 -- Vim's package format (obsolete)
vim.g.loaded_vimballPlugin = 1 -- More vimball functionality

-- Disable legacy scripting/web built-in plugins
vim.g.loaded_getscript = 1 -- Download vim scripts from web
vim.g.loaded_getscriptPlugin = 1 -- More getscript functionality
vim.g.loaded_2html_plugin = 1 -- Convert vim buffer to HTML

-- Disable text processing built-in plugins
vim.g.loaded_logiPat = 1 -- Logical pattern matching
vim.g.loaded_rrhelper = 1 -- Helper for remote plugins

-- Disable other built-in plugins
vim.g.loaded_spellfile_plugin = 1 -- Spell file management
vim.g.loaded_tutor_mode_plugin = 1 -- Vim tutor (:Tutor command)
