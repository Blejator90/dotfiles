-- Configure LSP diagnostics display
vim.diagnostic.config({
  -- Show diagnostics in virtual text (inline with code)
  virtual_text = {
    source = "if_many", -- Show source if multiple
    prefix = "●", -- Symbol before diagnostic text
    spacing = 2,
  },

  -- Show diagnostics in signs column (left side)
  signs = true,

  -- Underline problematic code
  underline = true,

  -- Update diagnostics in insert mode (can be distracting, disable if needed)
  update_in_insert = false,

  -- Sort diagnostics by severity
  severity_sort = true,

  -- Floating window config for hover diagnostics
  float = {
    source = "always", -- Always show the source
    border = "rounded",
    header = "",
    prefix = "",
  },
})

-- Customize diagnostic signs (icons in the gutter)
local signs = { Error = "󰅚 ", Warn = "󰀪 ", Hint = "󰌶 ", Info = " " }
for type, icon in pairs(signs) do
  local hl = "DiagnosticSign" .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

-- Enhanced keymaps for navigating diagnostics
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = "Show diagnostic in floating window" })
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = "Go to previous diagnostic" })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = "Go to next diagnostic" })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = "Add diagnostics to location list" })

-- Show diagnostics automatically when cursor holds
vim.api.nvim_create_autocmd("CursorHold", {
  callback = function()
    local opts = {
      focusable = false,
      close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
      border = 'rounded',
      source = 'always',
      prefix = ' ',
      scope = 'cursor',
    }
    vim.diagnostic.open_float(nil, opts)
  end
})

-- Reduce the delay for CursorHold events (default is 4000ms)
vim.opt.updatetime = 1000