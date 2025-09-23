# ------------------------------
# ZSH Configuration (Optimized)
# ------------------------------

# Path to oh-my-zsh installation
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"

# Minimal plugin set for performance
plugins=(git z)

source $ZSH/oh-my-zsh.sh

# ------------------------------
# Core Settings
# ------------------------------

# Editor
export EDITOR='nvim'
export VISUAL='nvim'

# History
HISTSIZE=10000
SAVEHIST=10000
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE

# ------------------------------
# Path Configuration
# ------------------------------

# Function to add to PATH only if directory exists
add_to_path() {
  [ -d "$1" ] && export PATH="$1:$PATH"
}

# Add paths conditionally
add_to_path "/opt/homebrew/opt/openjdk@17/bin"
add_to_path "$HOME/Library/Android/sdk/platform-tools"
add_to_path "$HOME/.lmstudio/bin"
add_to_path "/opt/homebrew/bin"
add_to_path "/usr/local/bin"

# ------------------------------
# Lazy Loading Functions
# ------------------------------

# Lazy load NVM (significantly improves startup time)
lazy_load_nvm() {
  unset -f node npm npx nvm
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"
  [ -s "$NVM_DIR/bash_completion" ] && source "$NVM_DIR/bash_completion"
}

# Create placeholder functions that load NVM on first use
node() { lazy_load_nvm && node "$@" }
npm() { lazy_load_nvm && npm "$@" }
npx() { lazy_load_nvm && npx "$@" }
nvm() { lazy_load_nvm && nvm "$@" }

# Lazy load thefuck
if command -v thefuck >/dev/null 2>&1; then
  fuck() {
    unset -f fuck
    eval "$(thefuck --alias)"
    fuck "$@"
  }
fi

# Lazy load Angular CLI completion
ng() {
  unset -f ng
  source <(ng completion script 2>/dev/null)
  ng "$@"
}

# ------------------------------
# FZF Configuration
# ------------------------------

# Load FZF if available (single source)
if [ -f ~/.fzf.zsh ]; then
  source ~/.fzf.zsh
elif command -v fzf >/dev/null 2>&1; then
  # Try brew installation
  FZF_PREFIX="$(brew --prefix 2>/dev/null)/opt/fzf"
  if [ -d "$FZF_PREFIX" ]; then
    [ -f "$FZF_PREFIX/shell/key-bindings.zsh" ] && source "$FZF_PREFIX/shell/key-bindings.zsh"
    [ -f "$FZF_PREFIX/shell/completion.zsh" ] && source "$FZF_PREFIX/shell/completion.zsh"
  fi
fi

# FZF configuration
export FZF_DEFAULT_COMMAND='rg --files --hidden --follow --glob "!.git/*"'
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'

# ------------------------------
# Aliases
# ------------------------------

# Editor aliases
alias vi='nvim'
alias vim='nvim'
alias view='nvim -R'
alias vimdiff='nvim -d'
alias vf='nvim $(fzf)'

# Dotfiles shortcuts
alias tdot='tmux new-session -s dotfiles -c ~/dotfiles'
alias vdot='cd ~/dotfiles && vim .'

# Git aliases (using functions for better performance)
gcof() { git checkout $(git branch --format='%(refname:short)' | fzf); }
glogf() { git log --oneline --decorate --graph | fzf; }

# Utility aliases
alias cat='bat'
alias ls='ls --color=auto'
alias ll='ls -lah'
alias la='ls -A'
alias l='ls -CF'

# Reload configuration
alias reload='source ~/.zshrc'

# Auto-sudo last command
alias please='sudo $(fc -ln -1)'

# ------------------------------
# ZSH Enhancements (Conditional)
# ------------------------------

# Load autosuggestions if available
[ -f /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh ] && \
  source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# Load syntax highlighting if available (should be last)
[ -f /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ] && \
  source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# ------------------------------
# Performance Monitoring (Optional)
# ------------------------------

# Uncomment to debug slow startup
# zmodload zsh/zprof  # At the top of .zshrc
# zprof  # At the bottom of .zshrc