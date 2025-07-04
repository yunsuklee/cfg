return {
  "stevearc/conform.nvim",
  opts = {
    formatters_by_ft = {
      sh = function(bufnr)
        -- Don't format .env files even if they're detected as shell
        if vim.fn.expand("%:t"):match("%.env") then
          return {}
        end
        return { "shfmt" }
      end,
    },
  },
}
