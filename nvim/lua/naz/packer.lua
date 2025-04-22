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
    tag = '0.1.4',
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
  -- UndoTree (visual undo history)
  -----------------------------------------------------------
  use 'mbbill/undotree'

  -----------------------------------------------------------
  -- Wakatime (time tracking)
  -----------------------------------------------------------
  use 'wakatime/vim-wakatime'

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
