# .config/fish/config.fish

if status is-interactive
    # Commands to run in interactive sessions can go here
end

set SPACESHIP_PROMPT_ADD_NEWLINE false

starship init fish | source

# ------------------------------------------------------------
# Paths
# ------------------------------------------------------------

# Go
set -x GOPATH $HOME/go
fish_add_path $GOPATH/bin

# Cargo / Rust
fish_add_path $(brew --prefix rustup)/bin

# Local
fish_add_path $HOME/.local/bin

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

fzf --fish | source

export FZF_DEFAULT_OPTS="
  --style full
  --preview 'bat --color=always {}'"
