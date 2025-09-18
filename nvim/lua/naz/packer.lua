-- Load Packer if it's installed as optional
vim.cmd [[packadd packer.nvim]]

-- Start plugin setup
return require('packer').startup(function(use)

  -----------------------------------------------------------
  -- Packer can manage itself
  -----------------------------------------------------------
  use 'wbthomason/packer.nvim'

  -----------------------------------------------------------
  -- Telescope (fuzzy finder)
  -----------------------------------------------------------
  use {
    'nvim-telescope/telescope.nvim',
    tag = '0.1.8',
    requires = { 'nvim-lua/plenary.nvim' }  -- Required dependency
  }

  -----------------------------------------------------------
  -- Rose Pine theme
  -----------------------------------------------------------
  use {
    'rose-pine/neovim',
    as = 'rose-pine',
    config = function()
      vim.cmd('colorscheme rose-pine')
    end
  }

  -----------------------------------------------------------
  -- Treesitter (syntax highlighting engine)
  -----------------------------------------------------------
  use {
    'nvim-treesitter/nvim-treesitter',
    run = ':TSUpdate' -- Automatically update parsers
  }

  -----------------------------------------------------------
  -- Auto-close parenthesis
  -----------------------------------------------------------
  use {
    'windwp/nvim-autopairs',
    config = function()
        require("nvim-autopairs").setup {}
    end
  }

  -----------------------------------------------------------
  -- UndoTree (visual undo history)
  -----------------------------------------------------------
  use 'mbbill/undotree'

  -----------------------------------------------------------
  -- Wakatime (time tracking)
  -----------------------------------------------------------
  use 'wakatime/vim-wakatime'

  -----------------------------------------------------------
  -- Modern TypeScript/Testing Tools
  -----------------------------------------------------------
  -- Enhanced test runner with real-time feedback
  use {
    'nvim-neotest/neotest',
    requires = {
      'nvim-lua/plenary.nvim',
      'nvim-treesitter/nvim-treesitter',
      'antoinemadec/FixCursorHold.nvim',
      'nvim-neotest/nvim-nio', -- Required dependency
      'nvim-neotest/neotest-jest', -- Jest adapter
      'mmllr/neotest-swift-testing', -- Swift Testing adapter
    }
  }

  -- Modern formatting engine
  use {
    'stevearc/conform.nvim',
    config = function()
      require("conform").setup({})
    end
  }

  -- Async linting (complements LSP)
  use 'mfussenegger/nvim-lint'

  -----------------------------------------------------------
  -- Which-key (keybinding helper)
  -----------------------------------------------------------
  use {
    'folke/which-key.nvim',
    config = function()
      require("which-key").setup {}
    end
  }

  -----------------------------------------------------------
  -- LSP & Autocompletion (lsp-zero preset)
  -----------------------------------------------------------
  use {
    'VonHeikemen/lsp-zero.nvim',
    branch = 'v3.x',
    requires = {

      -- LSP server manager
      { 'williamboman/mason.nvim' },
      { 'williamboman/mason-lspconfig.nvim' },

      -- Native LSP client
      { 'neovim/nvim-lspconfig' },

      -- Autocompletion plugins
      { 'hrsh7th/nvim-cmp' },
      { 'hrsh7th/cmp-nvim-lsp' },

      -- Snippet engine
      { 'L3MON4D3/LuaSnip' },
    }
  }

end)
