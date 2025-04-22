-- Load lsp-zero, a preset for easier LSP configuration
local lsp_zero = require('lsp-zero')

-- Set up LSP-specific keymaps when a language server attaches to a buffer
lsp_zero.on_attach(function(client, bufnr)
  local opts = { buffer = bufnr, remap = false }

  -- Go to definition
  vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, opts)

  -- Show hover info (e.g. function docs)
  vim.keymap.set("n", "K", function() vim.lsp.buf.hover() end, opts)

  -- Search workspace symbols (like global functions/classes)
  vim.keymap.set("n", "<leader>vws", function() vim.lsp.buf.workspace_symbol() end, opts)

  -- Show diagnostics in floating window
  vim.keymap.set("n", "<leader>vd", function() vim.diagnostic.open_float() end, opts)

  -- Jump to next/previous diagnostic
  vim.keymap.set("n", "[d", function() vim.diagnostic.goto_next() end, opts)
  vim.keymap.set("n", "]d", function() vim.diagnostic.goto_prev() end, opts)

  -- Trigger code action (e.g. fix, refactor)
  vim.keymap.set("n", "<leader>vca", function() vim.lsp.buf.code_action() end, opts)

  -- Find references
  vim.keymap.set("n", "<leader>vrr", function() vim.lsp.buf.references() end, opts)

  -- Rename symbol
  vim.keymap.set("n", "<leader>vrn", function() vim.lsp.buf.rename() end, opts)

  -- Show function signature help (when typing args)
  vim.keymap.set("i", "<C-h>", function() vim.lsp.buf.signature_help() end, opts)
end)

-- Initialize Mason (LSP installer UI)
require('mason').setup({})

-- Automatically install and configure these LSPs
require('mason-lspconfig').setup({
  ensure_installed = {
    'pyright',         -- Python
    'rust_analyzer',   -- Rust
    'clangd',          -- C/C++
  },
  handlers = {
    lsp_zero.default_setup -- Apply lsp-zero defaults to each LSP
  }
})

-- Load completion plugin
local cmp = require('cmp')

-- Use "select" behavior when choosing suggestions
local cmp_select = { behavior = cmp.SelectBehavior.Select }

-- Configure nvim-cmp
cmp.setup({
  -- Sources for completion
  sources = {
    { name = 'path' },        -- Filesystem paths
    { name = 'nvim_lsp' },    -- LSP-based completions
    { name = 'nvim_lua' },    -- Lua API completions (useful for config)
  },

  -- Format entries using lsp-zero’s helper
  formatting = lsp_zero.cmp_format(),

  -- Keybindings for completion menu
  mapping = cmp.mapping.preset.insert({
    ['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),   -- Previous suggestion
    ['<C-n>'] = cmp.mapping.select_next_item(cmp_select),   -- Next suggestion
    ['<C-y>'] = cmp.mapping.confirm({ select = true }),     -- Confirm selection
    ['<C-Space>'] = cmp.mapping.complete(),                 -- Manually trigger completion
  }),
})
