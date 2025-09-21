-- Lazy.nvim plugin specifications
return {
  -- Telescope (fuzzy finder)
  {
    'nvim-telescope/telescope.nvim',
    tag = '0.1.8',
    dependencies = { 'nvim-lua/plenary.nvim' },
    cmd = "Telescope",
    keys = {
      { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find Files" },
      { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Live Grep" },
      { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Buffers" },
      { "<leader>fh", "<cmd>Telescope help_tags<cr>", desc = "Help Tags" },
    },
  },

  -- Telescope FZF native for performance
  {
    'nvim-telescope/telescope-fzf-native.nvim',
    build = 'make',
    lazy = true,
    config = function()
      require('telescope').load_extension('fzf')
    end,
  },

  -- Git Fugitive
  {
    'tpope/vim-fugitive',
    cmd = { 'Git', 'G', 'Gdiffsplit', 'Gread', 'Gwrite', 'Ggrep', 'GMove', 'GDelete', 'GBrowse' },
    keys = {
      { "<leader>gs", "<cmd>Git<cr>", desc = "Git Status" },
      { "<leader>gc", "<cmd>Git commit<cr>", desc = "Git Commit" },
      { "<leader>gp", "<cmd>Git push<cr>", desc = "Git Push" },
      { "<leader>gl", "<cmd>Git log<cr>", desc = "Git Log" },
    },
  },

  -- Catppuccin theme
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()
      require("catppuccin").setup({
        flavour = "mocha",
        transparent_background = true,
        show_end_of_buffer = false,
        integrations = {
          cmp = true,
          telescope = true,
          treesitter = true,
          native_lsp = {
            enabled = true,
          },
        },
      })
      vim.cmd.colorscheme("catppuccin")

      -- Force transparency for all backgrounds
      vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
      vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
      vim.api.nvim_set_hl(0, "NormalNC", { bg = "none" })
      vim.api.nvim_set_hl(0, "LineNr", { bg = "none" })
      vim.api.nvim_set_hl(0, "SignColumn", { bg = "none" })
      vim.api.nvim_set_hl(0, "EndOfBuffer", { bg = "none" })
    end,
  },

  -- Lualine (status line)
  {
    'nvim-lualine/lualine.nvim',
    event = "VeryLazy",
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      require('lualine').setup({
        options = {
          theme = 'catppuccin',
          globalstatus = true,
        }
      })
    end,
  },

  -- Treesitter (syntax highlighting)
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      require('nvim-treesitter.configs').setup({
        -- Install parsers synchronously (only applied to `ensure_installed`)
        sync_install = false,

        -- List of parsers to ignore installing (or "all")
        ignore_install = {},

        -- Install parsers only when needed
        ensure_installed = {},
        auto_install = true,

        highlight = {
          enable = true,
          additional_vim_regex_highlighting = false,
        },
        indent = {
          enable = true,
        },
      })
    end,
  },

  -- Auto-pairs
  {
    'windwp/nvim-autopairs',
    event = "InsertEnter",
    config = true,
  },

  -- UndoTree
  {
    'mbbill/undotree',
    cmd = { 'UndotreeToggle', 'UndotreeShow' },
    keys = {
      { "<leader>u", "<cmd>UndotreeToggle<cr>", desc = "Toggle UndoTree" },
    },
  },

  -- Wakatime (time tracking)
  {
    'wakatime/vim-wakatime',
    event = "VeryLazy",
  },

  -- Modern test runner
  {
    'nvim-neotest/neotest',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-treesitter/nvim-treesitter',
      'antoinemadec/FixCursorHold.nvim',
      'nvim-neotest/nvim-nio',
      'nvim-neotest/neotest-jest',
      'mmllr/neotest-swift-testing',
    },
    cmd = { 'Neotest', 'NeotestRun', 'NeotestStop', 'NeotestSummary', 'NeotestOutput' },
    keys = {
      { "<leader>tn", function() require("neotest").run.run() end, desc = "Run nearest test" },
      { "<leader>tf", function() require("neotest").run.run(vim.fn.expand("%")) end, desc = "Run file tests" },
      { "<leader>ta", function() require("neotest").run.run(vim.fn.getcwd()) end, desc = "Run all tests" },
      { "<leader>ts", function() require("neotest").summary.toggle() end, desc = "Toggle summary" },
      { "<leader>to", function() require("neotest").output.open({ enter = true }) end, desc = "Open output" },
    },
    config = function()
      require("neotest").setup({
        adapters = {
          require("neotest-jest")({
            jestCommand = "npm test --",
            env = { CI = true },
          }),
          require("neotest-swift-testing"),
        },
      })
    end,
  },

  -- Formatting
  {
    'stevearc/conform.nvim',
    event = { "BufWritePre" },
    cmd = { "ConformInfo", "Format" },
    keys = {
      { "<leader>f", function() require("conform").format({ lsp_fallback = true, async = false, timeout_ms = 1000 }) end, mode = { "n", "v" }, desc = "Format" },
      { "<leader>F", function() require("conform").format({ lsp_fallback = true, async = true, timeout_ms = 2000 }) end, desc = "Format (async)" },
    },
    config = function()
      require("conform").setup({
        formatters_by_ft = {
          javascript = { "prettier" },
          typescript = { "prettier" },
          typescriptreact = { "prettier" },
          javascriptreact = { "prettier" },
          json = { "prettier" },
          html = { "prettier" },
          css = { "prettier" },
          markdown = { "prettier" },
          yaml = { "prettier" },
          c = { "clang-format" },
          cpp = { "clang-format" },
          swift = { "swiftformat" },
          python = { "black", "isort" },
          rust = { "rustfmt" },
          lua = { "stylua" },
        },
        format_on_save = function(bufnr)
          -- Disable autoformat on certain filetypes
          local ignore_filetypes = { "sql", "java" }
          if vim.tbl_contains(ignore_filetypes, vim.bo[bufnr].filetype) then
            return
          end
          return {
            timeout_ms = 500,
            lsp_fallback = true,
            async = false,
          }
        end,
      })
    end,
  },

  -- Linting
  {
    'mfussenegger/nvim-lint',
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local lint = require('lint')

      -- Function to check if linter exists
      local function setup_linter(filetype, linter)
        if vim.fn.executable(linter) == 1 then
          if not lint.linters_by_ft[filetype] then
            lint.linters_by_ft[filetype] = {}
          end
          table.insert(lint.linters_by_ft[filetype], linter)
        end
      end

      -- Setup linters only if they exist
      setup_linter('javascript', 'eslint_d')
      setup_linter('typescript', 'eslint_d')
      setup_linter('javascriptreact', 'eslint_d')
      setup_linter('typescriptreact', 'eslint_d')
      setup_linter('python', 'pylint')
      setup_linter('swift', 'swiftlint')

      -- Fallback to eslint if eslint_d not available
      if vim.fn.executable('eslint_d') == 0 and vim.fn.executable('eslint') == 1 then
        setup_linter('javascript', 'eslint')
        setup_linter('typescript', 'eslint')
        setup_linter('javascriptreact', 'eslint')
        setup_linter('typescriptreact', 'eslint')
      end

      vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
        group = vim.api.nvim_create_augroup("lint", { clear = true }),
        callback = function()
          local ft = vim.bo.filetype

          -- Only lint if we have a linter for this filetype
          if lint.linters_by_ft[ft] and #lint.linters_by_ft[ft] > 0 then
            -- Check if the linter actually exists before running
            local available_linters = {}
            for _, linter in ipairs(lint.linters_by_ft[ft]) do
              if vim.fn.executable(linter) == 1 then
                table.insert(available_linters, linter)
              end
            end

            if #available_linters > 0 then
              -- Run linting with error handling
              local ok, err = pcall(require("lint").try_lint)
              if not ok and err:match("ENOENT") then
                -- Show a helpful message for missing tools
                vim.notify(
                  string.format("Linter not found for %s. Install with: npm install -g eslint_d", ft),
                  vim.log.levels.WARN
                )
              elseif not ok then
                vim.notify("Linting error: " .. tostring(err), vim.log.levels.ERROR)
              end
            end
          end
        end,
      })
    end,
  },

  -- Which-key
  {
    'folke/which-key.nvim',
    event = "VeryLazy",
    config = true,
  },

  -- LSP Zero
  {
    'VonHeikemen/lsp-zero.nvim',
    branch = 'v3.x',
    lazy = true,
    config = false,
    init = function()
      -- Disable automatic setup, we prefer to do it manually
      vim.g.lsp_zero_extend_cmp = 0
      vim.g.lsp_zero_extend_lspconfig = 0
    end,
  },


  -- Mason
  {
    'williamboman/mason.nvim',
    lazy = false,
    config = true,
  },

  -- LSP Support
  {
    'neovim/nvim-lspconfig',
    cmd = { 'LspInfo', 'LspInstall', 'LspStart' },
    event = { 'BufReadPre', 'BufNewFile' },
    dependencies = {
      { 'hrsh7th/cmp-nvim-lsp' },
      { 'williamboman/mason-lspconfig.nvim' },
    },
    config = function()
      -- This is where we'll configure all LSP settings
      require('naz.lsp')
    end,
  },

  -- Autocompletion
  {
    'hrsh7th/nvim-cmp',
    event = 'InsertEnter',
    dependencies = {
      { 'L3MON4D3/LuaSnip' },
      { 'hrsh7th/cmp-path' },
      { 'hrsh7th/cmp-buffer' },
    },
    config = function()
      require('naz.cmp')
    end,
  },
}