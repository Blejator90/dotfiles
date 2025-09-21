-- LSP Configuration
local lsp_zero = require('lsp-zero')

lsp_zero.on_attach(function(client, bufnr)
  local opts = { buffer = bufnr, remap = false }

  -- Standard LSP keybindings
  vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
  vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
  vim.keymap.set("n", "<leader>vws", vim.lsp.buf.workspace_symbol, opts)
  vim.keymap.set("n", "<leader>vd", vim.diagnostic.open_float, opts)
  vim.keymap.set("n", "[d", vim.diagnostic.goto_next, opts)
  vim.keymap.set("n", "]d", vim.diagnostic.goto_prev, opts)
  vim.keymap.set("n", "<leader>vca", vim.lsp.buf.code_action, opts)
  vim.keymap.set("n", "<leader>vrr", vim.lsp.buf.references, opts)
  vim.keymap.set("n", "<leader>vrn", vim.lsp.buf.rename, opts)
  vim.keymap.set("i", "<C-h>", vim.lsp.buf.signature_help, opts)

  -- Organize imports for TypeScript
  if client.name == "tsserver" or client.name == "ts_ls" then
    -- Manual organize imports command
    vim.keymap.set("n", "<leader>oi", function()
      vim.lsp.buf.execute_command({
        command = "_typescript.organizeImports",
        arguments = { vim.api.nvim_buf_get_name(0) },
      })
    end, { buffer = bufnr, desc = "Organize Imports" })

    -- Auto organize imports on save (before formatting)
    vim.api.nvim_create_autocmd("BufWritePre", {
      buffer = bufnr,
      group = vim.api.nvim_create_augroup("TypeScriptOrganizeImports", { clear = false }),
      callback = function()
        -- Run organize imports synchronously before save
        local params = {
          command = "_typescript.organizeImports",
          arguments = { vim.api.nvim_buf_get_name(0) },
        }
        vim.lsp.buf_request_sync(bufnr, "workspace/executeCommand", params, 1000)
      end,
    })

    -- TypeScript/NestJS specific keymaps
    local package_json = vim.fn.findfile("package.json", ".;")
    if package_json ~= "" then
      vim.keymap.set("n", "<leader>tb", ":TSBuild<CR>", { buffer = bufnr, desc = "TS Build" })
      vim.keymap.set("n", "<leader>tl", ":TSLint<CR>", { buffer = bufnr, desc = "TS Lint" })
      vim.keymap.set("n", "<leader>tt", ":TSTest<CR>", { buffer = bufnr, desc = "TS Test" })
      vim.keymap.set("n", "<leader>tu", ":TSTestUnit<CR>", { buffer = bufnr, desc = "TS Test Unit" })
      vim.keymap.set("n", "<leader>ti", ":TSTestIntegration<CR>", { buffer = bufnr, desc = "TS Test Integration" })
      vim.keymap.set("n", "<leader>te", ":TSTestE2E<CR>", { buffer = bufnr, desc = "TS Test E2E" })
      vim.keymap.set("n", "<leader>tr", ":TSDev<CR>", { buffer = bufnr, desc = "TS Run Dev" })
      vim.keymap.set("n", "<leader>td", ":TSDev<CR>", { buffer = bufnr, desc = "TS Dev Server" })
    end
  end

  -- Swift-specific keymaps
  if vim.bo[bufnr].filetype == "swift" then
    local function find_xcode_project()
      local result = vim.fs.find(function(name)
        return name:match("%.xcworkspace$") or name:match("%.xcodeproj$")
      end, { upward = true, type = "directory" })
      return result and result[1] or nil
    end

    local has_package = vim.fn.findfile("Package.swift", ".;") ~= ""
    local has_xcode = find_xcode_project() ~= nil

    if has_xcode then
      vim.keymap.set("n", "<leader>wb", ":XcodeBuild<CR>", { buffer = bufnr, desc = "Xcode Build" })
      vim.keymap.set("n", "<leader>wt", ":XcodeTest<CR>", { buffer = bufnr, desc = "Xcode Test" })
      vim.keymap.set("n", "<leader>wr", ":XcodeRun<CR>", { buffer = bufnr, desc = "Xcode Run" })
      vim.keymap.set("n", "<leader>wo", ":XcodeOpen<CR>", { buffer = bufnr, desc = "Open in Xcode" })
      vim.keymap.set("n", "<leader>ws", ":SwiftSetScheme<CR>", { buffer = bufnr, desc = "Set Xcode Scheme" })
      vim.keymap.set("n", "<leader>wd", ":SwiftSetDestination<CR>", { buffer = bufnr, desc = "Set Destination" })
    elseif has_package then
      vim.keymap.set("n", "<leader>wb", ":SwiftBuild<CR>", { buffer = bufnr, desc = "Swift Build" })
      vim.keymap.set("n", "<leader>wr", ":SwiftRun<CR>", { buffer = bufnr, desc = "Swift Run" })
      vim.keymap.set("n", "<leader>wt", ":SwiftTest<CR>", { buffer = bufnr, desc = "Swift Test" })
      vim.keymap.set("n", "<leader>wo", ":XcodeOpen<CR>", { buffer = bufnr, desc = "Open in Xcode" })
    else
      -- Fallback for iOS projects without explicit detection
      vim.keymap.set("n", "<leader>wb", ":XcodeBuild<CR>", { buffer = bufnr, desc = "Xcode Build" })
      vim.keymap.set("n", "<leader>wt", ":XcodeTest<CR>", { buffer = bufnr, desc = "Xcode Test" })
      vim.keymap.set("n", "<leader>wr", ":XcodeRun<CR>", { buffer = bufnr, desc = "Xcode Run" })
      vim.keymap.set("n", "<leader>wo", ":XcodeOpen<CR>", { buffer = bufnr, desc = "Open in Xcode" })
      vim.keymap.set("n", "<leader>ws", ":SwiftSetScheme<CR>", { buffer = bufnr, desc = "Set Xcode Scheme" })
      vim.keymap.set("n", "<leader>wd", ":SwiftSetDestination<CR>", { buffer = bufnr, desc = "Set Destination" })
    end
  end

  -- C/C++ specific keymaps
  if vim.bo[bufnr].filetype == "c" or vim.bo[bufnr].filetype == "cpp" then
    vim.keymap.set("n", "<leader>cb", ":CBuild<CR>", { buffer = bufnr, desc = "C Build" })
    vim.keymap.set("n", "<leader>cr", ":CRun<CR>", { buffer = bufnr, desc = "C Run" })
    vim.keymap.set("n", "<leader>cd", ":CDebug<CR>", { buffer = bufnr, desc = "C Debug" })
    vim.keymap.set("n", "<leader>cc", ":CConfig<CR>", { buffer = bufnr, desc = "C Configure" })
    vim.keymap.set("n", "<leader>cq", ":CQuickRun<CR>", { buffer = bufnr, desc = "C Quick Run" })
  end
end)

-- Configure Mason
require('mason').setup({})
require('mason-lspconfig').setup({
  ensure_installed = {
    'tsserver',          -- TypeScript/JavaScript
    'eslint',            -- ESLint for JS/TS
    'pyright',           -- Python
    'rust_analyzer',     -- Rust
    'clangd',            -- C/C++
    'lua_ls',            -- Lua
  },
  handlers = {
    lsp_zero.default_setup,

    -- TypeScript specific setup (using ts_ls as tsserver is deprecated)
    ts_ls = function()
      require('lspconfig').ts_ls.setup({
        on_attach = function(client, bufnr)
          -- Call the default on_attach
          lsp_zero.on_attach(client, bufnr)

          -- Enable formatting capabilities
          client.server_capabilities.documentFormattingProvider = false
          client.server_capabilities.documentRangeFormattingProvider = false
        end,
        capabilities = lsp_zero.get_capabilities(),
        settings = {
          typescript = {
            inlayHints = {
              includeInlayParameterNameHints = 'all',
              includeInlayParameterNameHintsWhenArgumentMatchesName = false,
              includeInlayFunctionParameterTypeHints = true,
              includeInlayVariableTypeHints = true,
            },
            format = {
              enable = false -- Let prettier handle formatting
            },
            updateImportsOnFileMove = {
              enabled = 'always'
            },
          },
          javascript = {
            inlayHints = {
              includeInlayParameterNameHints = 'all',
              includeInlayParameterNameHintsWhenArgumentMatchesName = false,
              includeInlayFunctionParameterTypeHints = true,
              includeInlayVariableTypeHints = true,
            },
            format = {
              enable = false -- Let prettier handle formatting
            },
            updateImportsOnFileMove = {
              enabled = 'always'
            },
          },
        },
      })
    end,

    -- C/C++ specific setup
    clangd = function()
      require('lspconfig').clangd.setup({
        on_attach = lsp_zero.on_attach,
        capabilities = lsp_zero.get_capabilities(),
        cmd = {
          "clangd",
          "--background-index",
          "--clang-tidy",
          "--header-insertion=iwyu",
          "--completion-style=detailed",
          "--function-arg-placeholders",
        },
      })
    end,

    -- Lua specific setup
    lua_ls = function()
      require('lspconfig').lua_ls.setup({
        on_attach = lsp_zero.on_attach,
        capabilities = lsp_zero.get_capabilities(),
        settings = {
          Lua = {
            runtime = {
              version = 'LuaJIT',
            },
            diagnostics = {
              globals = { 'vim' },
            },
            workspace = {
              library = vim.api.nvim_get_runtime_file("", true),
              checkThirdParty = false,
            },
            telemetry = {
              enable = false,
            },
          },
        },
      })
    end,
  }
})

