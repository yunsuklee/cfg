return {
  { -- Detect tabstop and shiftwidth automatically
    'NMAC427/guess-indent.nvim',
    event = 'BufReadPost', -- Load after file content is loaded
    opts = {},
  },

  { -- Autoformat
    'stevearc/conform.nvim',
    event = 'BufWritePre', -- Load when about to save a file
    cmd = 'ConformInfo', -- Also load when command is used
    keys = {
      {
        '<leader>f',
        function()
          require('conform').format { async = true, lsp_format = 'fallback' }
        end,
        mode = '',
        desc = '[F]ormat buffer',
      },
    },
    opts = {
      notify_on_error = false,
      format_on_save = function(bufnr)
        -- Disable "format_on_save lsp_fallback" for languages that don't
        -- have a well standardized coding style. You can add additional
        -- languages here or re-enable it for the disabled ones.
        local disable_filetypes = {} -- Removed c and cpp since clang-format is well standardized
        if disable_filetypes[vim.bo[bufnr].filetype] then
          return nil
        else
          return {
            timeout_ms = 500,
            lsp_format = 'fallback',
          }
        end
      end,
      formatters_by_ft = {
        ['*'] = { 'trim_whitespace' },
        lua = { 'stylua' },
        rust = { 'rustfmt' },
        -- C/C++ formatting
        c = { 'clang-format' },
        cpp = { 'clang-format' },
        -- TypeScript/JavaScript formatting
        javascript = { 'prettierd', 'prettier', stop_after_first = true },
        typescript = { 'prettierd', 'prettier', stop_after_first = true },
        javascriptreact = { 'prettierd', 'prettier', stop_after_first = true },
        typescriptreact = { 'prettierd', 'prettier', stop_after_first = true },
        -- Web technologies
        json = { 'prettierd', 'prettier', stop_after_first = true },
        html = { 'prettierd', 'prettier', stop_after_first = true },
        css = { 'prettierd', 'prettier', stop_after_first = true },
        scss = { 'prettierd', 'prettier', stop_after_first = true },
        markdown = { 'prettierd', 'prettier', stop_after_first = true },
        yaml = { 'prettierd', 'prettier', stop_after_first = true },
        -- Conform can also run multiple formatters sequentially
        -- python = { "isort", "black" },
      },
      formatters = {
        prettier = {
          -- You can customize prettier options here
          prepend_args = { '--single-quote', '--trailing-comma', 'es5' },
        },
        prettierd = {
          -- prettierd inherits prettier config automatically
        },
      },
    },
  },
}
