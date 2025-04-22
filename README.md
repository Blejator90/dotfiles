# 🛠 Dotfile setup

This repository contains my personal development environment setup. It includes:

- Zsh configuration (Oh My Zsh + plugins)
- Neovim config (Lua-based, Treesitter, LSP, Packer)
- Brewfile with curated tools and extensions
- VS Code extensions
- Shell aliases, tools, and developer CLI integrations

---

## 🚀 Setup Instructions

### 1. Clone the repo

```bash
git clone https://github.com/Blejator90/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

### 2. Run the install script

```bash
chmod +x install.sh
./install.sh
```

This will:
- Install Homebrew (if missing)
- Install all packages, casks, and VSCode extensions from `Brewfile`
- Create symlinks for:
  - `~/.zshrc`
  - `~/.gitconfig`
  - `~/.config/nvim`
- Set up fzf integration (keybindings + completions)
- Reload your Zsh shell

---

## 📁 Folder Structure

```
dotfiles/
├── install.sh           # Main setup script
├── Brewfile             # Homebrew + cask + VSCode package list
├── zsh/
│   └── .zshrc           # Zsh config
├── git/
│   └── .gitconfig       # Git identity + aliases
├── nvim/                # Neovim config
│   ├── init.lua
│   ├── lua/naz/         # Settings, remaps, packer, etc.
│   └── after/plugin/    # Plugin-specific config (e.g. treesitter, telescope, etc.)
```

---

## ⚙️ Included Tools

### Shell
- Zsh
- Oh My Zsh
- `fzf`, `bat`, `ripgrep`, `thefuck`
- Syntax highlighting and autosuggestions

### Editor (Neovim)
- Treesitter (syntax parsing)
- LSP (language server support)
- Telescope (fuzzy finder)
- Packer (plugin manager)
- Custom Lua config split across logical modules

### Homebrew
- CLI tools: `cmake`, `gcc`, `pre-commit`, `nvm`, `python`, etc.
- iOS dev: `cocoapods`, `fastlane`, `swiftlint`, `swiftformat`
- Visuals: `zsh-autosuggestions`, `zsh-syntax-highlighting`
- Others: `git-lfs`, `docker-compose`, `neovim`, `jenv`

### VS Code Extensions
- Docker, Python, Astro, OpenAI ChatGPT, GitHub themes, C++ tools

---

## 🤔 Notes & Tips

- You can run the install script multiple times — it's safe and idempotent
- `fzf` includes:
  - `Ctrl-R`: fuzzy history
  - `Alt-C`: jump to directory
- Aliases like `gcof`, `glogf`, `gsd` improve Git workflow

---

## 🔒 Optional Enhancements

- Add `zoxide` for smarter folder jumping
- Use `yq` for YAML editing
- Setup `tmux` with auto-resume and plugins

---

## ✅ License

MIT — use, fork, or adapt freely.

---
