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
  return 0
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
# Git Worktree Management
# ------------------------------
# Bash-compatible functions for managing git worktrees
#
# Usage:
#   wtadd <branch-name> [base|--pb] - Create worktree, optionally from base branch
#   wtfetch <remote-branch>         - Fetch and create worktree for remote branch
#   wtls [--git|--gs]               - List all worktrees (--git shows status indicators)
#   wtrm [branch-name|--all]        - Delete worktree and branch (--all removes all)
#   wtcd                            - Interactive fzf picker to switch between worktrees
#
# Examples:
#   wtadd fix/issue-123           # From current branch
#   wtadd fix/issue-123 main      # From main (fetch + pull first)
#   wtadd fix/issue-123 --pb      # Pick base branch with fzf
#   wtfetch colleague/feature-x   # Fetch remote branch for PR review
#   wtls --git                    # List with git status (✗=dirty, ↑=ahead, ↓=behind, ⇕=diverged)
#   wtrm                          # Delete current worktree
#   wtrm --all                    # Delete all worktrees
#   wtcd                          # Switch between worktrees
#
# Note: Works from anywhere in the repo (main or any worktree)
# Compatible with both zsh and bash - copy to ~/.bashrc for bash users

# Helper: Convert branch name to directory-safe name (slashes to dashes)
_wt_dir_name() {
  echo "${1//\//-}"
}

# Helper: Get the main worktree path
_wt_main_path() {
  git worktree list | head -1 | awk '{print $1}'
}

# Helper: Get worktree directory path for a branch
_wt_get_path() {
  local branch_name="$1"
  local main_worktree=$(_wt_main_path)
  local project_name=$(basename "$main_worktree")
  local dir_name=$(_wt_dir_name "$branch_name")
  echo "$(dirname $main_worktree)/${project_name}-worktrees/$dir_name"
}

# Helper: Resolve base branch to git ref (checks remote first, then local)
_wt_resolve_base() {
  local base_branch="$1"

  # Fetch from remote
  git fetch origin "$base_branch" 2>/dev/null

  # Check remote first (preferred - always fresh)
  if git show-ref --verify --quiet "refs/remotes/origin/$base_branch"; then
    echo "origin/$base_branch"
    return 0
  fi

  # Fallback to local
  if git show-ref --verify --quiet "refs/heads/$base_branch"; then
    echo "$base_branch"
    return 0
  fi

  # Not found
  return 1
}

# Helper: Print green text
_wt_green() {
  echo -e "\033[0;32m$1\033[0m"
}

# Helper: Get git status indicator for a worktree
_wt_git_status() {
  local wt_path="$1"
  cd "$wt_path" 2>/dev/null || return

  local git_status=$(git status --porcelain 2>/dev/null)
  local ahead_behind=$(git rev-list --left-right --count HEAD...@{upstream} 2>/dev/null)

  if [ -n "$git_status" ]; then
    # Dirty: changes present
    echo "✗"
  elif [ -n "$ahead_behind" ]; then
    local ahead=$(echo $ahead_behind | awk '{print $1}')
    local behind=$(echo $ahead_behind | awk '{print $2}')
    if [ "$ahead" -gt 0 ] && [ "$behind" -gt 0 ]; then
      echo "⇕"  # Diverged
    elif [ "$ahead" -gt 0 ]; then
      echo "↑"  # Ahead
    elif [ "$behind" -gt 0 ]; then
      echo "↓"  # Behind
    fi
  fi
  # Clean: return empty (no indicator)
}

wtadd() {
  if [ -z "$1" ]; then
    echo "Usage: wtadd <branch-name> [base-branch|--pb]"
    return 1
  fi

  local branch_name=""
  local base_ref=""
  local use_picker=false

  # Parse arguments - handle --pb in any position
  if [ "$1" = "--pb" ]; then
    use_picker=true
    branch_name="$2"
  elif [ "$2" = "--pb" ]; then
    branch_name="$1"
    use_picker=true
  else
    branch_name="$1"
  fi

  # Validate branch name
  if [ -z "$branch_name" ]; then
    echo "Error: branch name required"
    echo "Usage: wtadd <branch-name> [base-branch|--pb]"
    return 1
  fi

  # Handle base branch selection
  if [ "$use_picker" = true ]; then
    # Use fzf to pick base branch
    local base_branch=$(git branch --format='%(refname:short)' | fzf --prompt="Select base branch: ")
    if [ -z "$base_branch" ]; then
      echo "No base branch selected"
      return 1
    fi

    # Resolve to git ref (remote or local)
    base_ref=$(_wt_resolve_base "$base_branch")
    if [ $? -ne 0 ]; then
      echo "Branch not found: $base_branch (checked remote and local)"
      return 1
    fi
    echo "Using branch: $base_ref"
  elif [ -n "$2" ] && [ "$2" != "--pb" ]; then
    # Explicit base branch provided
    local base_branch="$2"

    # Resolve to git ref (remote or local)
    base_ref=$(_wt_resolve_base "$base_branch")
    if [ $? -ne 0 ]; then
      echo "Branch not found: $base_branch (checked remote and local)"
      return 1
    fi
    echo "Using branch: $base_ref"
  fi

  local worktree_dir=$(_wt_get_path "$branch_name")
  local main_worktree=$(_wt_main_path)

  # Check if directory already exists
  if [ -d "$worktree_dir" ]; then
    echo "Worktree directory already exists: $worktree_dir"
    return 1
  fi

  mkdir -p "$(dirname $worktree_dir)"

  # Check if branch already exists locally
  if git show-ref --verify --quiet "refs/heads/$branch_name"; then
    echo "Creating worktree for existing branch '$branch_name'"
    git worktree add "$worktree_dir" "$branch_name" && cd "$worktree_dir"
  else
    if [ -n "$base_ref" ]; then
      _wt_green "Creating worktree and new branch '$branch_name' from '$base_ref'"
      git worktree add "$worktree_dir" -b "$branch_name" "$base_ref" && cd "$worktree_dir"
    else
      _wt_green "Creating worktree and new branch '$branch_name'"
      git worktree add "$worktree_dir" -b "$branch_name" && cd "$worktree_dir"
    fi
  fi
}

wtfetch() {
  if [ -z "$1" ]; then
    echo "Usage: wtfetch <remote-branch>"
    return 1
  fi

  local branch_name="$1"
  local remote_branch="origin/$branch_name"

  # Fetch latest from remote
  git fetch origin "$branch_name" 2>/dev/null

  # Check if remote branch exists
  if ! git show-ref --verify --quiet "refs/remotes/$remote_branch"; then
    echo "Remote branch not found: $remote_branch"
    return 1
  fi

  local worktree_dir=$(_wt_get_path "$branch_name")

  if [ -d "$worktree_dir" ]; then
    echo "Worktree already exists: $worktree_dir"
    return 1
  fi

  mkdir -p "$(dirname $worktree_dir)"
  echo "Fetching and creating worktree for remote branch '$branch_name'"
  git worktree add "$worktree_dir" -b "$branch_name" --track "$remote_branch" && cd "$worktree_dir"
}

wtls() {
  local main_worktree=$(_wt_main_path)
  local project_name=$(basename "$main_worktree")
  local worktree_base="$(dirname $main_worktree)/${project_name}-worktrees"
  local current_dir=$(pwd)
  local show_git_status=false

  # Check for --git or --gs flag
  if [ "$1" = "--git" ] || [ "$1" = "--gs" ]; then
    show_git_status=true
  fi

  # Show main with indicator if current
  local main_prefix="  "
  if [ "$current_dir" = "$main_worktree" ]; then
    main_prefix="* "
  fi

  if [ "$show_git_status" = true ]; then
    local wt_status=$(_wt_git_status "$main_worktree")
    if [ "$current_dir" = "$main_worktree" ]; then
      _wt_green "$main_prefix$project_name [original] $wt_status"
    else
      echo "$main_prefix$project_name [original] $wt_status"
    fi
  else
    if [ "$current_dir" = "$main_worktree" ]; then
      _wt_green "$main_prefix$project_name [original]"
    else
      echo "$main_prefix$project_name [original]"
    fi
  fi

  # Show worktrees with indicator if current
  if [ -d "$worktree_base" ]; then
    for wt in "$worktree_base"/*; do
      if [ -d "$wt" ]; then
        local wt_name=$(basename "$wt")
        local wt_prefix="  "
        if [ "$current_dir" = "$wt" ]; then
          wt_prefix="* "
        fi

        if [ "$show_git_status" = true ]; then
          local wt_status=$(_wt_git_status "$wt")
          if [ "$current_dir" = "$wt" ]; then
            _wt_green "$wt_prefix$wt_name $wt_status"
          else
            echo "$wt_prefix$wt_name $wt_status"
          fi
        else
          if [ "$current_dir" = "$wt" ]; then
            _wt_green "$wt_prefix$wt_name"
          else
            echo "$wt_prefix$wt_name"
          fi
        fi
      fi
    done
  fi
}

wtcd() {
  local main_worktree=$(_wt_main_path)
  local project_name=$(basename "$main_worktree")
  local worktree_base="$(dirname $main_worktree)/${project_name}-worktrees"

  # Build list with main repo + worktrees
  local options="→ $project_name [original]\n"
  if [ -d "$worktree_base" ]; then
    options+=$(ls -1 "$worktree_base" 2>/dev/null | sed 's/^/  /')
  fi

  local selected=$(echo -e "$options" | fzf --prompt="Select worktree: ")

  # Strip prefixes and labels
  local selected_name="${selected#→ }"
  selected_name="${selected_name#  }"
  selected_name="${selected_name% \[original\]}"

  if [ "$selected_name" = "$project_name" ]; then
    cd "$main_worktree"
  elif [ -n "$selected_name" ]; then
    cd "$worktree_base/$selected_name"
  fi
}

wtrm() {
  local main_worktree=$(_wt_main_path)
  local current_dir=$(pwd)

  if [ "$1" = "--all" ]; then
    # Delete all worktrees
    local project_name=$(basename "$main_worktree")
    local worktree_base="$(dirname $main_worktree)/${project_name}-worktrees"

    if [ ! -d "$worktree_base" ]; then
      echo "No worktrees to remove"
      return 0
    fi

    echo "Removing all worktrees..."
    cd "$main_worktree"

    for wt in "$worktree_base"/*; do
      if [ -d "$wt" ]; then
        local wt_name=$(basename "$wt")
        echo "Removing: $wt_name"
        git worktree remove "$wt" 2>/dev/null || rm -rf "$wt"
      fi
    done

    git worktree prune
    echo "All worktrees removed"
    return 0
  fi

  if [ -z "$1" ]; then
    # No arg - delete current worktree
    if [ "$current_dir" = "$main_worktree" ]; then
      echo "Cannot delete main worktree"
      return 1
    fi

    local branch_name=$(git branch --show-current)
    cd "$main_worktree"
    git worktree remove "$current_dir" 2>/dev/null || rm -rf "$current_dir"
    git worktree prune
    git branch -d "$branch_name"
  else
    # Has arg - delete specified worktree
    local branch_name="$1"
    local worktree_dir=$(_wt_get_path "$branch_name")

    # Check if worktree exists
    if [ ! -d "$worktree_dir" ]; then
      echo "Worktree does not exist: $worktree_dir"
      return 1
    fi

    # If deleting current worktree, cd to main first
    if [ "$current_dir" = "$worktree_dir" ]; then
      cd "$main_worktree"
    fi

    git worktree remove "$worktree_dir" 2>/dev/null || rm -rf "$worktree_dir"
    git worktree prune
    git branch -d "$branch_name"
  fi
}

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
# Added by LM Studio CLI (lms)
export PATH="$PATH:/Users/nebojsanadj/.lmstudio/bin"
# End of LM Studio CLI section

