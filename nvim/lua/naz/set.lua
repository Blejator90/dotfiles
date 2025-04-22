-- Line Numbers
vim.opt.nu = true                 -- Show absolute line numbers
vim.opt.relativenumber = true     -- Show relative line numbers (except current line)

-- Indentation
vim.opt.tabstop = 4               -- A tab character is 4 spaces wide
vim.opt.softtabstop = 4           -- When hitting tab/backspace, use 4 spaces
vim.opt.shiftwidth = 4            -- Indent by 4 spaces when using >>
vim.opt.expandtab = true          -- Convert tabs to spaces
vim.opt.smartindent = true        -- Smart auto-indenting on new lines

-- Text Display
vim.opt.wrap = false              -- Disable line wrap (scroll horizontally)

-- Search
vim.opt.hlsearch = false          -- Don't highlight matches after search
vim.opt.incsearch = true          -- Show matches while typing the search

-- Appearance
vim.opt.termguicolors = true      -- Enable true color support
vim.opt.scrolloff = 8             -- Keep 8 lines visible above/below cursor
vim.opt.signcolumn = "yes"        -- Always show the sign column (gutter)
vim.opt.colorcolumn = "80"        -- Highlight column 80 (coding style guide)

-- Performance
vim.opt.updatetime = 50           -- Lower update time (for CursorHold/LSP events)

-- Window Management
vim.opt.splitright = true         -- Vertical splits open to the right
vim.opt.splitbelow = true         -- Horizontal splits open below

-- Leader key
vim.g.leader = " "                -- Set <leader> to Space
