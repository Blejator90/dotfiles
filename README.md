# Personal Dotfiles

A modern, performant development environment configuration for macOS focusing on terminal-based workflows with Neovim, Zsh, and development tooling.

## Overview

This dotfiles repository provides a complete development environment setup optimized for:
- **Web Development** (TypeScript/JavaScript, React, Node.js)
- **Systems Programming** (Rust, C/C++)
- **Python Development**
- **General Text Editing** and productivity

## Architecture

### Package Manager Migration: Packer → Lazy.nvim

This configuration recently migrated from Packer to **Lazy.nvim** for better performance and modern plugin management:

- **Old**: `nvim/after/plugin/*` - Individual plugin configs loaded at startup
- **New**: `nvim/lua/naz/plugins/` - Lazy-loaded modular plugin specifications
- **Result**: Faster startup times and better resource management

### Core Components

```
dotfiles/
├── nvim/                    # Neovim configuration
│   ├── init.lua            # Entry point, loads core modules
│   ├── lua/naz/            # Personal configuration modules
│   │   ├── set.lua         # Core Neovim settings
│   │   ├── remap.lua       # Key mappings
│   │   ├── diagnostics.lua # LSP diagnostics configuration
│   │   ├── lsp.lua         # Language Server Protocol setup
│   │   ├── cmp.lua         # Autocompletion configuration
│   │   ├── lazy-init.lua   # Lazy.nvim bootstrap
│   │   └── plugins/        # Plugin specifications
│   │       └── init.lua    # All plugin definitions
│   └── lazy-lock.json      # Plugin version lockfile
├── zsh/
│   └── .zshrc             # Zsh configuration with performance optimizations
├── git/                   # Git configuration
├── Brewfile              # macOS package dependencies
└── install.sh           # Setup script
```

## Neovim Configuration

### Plugin Management (Lazy.nvim)

**Why Lazy.nvim?**
- **Performance**: Plugins load only when needed
- **Modern**: Better dependency management and configuration
- **Maintainable**: Clear plugin specifications with lazy-loading rules

**Key Features:**
- Event-based loading (on file type, command, keypress)
- Automatic dependency resolution
- Built-in profiling and health checks
- Lock file for reproducible installs

### Language Support

#### LSP (Language Server Protocol)
Configured LSPs for comprehensive language support:

- **TypeScript/JavaScript**: `ts_ls` with auto-import organization
- **Python**: `pyright` for type checking
- **Rust**: `rust_analyzer` with advanced features
- **C/C++**: `clangd` with compilation database support
- **Lua**: `lua_ls` configured for Neovim development

**LSP Features:**
- Go-to-definition (`gd`)
- Hover documentation (`K`)
- Code actions (`<leader>vca`)
- Workspace symbols (`<leader>vws`)
- Rename refactoring (`<leader>vrn`)

#### Autocompletion (nvim-cmp)
Smart completion system with multiple sources:
- LSP completions
- File path completions
- Buffer word completions
- Snippet support (LuaSnip)

#### Formatting & Linting

**Conform.nvim** for formatting:
- Format on save for supported file types
- Async formatting to prevent blocking
- Fallback to LSP formatting when formatters unavailable

**nvim-lint** for additional linting:
- ESLint for JavaScript/TypeScript
- Pylint for Python
- Conditional loading - only runs if linters are installed

### Code Navigation & Search

**Telescope.nvim** - Fuzzy finder with FZF integration:
- `<leader>ff` - Find files
- `<leader>fg` - Live grep across project
- `<leader>fb` - Open buffers
- `<leader>fh` - Help tags

**Treesitter** - Advanced syntax highlighting:
- Context-aware highlighting
- Better code folding
- Improved text objects

### Development Tools

**Testing Integration**:
- **Neotest** with Jest adapter
- Visual test running and results
- `<leader>tn` - Run nearest test
- `<leader>tf` - Run file tests
- `<leader>ta` - Run all tests

**Code Quality**:
- Real-time diagnostics display
- Automatic import organization (TypeScript)
- Format on save (configurable per file type)
- Integration with external linters

### UI & Theme

**Catppuccin Theme**:
- Modern, low-contrast colorscheme
- Consistent across all plugins
- Terminal transparency support

**Lualine Status Line**:
- Clean, informative status bar
- Git integration
- LSP status indicators

## Zsh Configuration

### Performance Optimizations

The Zsh setup prioritizes **fast shell startup** through lazy loading:

**Lazy Loading Strategies:**
```bash
# NVM (Node Version Manager) - loads only when needed
node() { lazy_load_nvm && node "$@" }
npm() { lazy_load_nvm && npm "$@" }

# Angular CLI - loads completion on first use
ng() { unset -f ng; source <(ng completion script); ng "$@" }

# thefuck - aliases only when used
fuck() { unset -f fuck; eval "$(thefuck --alias)"; fuck "$@" }
```

**Path Management**:
- Conditional PATH additions (only if directories exist)
- Prioritized tool locations (Homebrew, local bins)

**Development Aliases**:
- `vi`, `vim` → `nvim`
- `cat` → `bat` (with fallback)
- `vf` - Edit file selected with fzf
- `vdot` - Quick dotfiles editing

### Git Integration

**FZF-powered Git functions**:
- `gcof()` - Checkout branch with fuzzy search
- `glogf()` - Browse git log with fzf
- `gsd()` - Staged diff with syntax highlighting

## Development Workflow

### Project Setup

1. **LSP automatically detects** project type and configures appropriate language server
2. **Mason** manages LSP server installations
3. **Formatters and linters** activate based on available tools
4. **Project-specific settings** via `.editorconfig` or LSP workspace settings

### Typical Workflow

1. **Navigate**: `<leader>ff` to find files, `<leader>fg` to search code
2. **Edit**: Full LSP support with go-to-definition, hover docs, autocompletion
3. **Test**: `<leader>tn` for nearest test, integrated results display
4. **Format**: Automatic on save, or manual with `<leader>f`
5. **Debug**: LSP diagnostics show errors inline, `:LspLog` for troubleshooting

### Key Mappings Summary

**File Operations:**
- `<leader>ff` - Find files
- `<leader>fg` - Live grep
- `<leader>fb` - Buffers
- `<leader>u` - Undo tree

**LSP Operations:**
- `gd` - Go to definition
- `K` - Hover documentation
- `<leader>vca` - Code actions
- `<leader>vrn` - Rename symbol
- `[d` / `]d` - Navigate diagnostics

**Testing:**
- `<leader>tn` - Run nearest test
- `<leader>tf` - Run file tests
- `<leader>ts` - Test summary

## Installation

### Prerequisites

```bash
# Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install core dependencies
brew install neovim git fzf ripgrep bat jq
```

### Setup

```bash
# Clone dotfiles
git clone https://github.com/your-username/dotfiles ~/.dotfiles
cd ~/.dotfiles

# Run installation script
./install.sh

# Install development tools
brew bundle
```

### Post-Installation

1. **Open Neovim**: First launch will automatically install plugins
2. **LSP Setup**: Run `:Mason` to install language servers
3. **Health Check**: `:checkhealth` to verify everything works
4. **Customize**: Edit `nvim/lua/naz/` files for personal preferences

## Troubleshooting

### Common Issues

**Slow Startup:**
- Check `:Lazy profile` for plugin load times
- Verify FZF and other tools are installed
- Consider disabling unused language servers

**LSP Not Working:**
- `:LspInfo` to check active clients
- `:Mason` to install missing servers
- `:LspLog` to check for errors

**Plugin Issues:**
- `:Lazy sync` to update plugins
- `:Lazy clean` to remove unused plugins
- Check `lazy-lock.json` for version conflicts

### Performance Monitoring

```vim
" Neovim startup time
:Lazy profile

" LSP performance
:LspInfo

" General health
:checkhealth
```

## Customization

### Adding New Languages

1. **Add LSP server** in `lua/naz/lsp.lua`
2. **Configure formatter** in `lua/naz/plugins/init.lua` (conform.nvim)
3. **Add linter** in `lua/naz/plugins/init.lua` (nvim-lint)
4. **Install tools** via `:Mason` or add to `Brewfile`

### Personal Keymaps

Edit `lua/naz/remap.lua` for custom key bindings. The configuration uses `<leader>` (space) as the primary prefix.

### Theme Customization

Modify the Catppuccin setup in `lua/naz/plugins/init.lua` or switch to a different theme by changing the plugin specification.

## Philosophy

This configuration balances:
- **Performance** (fast startup, lazy loading)
- **Functionality** (comprehensive language support)
- **Maintainability** (modular, well-documented)
- **Flexibility** (easy to customize and extend)

The goal is a development environment that gets out of your way while providing powerful tools when needed.
