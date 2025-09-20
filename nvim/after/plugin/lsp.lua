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
  
  -- Swift-specific keymaps (auto-detect project type)
  if vim.bo.filetype == "swift" then
    -- Check if we're in an Xcode project or SPM project
    local has_package = vim.fn.findfile("Package.swift", ".;") ~= ""
    local has_xcode = vim.fn.glob("*.xcodeproj") ~= "" or vim.fn.glob("*.xcworkspace") ~= ""

    if has_xcode then
      vim.keymap.set("n", "<leader>wb", ":XcodeBuild<CR>", opts)
      vim.keymap.set("n", "<leader>wt", ":XcodeTest<CR>", opts)
    elseif has_package then
      vim.keymap.set("n", "<leader>wb", ":SwiftBuild<CR>", opts)
      vim.keymap.set("n", "<leader>wr", ":SwiftRun<CR>", opts)
      vim.keymap.set("n", "<leader>wt", ":SwiftTest<CR>", opts)
    end

    vim.keymap.set("n", "<leader>wo", ":XcodeOpen<CR>", opts)
  end

  -- TypeScript/NestJS-specific keymaps
  if vim.bo.filetype == "typescript" then
    -- Check if we're in a Node.js project (has package.json)
    local package_json = vim.fn.findfile("package.json", ".;")
    if package_json ~= "" then
      vim.keymap.set("n", "<leader>tb", ":TSBuild<CR>", opts)
      vim.keymap.set("n", "<leader>tl", ":TSLint<CR>", opts)
      vim.keymap.set("n", "<leader>tt", ":TSTest<CR>", opts)
      vim.keymap.set("n", "<leader>ti", ":TSTestIntegration<CR>", opts)
      vim.keymap.set("n", "<leader>ta", ":TSTestAll<CR>", opts)
      vim.keymap.set("n", "<leader>tr", ":TSRun<CR>", opts)
    end
  end
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

vim.lsp.config.ts_ls = {
  cmd = { 'typescript-language-server', '--stdio' },
  filetypes = { 'typescript', 'typescriptreact', 'javascript', 'javascriptreact' },
  root_markers = { 'package.json', 'tsconfig.json' },
}

require('lspconfig').sourcekit.setup({
    cmd = { "xcrun", "sourcekit-lsp" },
    filetypes = { "swift" },
    root_dir = require('lspconfig.util').root_pattern(
        "Package.swift",
        "*.xcodeproj",
        "*.xcworkspace",
        ".git"
    ),
    settings = {
        sourcekit = {
            indexSystemModules = true,
        }
    },
    capabilities = {
        workspace = {
            didChangeWatchedFiles = {
                dynamicRegistration = true
            }
        }
    }
})

-- Swift-specific commands
vim.api.nvim_create_user_command("SwiftBuild", function()
  vim.cmd("terminal swift build")
end, {})

vim.api.nvim_create_user_command("SwiftRun", function()
  vim.cmd("terminal swift run")
end, {})

vim.api.nvim_create_user_command("SwiftTest", function()
  vim.cmd("terminal swift test")
end, {})


-- Open current file in Xcode for deeper inspection
vim.api.nvim_create_user_command("XcodeOpen", function()
  local file = vim.fn.expand("%:p")
  vim.fn.system(string.format("open -a Xcode '%s'", file))
end, {})

-- TypeScript/NestJS-specific commands
vim.api.nvim_create_user_command("TSBuild", function()
  vim.cmd("terminal npm run build")
end, {})

vim.api.nvim_create_user_command("TSLint", function()
  vim.cmd("terminal npm run lint")
end, {})

vim.api.nvim_create_user_command("TSTest", function()
  vim.cmd("terminal npm test")
end, {})

vim.api.nvim_create_user_command("TSTestIntegration", function()
  vim.cmd("terminal npm run test:integration")
end, {})

vim.api.nvim_create_user_command("TSTestAll", function()
  vim.cmd("terminal npm run test:all")
end, {})

vim.api.nvim_create_user_command("TSRun", function()
  vim.cmd("terminal npm run start:dev")
  vim.cmd("startinsert")  -- automatically enter insert mode
end, {})

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
