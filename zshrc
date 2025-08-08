# ~/.zshrc

# Created by Thiago Souza (thrsouza)
# https://github.com/thrsouza/dotfiles

# ------------------------------------------------------------
# GPG Agent
# ------------------------------------------------------------

export GPG_TTY=$(tty)
gpg-connect-agent updatestartuptty /bye >/dev/null 2>&1

# ------------------------------------------------------------
# Fish Shell
# ------------------------------------------------------------

exec fish
