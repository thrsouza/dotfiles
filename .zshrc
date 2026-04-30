# ~/.zshrc

# Created by Thiago Souza (thrsouza)
# https://github.com/thrsouza/dotfiles

# ------------------------------------------------------------
# Tmux
# ------------------------------------------------------------

# if [[ -z "$TMUX" ]] && [[ $- == *i* ]] && command -v tmux >/dev/null 2>&1; then
#   exec tmux new -A -s default
# fi

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
export JAVA_HOME=$(/usr/libexec/java_home) # export JAVA_HOME=$(/usr/libexec/java_home -v XX)
export PATH=$JAVA_HOME/bin:$PATH
export CPPFLAGS="-I/opt/homebrew/opt/openjdk/include"

# Android
export ANDROID_HOME="$HOME/Library/Android/sdk"
export PATH="$ANDROID_HOME/emulator:$ANDROID_HOME/platform-tools:$JAVA_HOME/bin:$PATH"

# Antigravity
export PATH="$HOME/.antigravity/antigravity/bin:$PATH"

# NVM
export NVM_DIR="$HOME/.nvm"
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"  # This loads nvm
[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion

# PNPM
export PNPM_HOME="$HOME/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

# ------------------------------------------------------------
# Zsh Plugins
# ------------------------------------------------------------

# Autosuggestions (ghost text based on history)
[ -f /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh ] && \
  source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# Syntax highlighting (must be sourced last)
[ -f /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ] && \
  source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# ------------------------------------------------------------
# Prompt (Starship)
# ------------------------------------------------------------

command -v starship >/dev/null 2>&1 && eval "$(starship init zsh)"

# ------------------------------------------------------------
# Aliases
# ------------------------------------------------------------

alias ll='ls -alF'

alias codexy='codex --yolo'

alias bora="brew update; brew upgrade; brew upgrade --cask; brew cleanup --prune=all"
