# Path to oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="robbyrussell"

# ------------------------------
# Oh My Zsh Plugins
# ------------------------------
#

plugins=(
  git z fzf
)

source $ZSH/oh-my-zsh.sh

# ------------------------------
# User Configuration
# ------------------------------

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='nvim'
fi

# ------------------------------
# NVIM Shortcuts
# ------------------------------
alias vi="nvim"
alias vim="nvim"
alias view="nvim -R"
alias vimdiff="nvim -d"
alias vf='nvim $(fzf)'

# ------------------------------
# Java (OpenJDK 17)
# ------------------------------
export PATH="/opt/homebrew/opt/openjdk@17/bin:$PATH"

# ------------------------------
# Android ADB
# ------------------------------
export PATH=$PATH:/Users/nebojsanadj/Library/Android/sdk/platform-tools/

# ------------------------------
# Embedded Swift Toolchain
# ------------------------------
export TOOLCHAINS=$(plutil -extract CFBundleIdentifier raw /Library/Developer/Toolchains/swift-latest.xctoolchain/Info.plist)

# ------------------------------
# Node Version Manager
# ------------------------------
export NVM_DIR=~/.nvm
[ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"

# ------------------------------
# FZF Integration
# ------------------------------
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
source "$(brew --prefix)/opt/fzf/shell/key-bindings.zsh"
source "$(brew --prefix)/opt/fzf/shell/completion.zsh"

# ------------------------------
# Git Aliases and Fuzzy Branch Checkout
# ------------------------------

# - naive approach - alias gcof='git checkout $(git branch | fzf)'
# git checkout fzf
alias gcof='git checkout $(git branch --color=never | sed "s/^..//" | fzf)'
# git log fzf
alias glogf='git log --oneline --decorate --graph | fzf'
# git pretty staged diff
alias gsd='git diff --cached | bat -l diff'

# auto-sudo
alias please='sudo $(fc -ln -1)'

# ------------------------------
# ZSH - Auto suggestions
# ------------------------------
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# ------------------------------
# Bat (Modern cat)
# ------------------------------
alias cat='bat'

# ------------------------------
# Reload shell config
# ------------------------------
alias reload='source ~/.zshrc'

# ------------------------------
# TheFuck (auto-correct mistyped commands)
# ------------------------------
eval "$(thefuck --alias)"

# ------------------------------
# Quiet login (optional)
# ------------------------------
# touch ~/.hushlogin  # [See below]
