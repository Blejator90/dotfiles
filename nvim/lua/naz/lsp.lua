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


    -- TypeScript/NestJS specific keymaps
    local package_json = vim.fn.findfile("package.json", ".;")
    if package_json ~= "" then
      -- Detect package manager
      local pm = "npm"
      if vim.fn.filereadable("bun.lockb") == 1 then
        pm = "bun"
      elseif vim.fn.filereadable("pnpm-lock.yaml") == 1 then
        pm = "pnpm"
      elseif vim.fn.filereadable("yarn.lock") == 1 then
        pm = "yarn"
      end

      -- Build command
      vim.keymap.set("n", "<leader>tb", function()
        vim.cmd("split | terminal " .. pm .. " run build")
      end, { buffer = bufnr, desc = "TS Build" })

      -- Lint command
      vim.keymap.set("n", "<leader>tl", function()
        vim.cmd("split | terminal " .. pm .. " run lint")
      end, { buffer = bufnr, desc = "TS Lint" })

      -- Test command
      vim.keymap.set("n", "<leader>tt", function()
        vim.cmd("split | terminal " .. pm .. " test")
      end, { buffer = bufnr, desc = "TS Test" })

      -- Dev server
      vim.keymap.set("n", "<leader>tr", function()
        vim.cmd("split | terminal " .. pm .. " run dev")
      end, { buffer = bufnr, desc = "TS Run Dev" })

      vim.keymap.set("n", "<leader>td", function()
        vim.cmd("split | terminal " .. pm .. " run dev")
      end, { buffer = bufnr, desc = "TS Dev Server" })
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
    'ts_ls',             -- TypeScript/JavaScript
    'eslint',            -- ESLint for JS/TS
    'pyright',           -- Python
    'rust_analyzer',     -- Rust
    'clangd',            -- C/C++
    'lua_ls',            -- Lua
  },
  handlers = {
    lsp_zero.default_setup,

    -- ESLint specific setup - suppress plugin errors
    eslint = function()
      require('lspconfig').eslint.setup({
        on_attach = lsp_zero.on_attach,
        capabilities = lsp_zero.get_capabilities(),
        settings = {
          workingDirectory = { mode = "location" },
          codeAction = {
            disableRuleComment = {
              enable = true,
              location = "separateLine"
            },
            showDocumentation = {
              enable = true
            }
          },
          quiet = true,  -- Suppress errors about missing plugins
          rulesCustomizations = {},
          run = "onType",
          validate = "on",
        },
        handlers = {
          -- Suppress diagnostic errors about missing plugins
          ["textDocument/publishDiagnostics"] = function(_, result, ctx, config)
            -- Filter out missing plugin errors
            if result.diagnostics then
              result.diagnostics = vim.tbl_filter(function(diagnostic)
                return not string.match(diagnostic.message or "", "Cannot find module 'eslint%-plugin%-")
              end, result.diagnostics)
            end
            vim.lsp.diagnostic.on_publish_diagnostics(_, result, ctx, config)
          end,
        },
      })
    end,

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

    -- SourceKit-LSP for Swift and C-family languages
    sourcekit_lsp = function()
      require('lspconfig').sourcekit_lsp.setup({
        on_attach = lsp_zero.on_attach,
        capabilities = lsp_zero.get_capabilities(),
        filetypes = { 'swift', 'c', 'cpp', 'objective-c', 'objective-cpp' },
      })
    end,
  }
})

