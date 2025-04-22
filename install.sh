#!/bin/bash

set -e

DOTFILES="$HOME/dotfiles"

echo "🛠 Starting dotfiles setup..."

# -----------------------------
# Step 1: Install Homebrew (if not already installed)
# -----------------------------
if ! command -v brew &>/dev/null; then
  echo "🍺 Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# -----------------------------
# Step 2: Install Brew packages from Brewfile
# -----------------------------
echo "🍺 Installing packages from Brewfile..."
brew bundle --file="$DOTFILES/Brewfile"

# -----------------------------
# Step 3: Symlink dotfiles
# -----------------------------
echo "🔗 Creating symlinks..."

ln -sfn "$DOTFILES/zsh/.zshrc" "$HOME/.zshrc"
ln -sfn "$DOTFILES/git/.gitconfig" "$HOME/.gitconfig"
ln -sfn "$DOTFILES/nvim" "$HOME/.config/nvim"

# -----------------------------
# Step 4: Setup fzf integration
# -----------------------------
echo "⚙️ Setting up fzf..."
"$(brew --prefix)/opt/fzf/install" --all

# -----------------------------
# Step 5: Ensure Neovim plugin directory exists
# -----------------------------
mkdir -p ~/.local/share/nvim/site/pack/packer/start


# -----------------------------
# Step 6: FZF setup with real zshrc location
# -----------------------------
echo "Setting up fzf with zshrc"
FZF_LINE='[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh'
ZSHRC="$HOME/.zshrc"

if ! grep -Fxq "$FZF_LINE" "$ZSHRC"; then
  echo "🔧 Adding fzf sourcing line to .zshrc..."
  echo "$FZF_LINE" >> "$ZSHRC"
fi

# -----------------------------
# Step 7: Reload zsh
# -----------------------------
echo "🔁 Reloading zsh..."
exec zsh
