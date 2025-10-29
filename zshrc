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

# Java
export JAVA_HOME=$(/usr/libexec/java_home) # export JAVA_HOME=$(/usr/libexec/java_home -v 25)
export PATH=$JAVA_HOME/bin:$PATH
export CPPFLAGS="-I/opt/homebrew/opt/openjdk/include"

# ------------------------------------------------------------
# Aliases
# ------------------------------------------------------------

alias ll='ls -alF'

alias gs='git status'
alias gc='git commit -m'
alias gb='git branch'
alias gl='git log --oneline --graph --decorate'

alias bora="brew update; brew upgrade; brew upgrade --cask; brew cleanup --prune=all"
