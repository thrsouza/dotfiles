#!/bin/bash

# Apply configs from this repo into $HOME (symlink or copy).
# Safe to re-run.

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# tmux
ln -sf "$DOTFILES_DIR/.tmux.conf" "$HOME/.tmux.conf"

# Starship
mkdir -p "$HOME/.config"
ln -sf "$DOTFILES_DIR/.config/starship.toml" "$HOME/.config/starship.toml"

# Git (cp — signingkey is machine-specific, edit freely without touching the repo)
cp "$DOTFILES_DIR/.gitconfig" "$HOME/.gitconfig"

# Claude Code (cp — Claude writes to these files)
mkdir -p "$HOME/.claude"
cp "$DOTFILES_DIR/.claude/settings.json" "$HOME/.claude/settings.json"
cp "$DOTFILES_DIR/.claude/statusline-command.sh" "$HOME/.claude/statusline-command.sh"

# Zsh
cp "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"

echo "Configs applied."
