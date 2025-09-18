-- Configure nvim-lint for real-time linting
local lint = require('lint')

-- Configure linters by filetype
lint.linters_by_ft = {
  typescript = { 'eslint_d' },
  typescriptreact = { 'eslint_d' },
  javascript = { 'eslint_d' },
  javascriptreact = { 'eslint_d' },

  -- Optional: other languages
  python = { 'pylint' },
  swift = { 'swiftlint' },
}

-- Use faster eslint_d (daemon) for better performance
-- Falls back to eslint if eslint_d is not available
local function try_lint()
  -- Check if eslint_d is available, otherwise use eslint
  if vim.fn.executable('eslint_d') == 1 then
    lint.linters_by_ft.typescript = { 'eslint_d' }
    lint.linters_by_ft.typescriptreact = { 'eslint_d' }
    lint.linters_by_ft.javascript = { 'eslint_d' }
    lint.linters_by_ft.javascriptreact = { 'eslint_d' }
  else
    lint.linters_by_ft.typescript = { 'eslint' }
    lint.linters_by_ft.typescriptreact = { 'eslint' }
    lint.linters_by_ft.javascript = { 'eslint' }
    lint.linters_by_ft.javascriptreact = { 'eslint' }
  end

  -- Run linting
  lint.try_lint()
end

-- Auto-lint on various events
local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })

vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
  group = lint_augroup,
  callback = try_lint,
})

-- Manual lint command
vim.api.nvim_create_user_command("Lint", try_lint, { desc = "Run linter on current buffer" })

-- Keybinding for manual linting
vim.keymap.set("n", "<leader>l", try_lint, { desc = "Run linter" })