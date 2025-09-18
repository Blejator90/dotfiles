-- Configure conform.nvim for formatting
local conform = require("conform")

conform.setup({
  formatters_by_ft = {
    -- JavaScript/TypeScript formatting
    javascript = { "prettier" },
    javascriptreact = { "prettier" },
    typescript = { "prettier" },
    typescriptreact = { "prettier" },
    json = { "prettier" },
    jsonc = { "prettier" },
    html = { "prettier" },
    css = { "prettier" },
    scss = { "prettier" },
    markdown = { "prettier" },
    yaml = { "prettier" },

    -- C/C++ formatting
    c = { "clang-format" },
    cpp = { "clang-format" },
    objc = { "clang-format" },
    objcpp = { "clang-format" },

    -- Swift formatting
    swift = { "swiftformat" },

    -- Other languages
    python = { "black", "isort" },
    rust = { "rustfmt" },
    lua = { "stylua" },
    go = { "gofmt" },
  },

  -- Use local project formatters if available, otherwise use global
  formatters = {
    prettier = {
      -- Use npx which automatically uses local prettier if available
      command = "npx",
      args = { "prettier", "--stdin-filepath", "$FILENAME" },
      stdin = true,
    },
  },

  -- Format on save (optional, you can comment this out if you prefer manual formatting)
  format_on_save = {
    -- Enable format on save
    lsp_fallback = true,
    timeout_ms = 1000,
  },

  -- Notify on format errors
  notify_on_error = true,
})

-- Keybinding for manual formatting
vim.keymap.set({ "n", "v" }, "<leader>f", function()
  conform.format({
    lsp_fallback = true,
    async = false,
    timeout_ms = 1000,
  })
end, { desc = "Format file or range (in visual mode)" })

-- Alternative keybinding that matches your existing pattern
vim.keymap.set("n", "<leader>F", function()
  conform.format({
    lsp_fallback = true,
    async = true,
    timeout_ms = 2000,
  })
end, { desc = "Format file (async)" })

-- Create a command for formatting
vim.api.nvim_create_user_command("Format", function(args)
  local range = nil
  if args.count ~= -1 then
    local end_line = vim.api.nvim_buf_get_lines(0, args.line2 - 1, args.line2, true)[1]
    range = {
      start = { args.line1, 0 },
      ["end"] = { args.line2, end_line:len() },
    }
  end
  conform.format({ async = true, lsp_fallback = true, range = range })
end, { range = true })

-- Show formatter info for current buffer
vim.api.nvim_create_user_command("ConformInfo", function()
  require("conform").list_formatters()
end, {})