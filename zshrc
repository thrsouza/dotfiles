# ~/.zshrc

# Created by Thiago Souza (thrsouza)
# https://github.com/thrsouza/dotfiles

# ------------------------------------------------------------
# GPG Agent
# ------------------------------------------------------------

export GPG_TTY=$(tty)
gpg-connect-agent updatestartuptty /bye >/dev/null 2>&1

# ------------------------------------------------------------
# Paths
# ------------------------------------------------------------

# Go
export GOPATH="$HOME/go"
export PATH="$GOPATH/bin:$PATH"

# Rust
export PATH="$(brew --prefix rustup)/bin:$PATH"

# Cargo
export PATH="$HOME/.cargo/bin:$PATH"

# Local
export PATH="$HOME/.local/bin:$PATH"

# ------------------------------------------------------------
# Aliases
# ------------------------------------------------------------

alias ll='ls -alF'

alias gs='git status'
alias gc='git commit -m'
alias gb='git branch'
alias gl='git log --oneline --graph --decorate'

alias borabora="brew update; brew upgrade; brew upgrade --cask; brew cleanup --prune=all"

# ------------------------------------------------------------
# Fzf
# ------------------------------------------------------------

eval "$(fzf --zsh)"

export FZF_DEFAULT_OPTS="
  --style full
  --preview 'bat --color=always {}'"
