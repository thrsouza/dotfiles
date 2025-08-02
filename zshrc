# Created by Thiago Souza (thrsouza)
# https://github.com/thrsouza/dotfiles

# ------------------------------------------------------------
# GO Paths
# ------------------------------------------------------------

export GOPATH=$HOME/go
export PATH=$GOPATH/bin:$PATH

# ------------------------------------------------------------
# Aliases
# ------------------------------------------------------------

alias ll='ls -alF'

alias gs='git status'
alias gc='git commit -m'
alias gb='git branch'
alias gl='git log --oneline --graph --decorate'

alias borabora="brew update; brew upgrade; brew upgrade --cask; brew cleanup --prune=all"
